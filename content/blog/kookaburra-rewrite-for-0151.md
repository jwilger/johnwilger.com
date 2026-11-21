+++
title = "Kookaburra Rewrite for 0.15.1"
description = "Lessons learned from treating early versions as a spike and rewriting Kookaburra from the ground up with proper tests."
slug = "kookaburra-rewrite-for-0151"
date = 2012-03-10

[extra]
cover = "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80"

+++

[Sam][SLG] and I have rewritten [Kookaburra][Kookaburra] from the ground up. After the original release announcement we got good feedback and used the framework in a few more projects, and the problems with growing it from where it had started became apparent. We learned a lot about the approach from the versions before 0.15.0, and we decided to treat all of them as a spike.

The original code was extracted from another project, so Kookaburra itself wasn't well tested. That project's tests exercised it indirectly, but as a separate library it lacked tests that would document it and give newcomers a safety net to work with. A number of design decisions in the earlier versions were also questionable. Had unit tests driven the framework's development, those decisions would probably have been made differently, and in many cases they made it difficult to add tests afterwards.

Version 0.15.1, which I've just [released][Gem], was written test-first. In some ways it may do less than the 0.14.x versions, but it should be easier to understand and to contribute to. Please look at the new codebase, try it in your projects, and send me pull requests. If you have trouble getting it running, [let me know][GHIssues].

[Kookaburra]: http://github.com/jwilger/kookaburra "jwilger/kookaburra"
[SLG]: http://livingston-gray.com  "Sam Livingston-Gray"
[Gem]: http://rubygems.org/gems/kookaburra "kookaburra | Rubygems.org"
[GHIssues]: https://github.com/jwilger/kookaburra/issues?sort=created&direction=desc&state=open "Issues jwilger/kookaburra"
