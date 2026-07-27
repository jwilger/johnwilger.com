+++
title = "Using Jeweler for Private Gems"
description = "Configuring Jeweler to manage private Ruby gems without accidentally publishing them to rubygems.org."
slug = "using-jeweler-for-private-gems"
date = 2012-01-25

[extra]
cover = "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=800&q=80"

[extra.narration]
src = "/audio/blog/using-jeweler-for-private-gems.mp3"
type = "audio/mpeg"

[[extra.narration.credits]]
title = "Retro Audio Logo"
creator = "Breviceps"
source_url = "https://freesound.org/people/Breviceps/sounds/564237/"
license = "CC0 1.0"
license_url = "https://creativecommons.org/publicdomain/zero/1.0/"

[[extra.narration.credits]]
title = "01 room tone low frequency hvac"
creator = "pushkin"
source_url = "https://freesound.org/people/pushkin/sounds/215293/"
license = "CC0 1.0"
license_url = "https://creativecommons.org/publicdomain/zero/1.0/"
+++

I really like using [Jeweler] [1] to create and manage gems, but its default
behavior is to publish your gem to [rubygems.org] [2] whenever you run `rake
release`. This is great for generally useful libraries that you want to
open-source, but not as great when you want to use gems as shared libraries for
internal use only (whether because the code contains business secrets or just
because it's not something that would be useful to the community at large.)

After a bit of poking around, I figured out how to use Jeweler to manage
your versioning, gemspec and git tagging without pushing the result to
rubygems.org when running the release task. It turns out to be both obvious and
trivial. Just add the following line to the end of your gem project's
`Rakefile`:

```ruby Rakefile
Rake::Task[:release].prerequisites.delete('gemcutter:release')
```

[1]: http://github.com/technicalpickles/jeweler "technicalpickles/jeweler - GitHub"
[2]: http://rubygems.org "RubyGems.org | your community gem host"
