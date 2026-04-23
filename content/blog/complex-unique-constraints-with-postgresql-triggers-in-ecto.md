+++
title = "Complex Unique Constraints with PostgreSQL Triggers in Ecto"
description = "Handling complex multi-column unique constraints in Ecto by leveraging PostgreSQL triggers and custom changeset validations."
slug = "complex-unique-constraints-with-postgresql-triggers-in-ecto"
date = 2020-02-16
[extra]
cover = "https://cdn.hashnode.com/res/hashnode/image/stock/unsplash/lRoX0shwjUQ/upload/33be72f043a35f9b4b8257720d5a6a75.jpeg"
[taxonomies]
tags = ["postgresql", "database", "elixir", "ecto"]
+++

[Ecto][ecto] makes it easy to work with typical uniqueness constraints in your database; you just
define your table like this:

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

and a module with a [changeset validation for the uniqueness constraint][ecto-unique-constraint],
perhaps like:

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

The Ecto library will attempt to insert your record, and if there is already a record where the
name column is set to "bar", Ecto will see the uniqueness constraint violation error produced by
the database and turn it into a validation error on your changeset, so that it would look
something like:

```elixir
{:error, %Ecto.Changeset{errors: [name: {"has already been taken", _}]}} = result
```

### Something More Complex ###

I recently needed to enforce a database constraint similar in spirit to a unique index (if a
record were in violation, I wanted the same behavior on the Elixir end of things—the changeset
should report that the value for the field "has already been taken") however the criteria for what
should be considered "unique" was more complex than what a simple unique index in PostgreSQL would
be able to deal with.

Let's pretend we have a project that is managing meeting room reservations. The process for
reserving a meeting room is as follows:

1. The customer chooses a room and selects the time range for the reservation.
2. Assuming the room is available at that time, the system places a hold on the room for 24 hours
3. Within that 24-hour period, the customer pays for the room and completes some contractual
   information that must be signed by both the customer and the facility manager.
4. Once the payment is complete and the contracts are signed, the reservation is confirmed.

Here, then, are the business rules for creating a reservation:

* A room reservation cannot be made for a given room and time-period if there exists another room
  reservation for that same room with an overlapping time-period and the existing reservation is
  in a "confirmed" status.

* A room reservation cannot be made for a given room and time-period if there exists another room
  reservation for that same room with an overlapping time-period, the existing reservation is in a
  "hold" status, and the existing reservation was created within the last 24 hours.

We decide to store the room reservations in a table defined as:

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

and ideally, we'd like to be able to model the `RoomReservation` in Elixir as:

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

with the interesting bit being the `|> unique_constraint(:room_id)` line. When a customer tries to
reserve a room that is already reserved for the given time period, we want the
`Meeting.RoomReservation.create/1` function to return with a validation error:

```elixir
%{:error, %Ecto.Changeset{errors: [room_id: {"has already been reserved", _}]}} =
  Meetings.RoomReservation.create(%{
    customer_id: "0af5716a-c3d2-4d4c-87f5-9fed9b2515d4",
    room_id: "2c0d6242-3585-40cb-be92-a1818c0f4a73",
    reservation_starts_at: DateTime.from_naive!(~N[2020-01-01 8:00:00], "Etc/UTC"),
    reservation_ends_at: DateTime.from_naive!(~N[2020-01-01 17:00:00], "Etc/UTC")
  })
```

Clearly, according to the business rules for the system, we can't just put a unique index on the
`room_id` column. To the best of my knowledge, an exclusion constraint also won't work here,
because of the need to *not* check against any rows that have a status of "hold" and an
`inserted_at` timestamp that is more than 24 hours ago relative to the current time. It *is*
however possible to use a trigger function to enforce the constraint in the database:

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

The problem is that instead of that nice validation error on the changeset that we *want* to get,
we instead end up with an unhandled `Postgrex.Error` exception. We could, of course, simply rescue
that exception in our `Meetings.RoomReservation.create/1` function and add the error to the
changeset ourselves, but that starts to look a little ugly:

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

### TL;DR - It's All About the Raise

Knowing that `Ecto.Changeset.unique_constraint/3` works by intercepting an error raised by the
database, I set out to see if I could implement the complex unique constraint logic in the
database and still be able to use the `Ecto.Changeset.unique_constraint/3` validation without
needing to modify any Elixir code. Looking at [the relevant code in ecto_sql][ecto-sql-unique], we
can see that the trick to getting the `room_reservations_check_room_availability` functionality to
work with that function is to change the PostgreSQL exception to use the correct error code as
well as a constraint name that is linked with the changeset validation. We can redifine the
PostgreSQL function as:

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

and then add the `:name` option to our `unique_constraint` in the changeset validation:

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

[ecto]: https://hexdocs.pm/ecto "Ecto"
[ecto-unique-constraint]: https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3 "Ecto.Changeset.unique_constraint/3"
[ecto-sql-unique]: https://github.com/elixir-ecto/ecto_sql/blob/0359b7ce5155974d566fcd0b127f8695aed8b3a9/lib/ecto/adapters/postgres/connection.ex#L18-L19
