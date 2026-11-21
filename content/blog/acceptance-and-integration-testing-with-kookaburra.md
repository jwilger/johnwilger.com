+++
title = "Acceptance and Integration Testing with Kookaburra"
description = "How we built Kookaburra to solve the fragility problem in Cucumber acceptance tests by isolating UI details from test specifications."
slug = "acceptance-and-integration-testing-with-kookaburra"
date = 2012-01-21

[extra]
cover = "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=800&q=80"

+++

**UPDATE (2012-01-22):** *The credit I gave [Sam Livingston-Gray](http://resume.livingston-gray.com/) below didn't show how much he did to get this project off the ground, especially since much of his work was in the private repository this library was extracted from. Thanks, Sam. This might not have gone anywhere if you hadn't put the idea into practice in our application and helped everyone on our team learn the approach. I've made a few small changes below to reflect that.*

Automated acceptance tests written against the details of a user interface break when the interface changes, even when the behavior they describe hasn't. We ran into this at [Renewable Funding](http://renewfund.com). We've used [Cucumber](http://cukes.info/) for acceptance testing since it was still part of the [RSpec](http://rspec.info) project, which was before the company was called Renewable Funding. We've always liked having feature documentation in plain language that we could test against automatically. After years of adding to a fairly large set of scenarios, though, maintaining them was slowing us down. The suite had grown fragile, and it seemed that whenever one of our UX designers changed something in the interface, the development team spent a good deal of time getting Cucumber tests to pass again.

Last year I was reading [Continuous Delivery](http://www.amazon.com/gp/product/0321601912?tag=contindelive-20), by Jez Humble and David Farley, and came to the section titled "The Application Driver Layer" (p. 198). It describes an approach in which the specification and the test implementation are isolated from the details of the user interface. A layer sits between them and uses ordinary object-oriented design to represent the interface's components. Martin Fowler describes it on his website as the [Window Driver][1] pattern.

I started a proof-of-concept implementation last summer, and then my coworker [Sam Livingston-Gray](http://resume.livingston-gray.com/) and I began pulling it into a new project at work. Sam and the rest of the Renewable Funding team improved on my original attempt as they used it over the following six months or so. We've now extracted a library so that other Ruby developers can use the pattern in their own testing. It's called [Kookaburra](http://github.com/projectdx/kookaburra).

<!-- more -->

The rest of this post is adapted from Kookaburra's README as of version 0.7.1.

----

Kookaburra is a framework for implementing the [Window Driver][1] pattern in order to keep acceptance tests maintainable.

## Setup

Kookaburra abstracts some common patterns for implementing the Window Driver pattern in tests of Ruby web applications built on [Rack][2]. You tell it which classes contain the Domain Driver implementations for your application and which driver to use for running the tests (it has been tested only with [Capybara][3] so far). Setting up the Domain Driver layer is covered below. In general, you need something like the following in a location such as `lib/my_application/kookaburra.rb`, with `MyApplication` replaced by a module name that suits your application:

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

### RSpec

For [RSpec][4] integration tests, add the following file to your project:

``` ruby spec/support/kookaburra_setup.rb
require 'my_application/kookaburra'

RSpec.configure do |c|
  c.include(Kookaburra, :type => :request)
end
```

### Cucumber

For Cucumber, add the following file to your project:

``` ruby features/support/kookaburra_setup.rb
require 'my_application/kookaburra'

Kookaburra.adapter = Capybara
World(Kookaburra)

Before do
  # Ensure that there isn't state-leakage between scenarios
  kookaburra_reset!
end
```

This makes the `#api`, `#given`, and `#ui` methods available in your Cucumber step definitions.

## Defining your testing DSL

Kookaburra extracts some common patterns that make the Window Driver pattern easier to use with various Ruby testing frameworks, but you still define your own testing DSL. An acceptance testing stack that uses Kookaburra has four layers:

1. The **Business Specification Language** (Cucumber scenarios and step definitions)
2. The **Domain Driver** (Kookaburra::GivenDriver and Kookaburra::UIDriver)
3. The **Window Driver** (Kookaburra::UIDriver::UIComponent)
4. The **Application Driver** (Capybara and Rack::Test)

### The Business Specification Language

The business specification language is the highest-level description of a feature, suitable for sharing with a project's less technical stakeholders.

Gherkin is the external DSL that Cucumber uses for this. An e-commerce application might have the following scenario:

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

The scenario is written in business terms and leaves out interface details. You "choose to check out"; you don't "click on the checkout button." If the e-commerce system were a terminal application and not a web application, the scenario wouldn't need to change, because the business concepts it describes would be the same.

### The Domain Driver

The Domain Driver layer is where you build an internal DSL that describes your application's business concepts at a fairly high level. It has three top-level drivers. The `APIDriver` (available as `#api`) interacts with your application's external API. The `GivenDriver` (available as `#given`) wraps the `APIDriver` and sets up state for your tests. The `UIDriver` (available as `#ui`) describes the tasks a user can accomplish with the application.

For the Cucumber scenario above, the step definitions call into the Domain Driver layer to interact with the application:

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

The step definitions contain no explicitly shared state (instance variables) and no branching logic. They are wrappers around calls into the Domain Driver layer, and that has two advantages.

The first is that, because step definitions are this simple, there's no need to force very specific wording on the business analyst or product owner who writes the specs. If she writes "I see a summary of my order" in another scenario, it's no trouble to have both of the following in your step definitions, as long as the author confirms that the two phrases mean the same thing:

``` ruby
    Then "I see my order summary" do
      ui.order_summary.should be_visible
    end

    Then "I see a summary of my order" do
      ui.order_summary.should be_visible
    end
```

A step definition is a natural-language reference to an action in the Domain Driver. The slight duplication costs little to maintain, and it allows more readable Gherkin specs. The fewer artificial obstacles there are between your product owner and a written specification, the easier it is to keep her involved in the process.

The second advantage is that, with the complexity pushed down into the Domain Driver, the same code can be reused in developer-centric integration tests. The automated acceptance tests and any additional tests the development team adds then run the same way. The same test written in RSpec alone looks like this:

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

Whether you're writing Cucumber step definitions or developer integration tests, you will usually work only with the `GivenDriver` and the `UIDriver`.

#### TestData

`Kookaburra::TestData` is the component through which the `GivenDriver` and the `UIDriver` share information. If you create a user account through the `GivenDriver`, for instance, you store that account's login credentials in the `TestData` instance, and the `UIDriver` knows what to use when you tell it to `#sign_in`. This is what keeps the Cucumber step definitions free of explicitly shared state.

`TestData` can be configured to hold collections of test data and also default data to use as a starting point for creating new resources in the application. To configure it, call `Kookaburra.test_data_setup` with a block, usually in your `lib/my_application/kookaburra.rb` file:

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

Then, wherever you have an instance of `TestData` (in the `GivenDriver` or the `UIDriver`, for example), you can add items to collections, retrieve them, and read the default data:

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

#### APIDriver

`Kookaburra::APIDriver` interacts with an application's external web services API. You tell Kookaburra about your API by creating a subclass of `Kookaburra::APIDriver` for your application:

``` ruby lib/my_application/kookaburra/api_driver.rb
class MyApplication::Kookaburra::APIDriver < Kookaburra::APIDriver
  def create_account(account_data)
    post_as_json 'Account', 'api/v1/accounts', :account => account_data
    hash_from_response_json[:account]
  end
end
```

#### GivenDriver

`Kookaburra::GivenDriver` creates a particular preexisting state in your application's data and gives you a handle to that data, when you need one, before the test interacts with the UI. As with the `APIDriver`, you create a subclass of `Kookaburra::GivenDriver`, and in it you write part of the Domain Driver DSL for your application:

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

#### UIDriver

`Kookaburra::UIDriver` provides the tools for driving your application's user interface with the Window Driver pattern. You subclass `Kookaburra::UIDriver` for your application and implement your testing DSL in the subclass:

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

### The Window Driver layer

Your `GivenDriver` and `UIDriver` provide a DSL for the actions users can perform in your application. The [Window Driver][1] layer describes the individual interface components a user works with to perform them. Describing each component as an object makes acceptance and integration tests much easier to maintain, because the implementation details of a component are captured in one place. When that implementation changes, you can fix every test that logs a user in to the system by updating the `SignInScreen` class.

You describe the user interface components by subclassing `Kookaburra::UIDriver::UIComponent`:

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
