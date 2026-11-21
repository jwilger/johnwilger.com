+++
title = "Using Jeweler for Private Gems"
description = "Configuring Jeweler to manage private Ruby gems without accidentally publishing them to rubygems.org."
slug = "using-jeweler-for-private-gems"
date = 2012-01-25

[extra]
cover = "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=800&q=80"

+++

I like using [Jeweler][1] to create and manage Ruby gems, but by default `rake release` publishes the gem to [rubygems.org][2]. That's right for a library you're open-sourcing. It's wrong for a gem used as a shared library inside a company, whether the code contains business secrets or just wouldn't be useful to anyone else.

Jeweler can still manage the versioning, gemspec, and git tagging for such a gem without pushing it to rubygems.org on release. Add this line to the end of the gem project's `Rakefile`:

```ruby Rakefile
Rake::Task[:release].prerequisites.delete('gemcutter:release')
```

[1]: http://github.com/technicalpickles/jeweler "technicalpickles/jeweler - GitHub"
[2]: http://rubygems.org "RubyGems.org | your community gem host"
