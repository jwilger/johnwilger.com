+++
title = "Acceptance and Integration Testing with Kookaburra"
description = "How we built Kookaburra to solve the fragility problem in Cucumber acceptance tests by isolating UI details from test specifications."
slug = "acceptance-and-integration-testing-with-kookaburra"
date = 2012-01-21

[extra]
cover = "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=800&q=80"
+++

**UPDATE (2012-01-22):** *I realized this morning that the credit I gave to [Sam
Livingston-Gray](http://resume.livingston-gray.com/) below may not have
adequately shown how instrumental he was in getting this project off the ground;
especially since much of his work was done in the private repository from which
this was extracted. So, thanks, Sam. This might not have gone anywhere if you
hadn't worked to put the idea in practice in our application and helped everyone
on our team learn how to use the approach. I made a few minor changes below to
reflect this a bit better.*

We've been using [Cucumber](http://cukes.info/) for acceptance testing at
[Renewable Funding](http://renewfund.com) since back when it was still part of
the [RSpec](http://rspec.info) project (indeed, since before we were even
Renewable Funding). While we've always liked the ability to have plain-language
feature documentation that we could automatically test against, after years of
adding to and maintaining a fairly large set of Cucumber scenarios, the cost of
that maintenance was starting to really slow us down. The test suite began to
grow fragile, and it seemed like every time one of our UX designers changed
anything about the application's interface, the development team would spend a
bunch of time just babysitting Cucumber tests to get them passing again.

Last year, as I was reading Jez Humble's excellent [Continuous
Delivery](http://www.amazon.com/gp/product/0321601912?tag=contindelive-20) book,
I was inspired when I came across the section titled "The Application Driver
Layer" (p. 198). This section describes an approach to acceptance testing where
the specification and the test implementation are isolated from the details of
the application's user interface by inserting a layer between the two that uses
good old OOP to abstract the user interface components. Martin Fowler describes
it as the [Window Driver] [1] pattern on his website.

I started a proof-of-concept implementation of this pattern last summer, then my
coworker, [Sam Livingston-Gray](http://resume.livingston-gray.com/) and I
started pulling it into a new project at work. After Sam and the rest of the
Renewable Funding team helped improve on my original attempt while putting it to
use for the last six or so months, we extracted a library to make it easier for
other Ruby developers to implement this pattern in their testing. I'm happy to
introduce [Kookaburra](http://github.com/projectdx/kookaburra) to the world.

<!-- more -->

The following comes from Kookaburra's README as of version 0.7.1.

----

# Kookaburra #

Kookaburra is a framework for implementing the [Window Driver] [1] pattern in
order to keep acceptance tests maintainable.

## Setup ##

Kookaburra itself abstracts some common patterns for implementing the Window
Driver pattern for tests of Ruby web applications built on [Rack] [2]. You will need
to tell Kookaburra which classes contain the specific Domain Driver
implementations for your application as well as which driver to use for running
the tests (currently only tested with [Capybara] [3]). The details of setting up your
Domain Driver layer are discussed below, but in general you will need the
following in a locations such as `lib/my_application/kookaburra.rb` (replace
`MyApplication` with a module name suitable to your actual application:

``` ruby
module MyApplication
  module Kookaburra
    ::Kookaburra.adapter = Capybara

    # Note: the following assigned classes are defined under your
    # application's namespace, e.g. MyApplication::Kookaburra::APIDriver
    ::Kookaburra.api_driver = APIDriver
    ::Kookaburra.given_driver = GivenDriver
    ::Kookaburra.ui_driver = UIDriver

    ::Kookaburra.test_data_setup do
      provide_collection :accounts
      # See section on Test Data for more examples of what can go here.
    end
  end
end
```

### RSpec ###

For [RSpec] [4] integration tests, just add the following file to your project:

``` ruby spec/support/kookaburra_setup.rb
require 'my_application/kookaburra'

RSpec.configure do |c|
  c.include(Kookaburra, :type => :request)
end
```

### Cucumber ###

For Cucumber, add the following file to your project

``` ruby features/support/kookaburra_setup.rb
require 'my_application/kookaburra'

Kookaburra.adapter = Capybara
World(Kookaburra)

Before do
  # Ensure that there isn't state-leakage between scenarios
  kookaburra_reset!
end
```

This will cause the #api, #given and #ui methods will be available in your
Cucumber step definitions.

## Defining Your Testing DSL ##

Kookaburra attempts to extract some common patterns that make it easier to use
the Window Driver pattern along with various Ruby testing frameworks, but you
still need to define your own testing DSL. An acceptance testing stack using
Kookaburra has the following four layers:

1. The **Business Specification Language** (Cucumber scenarios and step definitions)
2. The **Domain Driver** (Kookaburra::GivenDriver and Kookaburra::UIDriver)
3. The **Window Driver** (Kookaburra::UIDriver::UIComponent)
4. The **Application Driver** (Capybara and Rack::Test)

### The Business Specification Language ###

The business specification language consists of the highest-level descriptions
of a feature that are suitable for sharing with the non/less-technical
stakeholders on a project.

Gherkin is the external DSL used by Cucumber for this purpose, and you might
have the following scenario defined for an e-commerce application:

``` cucumber purchase_items_in_cart.feature
Feature: Purchase Items in Cart

  Scenario: Using Existing Billing and Shipping Information
    
    Given I have an existing account
    And I have previously specified default payment options
    And I have previously specified default shipping options
    And I have an item in my shopping cart

    When I sign in to my account
    And I choose to check out

    Then I see my order summary
    And I see that my default payment options will be used
    And I see that my default shipping options will be used
```

Note that the scenario is focused on business concepts versus interface details,
i.e. you "choose to check out" rather than "click on the checkout button". If
for some reason your e-commerce system was going to be a terminal application
rather than a web application, you would not need to change this scenario at
all, because the actual business concepts described would not change.

### The Domain Driver ###

The Domain Driver layer is where you build up an internal DSL that describes the
business concepts of your application at a fairly high level. It consists of
three top-level drivers: the `APIDriver` (available via `#api`) for interacting
with your application's external API, the `GivenDriver` (available via `#given`)
which really just wraps the `APIDriver` and is used to set up state for your
tests, and the UIDriver (available via `#ui`) for describing the tasks that a
user can accomplish with the application.

Given the Cucumber scenario above, the step definitions call into the Domain
Driver layer to interact with your application:

``` ruby step_definitions/various_steps.rb
Given "I have an existing account" do
  given.existing_account(:my_account)
end

Given "I have previously specified default payment options" do
  given.default_payment_options_specified_for(:my_account)
end

Given "I have previously specified default shipping options" do
  given.default_shipping_options_specified_for(:my_account)
end

Given "I have an item in my shopping cart" do
  given.an_item_in_my_shopping_cart(:my_account)
end

When "I sign in to my account" do
  ui.sign_in(:my_account)
end

When "I choose to check out" do
  ui.choose_to_check_out
end

Then "I see my order summary" do
  ui.order_summary.should be_visible
end

Then "I see that my default payment options will be used" do
  ui.order_summary.payment_options.should be_account_default_options
end

Then "I see that my default shipping options will be used" do
  ui.order_summary.shipping_options.should be_account_default_options
end
```

The step definitions contain neither explicitly shared state (instance
variables) nor any logic branches; they are simply wrappers around calls into
the Domain Driver layer. There are a couple of advantages to this approach.
First, because step definitions are so simple, it isn't necessary to force *Very
Specific Wording* on the business analyst/product owner who is writing the
specs. For instance, if she writes "I see a summary of my order" in another
scenario, it's not a big deal to have the following in your step definitions (as
long as the author of the spec confirms that they really mean the same thing):

``` ruby
    Then "I see my order summary" do
      ui.order_summary.should be_visible
    end

    Then "I see a summary of my order" do
      ui.order_summary.should be_visible
    end
```

The step definitions are nothing more than a natural language reference to an
action in the Domain Driver; there is no overwhelming maintenance cost to the
slight duplication, and it opens up the capacity for more readable Gherkin
specs. The fewer false road blocks you put between your product owner and a
written specification, the easier it becomes to ensure her participation in this
process.

The second advantage is that by pushing all of the complexity down into the
Domain Driver, it's now trivial to reuse the exact same code in
developer-centric integration tests. This ensures you have parity between the
way the automated acceptance tests run and any additional testing that the
development team needs to add in. You could write the same test using just
RSpec as follows:

``` ruby spec/integration/purchase_items_in_cart_spec.rb
describe "Purchase Items in Cart" do
  example "Using Existing Billing and Shipping Information" do
    given.existing_account(:my_account)
    given.default_payment_options_specified_for(:my_account)
    given.default_shipping_options_specified_for(:my_account)
    given.an_item_in_my_shopping_cart(:my_account)

    ui.sign_in(:my_account)
    ui.choose_to_check_out

    ui.order_summary.should be_visible
    ui.order_summary.payment_options.should be_account_default_options
    ui.order_summary.shipping_options.should be_account_default_options
  end
end
```

Whether in Cucumber step definitions or developer integration tests, you will
usually interact only with the GivenDriver and the UIDriver.

#### TestData ####

`Kookaburra::TestData` is the component via which the `GivenDriver` and the
`UIDriver` share information. For instance, if you create a user account via the
`GivenDriver`, you would store the login credentials for that account in the
`TestData` instance, so the UIDriver knows what to use when you tell it to
`#sign_in`. This is what allows the Cucumber step definitions to remain free
from explicitly shared state.

The `TestData` class can be configured to contain both collections of test data
as well as default data that can be used as a starting point for creating new
resources in the application. To configure `TestData`, call
`Kookaburra.test_data_setup` with a block (usually in your
`lib/my_application/kookaburra.rb` file):

``` ruby lib/my_application/kookaburra.rb
module MyApplication
  module Kookaburra
    # ...
    ::Kookaburra.test_data_setup do
      provide_collection :animals
      set_default :animal,
        :name => 'horse'
        :size => 'large',
        :number_of_legs => 4
    end
  end
end
```

Then, in any context where you have an instance of `TestData` (such as in
`GivenDriver` or `UIDriver`), you can add/retrieve items to/from collections and
access default data:

``` ruby lib/my_application/kookaburra/given_driver.rb
class MyApplication::Kookaburra::GivenDriver < Kookaburra::GivenDriver
  def existing_account(nickname)
    default_account_data = test_data.default(:account)
    # do something to create account in application
    # ...
    # make the details of the new account available to the rest of the test
    test_data.accounts[nickname] = account
  end
end
```

``` ruby lib/my_application/kookaburra/ui_driver.rb
class MyApplication::Kookaburra::UIDriver < Kookaburra::UIDriver
  def sign_in(account_nickname)
    # pull stored account details from TestData
    account_info = test_data.accounts[account_nickname]

    # do something to log in using that account_info
  end
end
```

#### APIDriver ####

The `Kookaburra::APIDriver` is used to interact with an application's external
web services API. You tell Kookaburra about your API by creating a subclass of
`Kookaburra::APIDriver` for your application:

``` ruby lib/my_application/kookaburra/api_driver.rb
class MyApplication::Kookaburra::APIDriver < Kookaburra::APIDriver
  def create_account(account_data)
    post_as_json 'Account', 'api/v1/accounts', :account => account_data
    hash_from_response_json[:account]
  end
end
```

#### GivenDriver ####

The `Kookaburra::GivenDriver` is used to create a particular "preexisting"
state within your application's data and ensure you have a handle to that data
(when needed) prior to interacting with the UI. Like the `APIDriver`, you will
create a subclass of `Kookaburra::GivenDriver` in which you will create part of
the Domain Driver DSL for your application:

``` ruby lib/my_application/kookaburra/given_driver.rb
class MyApplication::Kookaburra::GivenDriver < Kookaburra::GivenDriver
  def existing_account(nickname)
    # grab the default account details and add a unique username and
    # password
    account_data = test_data.default(:account)
    account_data[:username] = "test-user-#{`uuidgen`.strip}"
    account_data[:password] = account_data[:username] + "-password"

    # use the API to create the account in the application
    account_details = api.create_account(account_data)

    # merge in the password (since API doesn't return it) and store details
    # in the TestData instance
    account_details.merge(:password => account_data[:password])
    test_data.accounts[nickname] = account_details
  end
end
```

#### UIDriver ####

`Kookaburra::UIDriver` provides the necessary tools for driving your
application's user interface using the Window Driver pattern. You will subclass
`Kookaburra::UIDriver` for your application and implement your testing DSL
within your subclass:

``` ruby lib/my_application/kookaburra/ui_driver.rb
class MyApplication::Kookaburra::UIDriver < Kookaburra::UIDriver
  # makes an instance of MyApplication::Kookaburra::UIDriver::SignInScreen
  # available via the instance method #sign_in_screen
  ui_component :sign_in_screen

  def sign_in(account_nickname)
    account = test_data.accounts[account_nickname]
    navigate_to :sign_in_screen
    sign_in_screen.submit_login(account[:username], account[:password])
  end
end
```

### The Window Driver Layer ###

While your `GivenDriver` and `UIDriver` provide a DSL that represents actions
your users can perform in your application, the [Window Driver] [1] layer describes
the individual user interface components that the user interacts with to perform
these tasks. By describing each interface component using an OOP approach, it is
much easier to maintain your acceptance/integration tests, because the
implementation details of each component are captured in a single place. If/when
that implementation changes, you can---for example---fix every single test that
needs to log a user into the system just by updating the SignInScreen class.

You describe the various user interface components by sub-classing
`Kookaburra::UIDriver::UIComponent`:

``` ruby lib/my_application/ui_driver/sign_in_screen.rb
class MyApplication::Kookaburra::UIDriver::SignInScreen < Kookaburra::UIDriver::UIComponent
  component_locator '#new_user_session'
  component_path '/session/new'

  def username
    in_component { browser.find('#session_username').value }
  end

  def username=(new_value)
    fill_in('#session_username', :with => new_value)
  end

  def password
    in_component { browser.find('#session_password').value }
  end

  def password=(new_value)
    fill_in('#session_password', :with => new_value)
  end

  def submit!
    click_on('Sign In')
    no_500_error!
  end

  def submit_login(username, password)
    self.username = username
    self.password = password
    submit!
  end
end
```

[1]: http://martinfowler.com/eaaDev/WindowDriver.html "Window Driver - Martin Fowler"
[2]: http://rack.rubyforge.org/ "Rack: a Ruby Webserver Interface"
[3]: https://github.com/jnicklas/capybara "jnicklas/capybara - GitHub"
[4]: http://rspec.info "RSpec.info: home"
