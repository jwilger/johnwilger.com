+++
title = "Production Release Workflow with Git"
description = "Transforming a painful multi-hour release process into a five-minute, low-stress workflow using Git branching strategies."
slug = "production-release-workflow-with-git"
date = 2011-01-08

[extra]
cover = "https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?w=800&q=80"
+++

After growing the [ProjectDX](http://www.projectdx.com) team from three to
eight software developers, our release process was a complete pain, and it
typically took two to three hours to get a good build on the production branch
(and even then some insidious issues would sneak through). By making a few
changes to our development and acceptance process, we were able to turn it
into a five-minute, low-stress job.

<!-- more -->

A couple of years ago, our team was much smaller. We had around three
full-time developers working on the code, and we would all commit our
work-in-progress to the master branch in our [git](http://git-scm.com/)
repository and push those commits out when we had a set that made sense to
share with the other developers. With only a few developers, we would usually
be working on one feature at a time, and once a small number of features were
accepted and ready, we could go ahead and release them to production. This
worked pretty well at the time, and when we *did* have a merge conflict, we
were all familiar enough with what was being worked on to be able to work it
out reasonably.

In 2010, the ProjectDX team was acquired by [Renewable
Funding](http://www.renewfund.com). Among other things, this gave us both the
resources and the need to grow the team beyond just a few developers. I took
over management of the software development team, and within several months
had hired three new developers and then added 2-3 contract developers to the team
at any given time. It's no big surprise that increasing the size of a team by
a factor of three in a six month period is going to have some challenges, and
one of those was how the flow of work through the system needed to
change.

At first, we didn't change anything about that process (I prefer not to change
things before I have any idea what the real problems are going to be).
Developers still committed work to the master branch, and that branch was
deployed to our internal alpha server by our automated CI system if and when
all of the tests passed. When the developers working on a feature felt that it
was complete, they put it up for acceptance, and the product owner verified
the feature on alpha before either accepting or rejecting the work. However,
our increased capacity meant that more individual features were worked on at
any given time, and this parallel development ran up against some shortcomings
in our process.

Our release cycle is once every two weeks. We plan our work into two-week
sprints, and a feature isn't considered "done" until it is accepted by the
product owner *and* actually released to production. The problem we ran into
was that—on occasion—a feature planned for a sprint would not be accepted in
time for that sprints's production deployment. This caused problems putting
together the production release. For example, let's say the team worked on
Feature A and Feature B during the sprint. Feature A gets accepted and is
ready to release, but there are some issues with Feature B that mean we are
not going to put it in production this time around. Since we worked on both
features at the same time, the commit log on the master branch contained a mix
of commits for both features and looked like:

  * A
  * A
  * B
  * A
  * B
  * A
  * A
  * B
  * B

When it came time to put together the release, we only wanted to take the
commits for the accepted feature and merge them into the production branch. This
meant that someone would have to go through the commit logs, find the relevant
commits, and cherry-pick them into production one at a time. First problem:
that's a mind-numbing chore for whoever is tasked with it.

Now imagine that—even if there are no inherent dependencies between Feature A
and Feature B—there are changes made in one of the early commits for Feature B
to a commonly used area of the code. Then, in the further work on Feature A,
the code is written in such a way that depends on this new behavior added by
Feature B's commits. Not a problem if both features get approved for the
release, but it does become an issue when only Feature A makes it to
production. At that point, the person tasked with putting together the
production branch ends up with failing tests and—possibly—a merge conflict.
It's especially fun when that person didn't actually work on the changes
involved.

That's bad enough; but it gets worse. It's not as if we stop working on
Feature B just because it doesn't get accepted for this release. The people
working on it continue to do so, and the est of the team starts work on
Feature C. By the end of the sprint, we have a commit log on the master branch
that looks something like:

  * A
  * A
  * B
  * A
  * B
  * A
  * A
  * B
  * B
  * C
  * B
  * C
  * B
  * B
  * C
  * C

Luckily, both B and C get accepted this sprint, so we can cherry-pick both of
these into production, and everything should be fine, right?

Well, the production branch now looks like this:

  * A
  * A
  * A
  * A
  * A
  * B
  * B
  * B
  * B
  * C
  * B
  * C
  * B
  * B
  * C
  * C

Notice an issue there? The production branch contains all of the same commits
as the master branch, but now they are applied in a different order. In
practice, this led to some *very interesting* merge conflicts. In
some cases, it didn't lead to conflicts that git was able to detect, but it
caused some defects to appear in production that were not present during our
internal acceptance process (performed against the master branch).

After a couple of "releases from hell", it was apparent to the whole team
that this was a problem that we needed to solve. We put our heads together and
came up with a solution that has been working great for us in the several
months since adopting it.

The first change is that we no longer have the whole team committing
work-in-progress to master. Whereas we used to have a master branch that
contained the main line of development and a production branch that only
contained work that was in (or ready to go to) production, we decided to turn
that on it's head a bit. We made the decision that the master branch wasn't
really all that important, and that the production branch was the most
critical part of the system. Regardless of what undeployed work might be in
commits on the master branch, the production branch is what is "real" and
"permanent". If you want to keep feature development independent from work on
other features, the production branch is the one thing you can rely on not
changing prior to the next production release.

Now, that's all well and good, but I'd have to cut a corner off my agile
practitioner's card if I suggested that we based each feature off of the
production branch and didn't integrate them until the end of the sprint.
On the other hand, we don't want to change the production branch until we're
ready for a release (in case we need to push out an emergency, mid-cycle
release to fix a critical defect.)

The challenge was to come up with a workflow that would protect the "actually
in production" nature of the production branch while making sure we didn't
fall into the trap of "big bang integration" at the end of the sprint.
In order to meet these goals, at the beginning of every sprint we
create a new branch based off of the production branch called sprint-N (where
N is the number of that sprint). Each feature that is being worked on during
that sprint also gets its own branch, and the feature branch is based off of the
sprint branch.

When a feature is ready for acceptance, the developer in charge of the feature
will deploy the code from our feature branch to the alpha environment for the
product owner to review. The product owner is able to review that feature in
isolation from all of the other work in progress. This gives him confidence
that—even if this were the only thing we got done this sprint—it would behave
the same way in production.

If the product owner rejects the feature, the developers go back to working on
it, and no other features are directly impacted. If the product owner accepts
the feature, then and only then does the feature branch get merged into the
sprint branch (we use `git merge --squash` so that the changes for the feature
show up as a single commit in the sprint branch). After the changes are merged
in, the rest of the team is notified that the sprint branch has been updated,
and all other in-progress feature branches are rebased onto the new HEAD of
the sprint branch. (For those not familiar with git, rebasing—in layman's
terms—means rewriting history such that all of the commits made only to the
feature branch will be applied *after* any changes that appear on the sprint
branch, regardless of the actual chronological order of those commits.)

With this system, we make sure that no feature has any unintentional
dependencies on work that may not be accepted, because the sprint branch
*only* contains code that is actually in production plus already accepted work
that will go out in the next release. At the same time, because changes are
merged into the sprint branch as soon as they are accepted, we are able to
test integration at the earliest practical point in time. When the developers
working on other features rebase their branches onto the new sprint branch,
they deal with any actual or semantic merge issues at that time. That way, the
people most familiar with the changes are able to resolve the conflicts while
those changes are still fresh in their minds.

We use TeamCity to run our automated, continuous integration. TeamCity runs
tests whenever it detects changes to either the sprint branch or the
production branch. Additionally, we can easily clone the build configuration
and have it run against the branch for a particular feature. We don't do so
for every feature, but we use that capability for larger features that need to
integrate the work of multiple pair-programming teams.

When the end of the sprint arrives, updating the production branch is as
simple as `git checkout production && git merge sprint-N`. Since the sprint
branch was created directly from the production branch and only contains
accepted work, this is always a simple, fast-forward merge. We tag the
production branch with the release number and deploy that to our staging
environment for a final once-over before delivering to production.
