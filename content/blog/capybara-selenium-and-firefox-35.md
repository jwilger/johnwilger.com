+++
title = "Capybara, Selenium and Firefox 3.5"
description = "A quick fix for Capybara timeout errors when running Selenium tests against older Firefox versions in CI."
slug = "capybara-selenium-and-firefox-35"
date = 2011-04-30

[extra]
cover = "https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=800&q=80"

+++

If Capybara's Selenium driver fails on Firefox 3.5 with `Capybara::TimeoutError: failed to resynchronize, AJAX request timed out`, turning off the driver's `resynchronize` option gets past it. I found that while setting up the CI build for a new project at work, after being stuck on it for a while.

I'd added an example integration spec that visits the default Rails homepage, clicks the "About your application's environment" link, and verifies the Rails version. The link loads the environment details with an AJAX action, so I marked the spec as a JavaScript test, which makes it use Capybara's Selenium driver. It passed on my machine, which has Firefox 4, and failed consistently on CI, which has Firefox 3.5, with the exception above.

I didn't dig far enough into Selenium and Firefox to learn what's going on, and a search for the error message turned up nothing that explained it. The fix is one line in `spec/support/capybara.rb`:

```
Capybara::Selenium::Driver::DEFAULT_OPTIONS[:resynchronize] = false
```

<!-- more -->

I can't promise this has no bad effect further on, but it works for my smoke test. My guess is that `resynchronize` relies on something available only in later versions of Firefox.

Upgrading Firefox on the build agents would be the better solution. There's no Firefox 4 RPM for the Linux distribution those machines run, and our sysadmin doesn't have time to build a custom one. We also have an older application that still uses Webrat and selenium-rc, which I don't believe supports Firefox 4 yet.

If you know what the `resynchronize` option does, and especially why turning it off might be a bad idea, I'd like to hear from you.
