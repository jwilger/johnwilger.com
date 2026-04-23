+++
title = "Kookaburra Rewrite for 0.15.1"
description = "Lessons learned from treating early versions as a spike and rewriting Kookaburra from the ground up with proper tests."
slug = "kookaburra-rewrite-for-0151"
date = 2012-03-10

[extra]
cover = "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80"
+++

After getting some good feedback on [Kookaburra] [Kookaburra] since the original
release announcement as well as using it in a few more projects, [Sam] [SLG] and
I decided to treat all of the versions prior to 0.15.0 as a spike and rewrite
the framework from the ground up. Although we certainly learned a lot about the
approach with the pre-0.15 versions, the problems with continuing to grow
Kookaburra from that seed became apparent as we tried to use it in more
applications.

Because the original code was extracted from another project, the Kookaburra
framework itself was not well tested. It had been indirectly tested due to its
position within that other project's tests, but as a seperate library it lacked
tests that would help bot document the project and ensure newcomers can work on
it with a good safety net. Additionally, there were a number of design decisions
made in the earlier versions of Kookaburra that were...questionable. Not only
would these decisions probably have been made differently if the development of
the framework itself had been driven with unit tests, these decisions in many
cases made it difficult to go back and add tests after the fact.

Starting with 0.15.1, which I just [released] [Gem] a few moments ago,
Kookaburra has been rewritten using a proper TDD approach. In some ways, 0.15.1
is possibly less functional than its 0.14.x cousins, but it is almost certainly
easier to understand and contribute to the project from this point on. Please
have a look at the new codebase, try it out in your projects, and send me a pull
request with updates to the library. Also, if you have any problems getting it
running, please don't hesitate to [let me know] [GHIssues].

[Kookaburra]: http://github.com/jwilger/kookaburra "jwilger/kookaburra"
[SLG]: http://livingston-gray.com  "Sam Livingston-Gray"
[Gem]: http://rubygems.org/gems/kookaburra "kookaburra | Rubygems.org"
[GHIssues]: https://github.com/jwilger/kookaburra/issues?sort=created&direction=desc&state=open "Issues jwilger/kookaburra"
