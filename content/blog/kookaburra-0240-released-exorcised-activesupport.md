+++
title = "Kookaburra 0.24.0 Released - Exorcised ActiveSupport"
description = "Removing the ActiveSupport dependency from Kookaburra to improve compatibility across Rails versions."
slug = "kookaburra-0240-released-exorcised-activesupport"
date = 2012-05-15

[extra]
cover = "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80"

+++

[Kookaburra][K], a Ruby framework for acceptance and integration testing, used to depend on ActiveSupport 3.0 or later. That kept it from working smoothly with Rails 2.x applications, at least within the same Bundler bundle. Version 0.24.0, which I've just released to [Rubygems.org][RGO], removes the dependency. Kookaburra used only a small fraction of [ActiveSupport][AS], so breaking the dependency was the easiest way to let an application use whichever version of ActiveSupport it needs. Kookaburra's own API hasn't changed. This is a minor release and not a patch release because removing the dependency can change how your application behaves.

ActiveSupport modifies a number of core Ruby classes. If your application doesn't explicitly require ActiveSupport elsewhere, some of those classes may now behave differently. Kookaburra had been using the `Hash` and `String` core extensions and `ActiveSupport::CoreExt::Module::Delegation`.

JSON handling has changed as well. `Kookaburra::JsonApiDriver` used `ActiveSupport::JSON` to encode and decode JSON data. It now uses `::JSON`, as provided by either the [json][json] gem or the [json_pure][json_pure] gem. Kookaburra's own tests pass with the new library swapped in, but they don't test JSON usage comprehensively, and there may be differences that affect your application.

Kookaburra declares its dependency on `json_pure`, a pure-Ruby implementation, so that it works on every platform. Both gems are written so that `require 'json'` detects whether both are installed and prefers the natively compiled `json` version.

[K]: http://github.com/jwilger/kookaburra
[RGO]: http://rubygems.org/gems/kookaburra/versions/0.24.0
[AS]: http://rubydoc.info/gems/activesupport/3.0.0/frames "ActiveSupport 3.0.0 API Documentation"
[json]: http://rubygems.org/gems/json "json | RubyGems.org"
[json_pure]: http://rubygems.org/gems/json_pure "json_pure | RubyGems.org"
