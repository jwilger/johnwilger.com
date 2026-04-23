+++
title = "Capybara, Selenium and Firefox 3.5"
description = "A quick fix for Capybara timeout errors when running Selenium tests against older Firefox versions in CI."
slug = "capybara-selenium-and-firefox-35"
date = 2011-04-30

[extra]
cover = "https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=800&q=80"
+++

I banged my head against this one while setting up our CI build for a new
project at work and just now figured it out. I added an example integration
spec that just visits the default Rails homepage, clicks the "About your
application's environment" link, and verifies the Rails version. This link
uses an AJAX action to load the environment details, so I marked it as a
JavaScript test, which would cause it to use Capybara's Selenium driver.

The test passed fine on my machine (with Firefox 4 installed), but it failed
consistently on CI, which has Firefox 3.5. It kept failing with the exception
`Capybara::TimeoutError: failed to resynchronize, AJAX request timed out`. I
didn't dig enough into the guts of Selenium/Firefox to find out exactly what
is going on (and a Google search for that error message turned up nothing that
really explained it) but I did at least find a workable fix. Just add the
following line to `spec/support/capybara.rb`:

```
Capybara::Selenium::Driver::DEFAULT_OPTIONS[:resynchronize] = false
```

<!-- more -->

Now, I can't guarantee that this won't have a negative effect further down the
line, but it works for my smoke-test. The `resynchronize` option must be using
something that is only available in later versions of Firefox.

Obviously the better solution would be to upgrade Firefox on our build-agents.
Unfortunately there isn't a Firefox 4 RPM available for the Linux
distribution/version that those machines are using, and our sysadmin doesn't
have any room on his plate to come up with a custom solution. Also, we have an
older application that still uses Webrat/selenium-rc, and I don't believe that
supports Firefox 4 yet.

I'd love to see any comments or pointers to information that would help me
understand exactly what that resynchronize option is doing, especially if
someone knows why turning it off could be a Very Bad Thing™.
