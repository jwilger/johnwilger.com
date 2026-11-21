+++
title = "Complex Unique Constraints with PostgreSQL Triggers in Ecto"
description = "How to enforce a uniqueness rule that a unique index can't express with a PostgreSQL trigger, and still get an ordinary Ecto changeset validation error."
slug = "complex-unique-constraints-with-postgresql-triggers-in-ecto"
date = 2020-02-16
[extra]
cover = "https://cdn.hashnode.com/res/hashnode/image/stock/unsplash/lRoX0shwjUQ/upload/33be72f043a35f9b4b8257720d5a6a75.jpeg"

[taxonomies]
tags = ["postgresql", "database", "elixir", "ecto"]
+++

Some business rules are too important to enforce only in application code. If two customers can be sold the same meeting room for the same afternoon, it doesn't matter which part of the application let it through. A rule like that belongs in the database, where application code can't bypass it. The database's built-in tools cover the simple cases, though, and a rule with conditions in it, such as "this room is taken unless the earlier booking was an unpaid hold that has expired," doesn't fit a unique index. This post shows how to enforce that kind of rule with a PostgreSQL trigger and still have [Ecto][ecto], Elixir's database library, report a violation as an ordinary validation error.

Ecto already handles the simple case. You define a table with a unique index:

```elixir
defmodule MyApp.Repo.Migrations.CreateFoos do
  use Ecto.Migration

  def change do
    create table(:foos) do
      add :name, :text, null: false
    end

    create unique_index(:foos, :name)
  end
end
```

and a schema module whose changeset declares [the uniqueness constraint][ecto-unique-constraint]:

```elixir
defmodule MyApp.Foo do
  use Ecto.Schema

  import Ecto.Changeset

  schema "foos" do
    field :name, :string
  end

  def changeset(%__MODULE__{} = foo, %{} = changes) do
      foo
      |> cast(changes, [:name])
      |> unique_constraint(:name)
  end
end
```

Then, when you run:

```elixir
result = MyApp.Foo.changeset(%MyApp.Foo{}, %{name: "bar"})
         |> MyApp.Repo.insert()
```

Ecto attempts the insert. If a row already has the name "bar", the database rejects the new one, and Ecto turns the database's uniqueness error into a validation error on the changeset:

```elixir
{:error, %Ecto.Changeset{errors: [name: {"has already been taken", _}]}} = result
```

## A rule a unique index can't express

I recently needed a constraint that behaved like a unique index from the Elixir side, with the changeset reporting that a value "has already been taken," but whose definition of "unique" was more than a unique index in PostgreSQL can express.

Take a system that manages meeting room reservations. A room is reserved in four steps:

1. The customer chooses a room and selects the time range for the reservation.
2. If the room is available at that time, the system places a hold on it for 24 hours.
3. Within those 24 hours, the customer pays for the room and completes some contractual information that must be signed by both the customer and the facility manager.
4. Once the payment is complete and the contracts are signed, the reservation is confirmed.

Two rules for creating a reservation follow from that:

* A room can't be reserved for a period that overlaps an existing reservation of the same room in "confirmed" status.
* A room can't be reserved for a period that overlaps an existing reservation of the same room in "hold" status that was created within the last 24 hours.

The reservations are stored in this table:

```elixir
defmodule Meetings.Repo.Migrations.CreateRoomReservations do
  use Ecto.Migration

  def change do
    create table(:room_reservations) do
      add :customer_id, :binary_id, null: false
      add :room_id, :binary_id, null: false
      add :reservation_starts_at, :timestamp, null: false
      add :reservation_ends_at, :timestamp, null: false
      add :status, :text, null: false, default: "hold"
      timestamps()
    end
  end
end
```

Ideally, the `RoomReservation` would be modeled in Elixir like this:

```elixir
defmodule Meetings.RoomReservation do
  use Ecto.Schema

  import Ecto.Changeset

  schema "room_reservations" do
    field :customer_id, :binary_id
    field :room_id, :binary_id
    field :reservation_starts_at, :utc_datetime
    field :reservation_ends_at, :utc_datetime
    field :status, :string
    timestamps()
  end

  def create(%{} = res_data) do
    %__MODULE__{}
    |> cast(res_data, [:customer_id, :room_id, :reservation_starts_at, :reservation_ends_at])
    |> validate_required([:customer_id, :room_id, :reservation_starts_at, :reservation_ends_at])
    |> put_change(:status, "hold")
    |> unique_constraint(:room_id, message: "has already been reserved")
    |> Meeting.Repo.insert()
  end
end
```

The line that matters is the call to `unique_constraint(:room_id, ...)`. When a customer tries to reserve a room that is already reserved for that period, `Meetings.RoomReservation.create/1` should return a validation error:

```elixir
%{:error, %Ecto.Changeset{errors: [room_id: {"has already been reserved", _}]}} =
  Meetings.RoomReservation.create(%{
    customer_id: "0af5716a-c3d2-4d4c-87f5-9fed9b2515d4",
    room_id: "2c0d6242-3585-40cb-be92-a1818c0f4a73",
    reservation_starts_at: DateTime.from_naive!(~N[2020-01-01 8:00:00], "Etc/UTC"),
    reservation_ends_at: DateTime.from_naive!(~N[2020-01-01 17:00:00], "Etc/UTC")
  })
```

A unique index on the `room_id` column can't express these rules. To the best of my knowledge an exclusion constraint can't either, because the check has to leave out rows with a status of "hold" and an `inserted_at` timestamp more than 24 hours old. A trigger function can enforce the rule in the database:

```elixir
defmodule Meetings.Repo.Migrations.CreateRoomReservations do
  use Ecto.Migration

  def change do
    create table(:room_reservations) do
      add :customer_id, :binary_id, null: false
      add :room_id, :binary_id, null: false
      add :reservation_starts_at, :timestamp, null: false
      add :reservation_ends_at, :timestamp, null: false
      add :status, :text, null: false, default: "hold"
      timestamps()
    end

    execute(
      # up
      ~S"""
      CREATE FUNCTION room_reservations_check_room_availability() RETURNS TRIGGER AS
      $$
      BEGIN
      IF EXISTS(
        SELECT 1
        FROM room_reservations rr
        WHERE rr.room_id = NEW.room_id
          AND tsrange(rr.reservation_starts_at, rr.reservation_ends_at, '[]') &&
              tsrange(NEW.reservation_starts_at, NEW.reservation_ends_at, '[]')
          AND (
            rr.status = 'confirmed'
              OR rr.inserted_at > CURRENT_TIMESTAMP - interval '24 hours'
          )
      )
      THEN
        RAISE "room already reserved";
      END IF;
      RETURN NEW;
      END;
      $$ language plpgsql;
      """,

      # down
      "DROP FUNCTION room_reservations_check_room_availability;"
    )

    execute(
      # up
      ~S"""
      CREATE TRIGGER room_reservations_room_availability_check
      BEFORE INSERT ON room_reservations
      FOR EACH ROW
      EXECUTE PROCEDURE room_reservations_check_room_availability();
      """,

      # down
      "DROP TRIGGER room_reservations_room_availability_check ON room_reservations;"
    )
  end
end
```

The database now enforces the rule, but the Elixir code gets an unhandled `Postgrex.Error` exception where we wanted a validation error on the changeset. We could rescue the exception in `Meetings.RoomReservation.create/1` and add the error to the changeset ourselves, which starts to look ugly:

```elixir
defmodule Meetings.RoomReservation do
  # ...

  def create(%{} = res_data) do
    changeset =
      %__MODULE__{}
      |> cast(res_data, [:customer_id, :room_id, :reservation_starts_at, :reservation_ends_at])
      |> validate_required([:customer_id, :room_id, :reservation_starts_at, :reservation_ends_at])
      |> put_change(:status, "hold")
    Meeting.Repo.insert(changeset)
  rescue
    error in Postgrex.Error ->
      case error do
        %{postgres: %{message: "room already reserved"}} ->
          changeset
          |> add_error(:room_id, "has already been reserved")
      end
  end
end
```

## Raising the error Ecto expects

`Ecto.Changeset.unique_constraint/3` works by intercepting an error raised by the database. The constraint logic can therefore stay in the database and still work with that validation, with no rescue clause in the Elixir code, as long as the database raises the error Ecto is looking for. [The relevant code in ecto_sql][ecto-sql-unique] shows what that is. The PostgreSQL exception has to carry the unique-violation error code and a constraint name that matches the one given to the changeset validation. The trigger function becomes:

```sql
CREATE FUNCTION room_reservations_check_room_availability() RETURNS TRIGGER AS
$$
BEGIN
IF EXISTS(
  SELECT 1
  FROM room_reservations rr
  WHERE rr.room_id = NEW.room_id
    AND tsrange(rr.reservation_starts_at, rr.reservation_ends_at, '[]') &&
        tsrange(NEW.reservation_starts_at, NEW.reservation_ends_at, '[]')
    AND (
      rr.status = 'confirmed'
        OR rr.inserted_at > CURRENT_TIMESTAMP - interval '24 hours'
    )
)
THEN
  RAISE unique_violation
    USING CONSTRAINT = 'room_reservations_room_reserved';
END IF;
RETURN NEW;
END;
$$ language plpgsql;
```

and the changeset passes the same name to `unique_constraint` through the `:name` option:

```elixir
defmodule Meetings.RoomReservation do
  #...

  def create(%{} = res_data) do
    %__MODULE__{}
    |> cast(res_data, [:customer_id, :room_id, :reservation_starts_at, :reservation_ends_at])
    |> validate_required([:customer_id, :room_id, :reservation_starts_at, :reservation_ends_at])
    |> put_change(:status, "hold")
    |> unique_constraint(:room_id,
                         message: "has already been reserved",
                         name: "room_reservations_room_reserved")
    |> Meeting.Repo.insert()
  end
end
```

The rule is enforced in the database, and a caller of `create/1` sees a double booking as it would see any other validation failure.

[ecto]: https://hexdocs.pm/ecto "Ecto"
[ecto-unique-constraint]: https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3 "Ecto.Changeset.unique_constraint/3"
[ecto-sql-unique]: https://github.com/elixir-ecto/ecto_sql/blob/0359b7ce5155974d566fcd0b127f8695aed8b3a9/lib/ecto/adapters/postgres/connection.ex#L18-L19
