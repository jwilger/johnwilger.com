+++
title = "Production Release Workflow with Git"
description = "Transforming a painful multi-hour release process into a five-minute, low-stress workflow using Git branching strategies."
slug = "production-release-workflow-with-git"
date = 2011-01-08

[extra]
cover = "https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?w=800&q=80"

+++

After the [ProjectDX](http://www.projectdx.com) team grew from three software developers to eight, putting a release together became a two-to-three-hour job, and even then some defects got through to production. The trouble came from having several features in progress at once on one shared branch, when a given release would contain only some of them. A few changes to how we develop and accept work turned the release into a five-minute, low-stress task.

<!-- more -->

A couple of years ago the team was much smaller. About three full-time developers worked on the code. We all committed work in progress to the master branch of our [git](http://git-scm.com/) repository and pushed those commits when we had a set that made sense to share. With so few of us, we were usually working on one feature at a time, and once a small number of features had been accepted, we released them to production. That worked well. When we did have a merge conflict, we all knew enough about what was being worked on to sort it out.

In 2010, the ProjectDX team was acquired by [Renewable Funding](http://www.renewfund.com), which gave us both the resources and the need to grow. I took over management of the software development team. Within several months I had hired three new developers and was adding two or three contract developers at any given time. Tripling a team in six months brings some challenges, and one of ours was that the flow of work through the system had to change.

At first we changed nothing, because I prefer not to change things before I know what the real problems are. Developers still committed to master, and our automated CI system deployed that branch to our internal alpha server whenever all the tests passed. When the developers on a feature thought it was complete, they put it up for acceptance, and the product owner verified it on alpha and accepted or rejected the work. With more capacity, though, more features were in progress at any given time, and that parallel development exposed some shortcomings in the process.

## Why releases became painful

We release every two weeks. We plan our work in two-week sprints, and a feature isn't "done" until the product owner has accepted it and it has been released to production. Occasionally a feature planned for a sprint wasn't accepted in time for that sprint's deployment, and that made the release hard to assemble. Say the team worked on Feature A and Feature B during the sprint. Feature A is accepted and ready to release. Feature B has some issues, and we aren't going to put it in production this time. Because both were worked on at the same time, the commit log on master mixed the two:

  * A
  * A
  * B
  * A
  * B
  * A
  * A
  * B
  * B

For the release, we wanted only the commits for the accepted feature merged into the production branch. Someone had to go through the log, find the relevant commits, and cherry-pick them into production one at a time, which is a mind-numbing chore.

It could also fail. Suppose Features A and B have no inherent dependency on each other, but one of the early commits for Feature B changes a commonly used area of the code, and later work on Feature A is written in a way that depends on the new behavior. That's no problem when both features are approved for the release. When only Feature A goes to production, the person assembling the production branch gets failing tests and possibly a merge conflict, and often that person didn't work on the changes involved.

It got worse in the following sprint. Work on Feature B doesn't stop because it missed a release. The people on it carry on, and the rest of the team starts Feature C. By the end of the sprint, the commit log on master looks something like this:

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

Both B and C are accepted this sprint, so we cherry-pick both into production. The production branch now looks like this:

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

The production branch contains the same commits as master, applied in a different order. In practice this produced some very difficult merge conflicts. In other cases there was no conflict that git could detect, and defects appeared in production that hadn't been present during our internal acceptance process, which was performed against master.

## A branch for each sprint

After a couple of releases like that, the whole team could see the problem had to be solved. We worked out a solution together, and it has served us well in the several months since we adopted it.

The first change was that the whole team no longer commits work in progress to master. We used to have a master branch with the main line of development and a production branch containing only work that was in production or ready to go. We turned that around. We decided that master wasn't very important and that the production branch was the most critical part of the system. Whatever undeployed work sits in commits elsewhere, the production branch is what's real and permanent. If you want to keep work on one feature independent of work on the others, the production branch is the one thing you can rely on not to change before the next release.

Basing every feature on the production branch and integrating them only at the end of the sprint would be big-bang integration, though, and I couldn't recommend that. We also didn't want to change the production branch before we were ready to release, in case we needed an emergency release in the middle of a cycle to fix a critical defect.

So the workflow had to keep the production branch an accurate record of what's in production and still integrate work throughout the sprint. At the beginning of every sprint, we create a new branch from production called sprint-N, where N is the number of the sprint. Each feature worked on during the sprint gets its own branch, based on the sprint branch.

When a feature is ready for acceptance, the developer in charge of it deploys the feature branch to the alpha environment for the product owner to review. The product owner sees that feature in isolation from all other work in progress. He can be confident that it would behave the same way in production if it were the only thing we finished that sprint.

If the product owner rejects the feature, the developers go back to work on it, and no other feature is directly affected. If he accepts it, then and only then is the feature branch merged into the sprint branch. We use `git merge --squash`, so the feature's changes appear in the sprint branch as a single commit. The rest of the team is told that the sprint branch has been updated, and every other in-progress feature branch is rebased onto the new HEAD of the sprint branch. For those unfamiliar with git, rebasing means rewriting history so that the commits made only on the feature branch are applied after any changes on the sprint branch, whatever the chronological order of those commits.

Under this system, no feature has an unintended dependency on work that may not be accepted, because the sprint branch contains only code that is in production plus accepted work that will go out in the next release. And because changes are merged into the sprint branch as soon as they're accepted, integration is tested at the earliest practical point. Developers on other features deal with any merge problems, textual or semantic, when they rebase onto the new sprint branch. The people most familiar with the changes resolve the conflicts while those changes are still fresh in their minds.

We use TeamCity for automated continuous integration. It runs the tests whenever it detects changes on the sprint branch or the production branch. We can also clone the build configuration and point it at the branch for a particular feature. We don't do that for every feature, but we use it for larger ones that combine the work of several pair-programming teams.

At the end of the sprint, updating the production branch is `git checkout production && git merge sprint-N`. Because the sprint branch was created directly from production and contains only accepted work, this is always a simple fast-forward merge. We tag the production branch with the release number and deploy it to our staging environment for a final check before delivering to production.
