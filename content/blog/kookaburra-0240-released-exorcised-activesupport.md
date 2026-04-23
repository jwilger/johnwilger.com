+++
title = "Kookaburra 0.24.0 Released - Exorcised ActiveSupport"
description = "Removing the ActiveSupport dependency from Kookaburra to improve compatibility across Rails versions."
slug = "kookaburra-0240-released-exorcised-activesupport"
date = 2012-05-15

[extra]
cover = "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80"
+++

I just released version 0.24.0 of [Kookaburra][K] to
[Rubygems.org][RGO]. While there were no changes to *Kookaburra's* API
with this release, it is a minor release rather than a patch release,
because I removed [ActiveSupport][AS] from Kookaburra's dependencies.
Previously, Kookaburra depended on ActiveSupport >= 3.0, and this
prevented it from working smoothly with Rails 2.x applications (at least
in the same Bundler bundle.) Since Kookaburra only used a small fraction
of ActiveSupport, it seemed easiest just to break the dependency, so
that your application can use whatever version of ActiveSupport it
needs.

Because of the fact that ActiveSupport makes a number of modifications
to core Ruby classes, if your application does not otherwise explicitly
require ActiveSupport, some of these core classes may now behave
differently. Specifically, `Hash` and `String` core extensions were
being used, as well as `ActiveSupport::CoreExt::Module::Delegation`.

Also, where `Kookaburra::JsonApiDriver` used `ActiveSupport::JSON` for
encoding and decoding of JSON data, it now uses `::JSON` as provided by
*either* the [json][json] or the [json_pure][json_pure] gems. The tests
on Kookaburra itself pass just by swapping out ActiveSupport JSON
library for the new one, but these tests do not comprehensively test
JSON usage, and there may be differences that impact your application.

Kookaburra declares its dependency on the `json_pure` gem (a pure-ruby
version) in order to ensure that it works cross-platform. However, both
`json` and `json_pure` are written in such a way that, when you `require
'json'`, it will detect if both libraries are installed and prefer the
natively compiled `json` gem's version of the library.

[K]: http://github.com/jwilger/kookaburra
[RGO]: http://rubygems.org/gems/kookaburra/versions/0.24.0
[AS]: http://rubydoc.info/gems/activesupport/3.0.0/frames "ActiveSupport 3.0.0 API Documentation"
[json]: http://rubygems.org/gems/json "json | RubyGems.org"
[json_pure]: http://rubygems.org/gems/json_pure "json_pure | RubyGems.org"
