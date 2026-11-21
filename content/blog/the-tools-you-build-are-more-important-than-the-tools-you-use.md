+++
title = "The Tools You Build Are More Important Than The Tools You Use"
description = "Why developers succeeding with AI coding assistants stop searching for perfect configurations and start building their own tools."
slug = "the-tools-you-build-are-more-important-than-the-tools-you-use"
date = 2025-12-29
[extra]
cover = "https://cdn.hashnode.com/res/hashnode/image/stock/unsplash/MCnzt2Udz_w/upload/e77fa8491d088ac1481652a88dfa65f7.jpeg"

[taxonomies]
tags = ["ai", "plugins", "llm", "claude-code"]
+++

Among the engineers I know who use AI coding assistants, some are shipping more, taking on problems they used to avoid, and enjoying the work more than they did. Others are producing buggy code and have concluded that the tools are little more than autocomplete. A manager is likely to have both kinds on the same team, using the same product.

The difference I see between them isn't the model or the prompting technique, and it isn't programming skill alone, though skill matters. The engineers getting results have stopped waiting for the tool to work well as delivered and have started building tools of their own for their own problems.

When Claude Code, Cursor, Windsurf, and similar tools gained traction, a supply of "optimal configurations" appeared with them: repositories of system prompts, posts about the ultimate rules file, videos promising large gains to anyone who copied a particular set of settings. I tried many of them. Some helped a little, most did nothing, and a few made things worse, because they had been tuned for someone else's workflow, codebase, and problems.

I've watched the same thing happen for two decades with other tools and methods. Copying another team's Agile process doesn't make a team agile. Copying another team's deployment pipeline doesn't produce that team's confidence in deploying. A tool helps when it fits a problem you understand well enough to say what you need.

## One problem and one hour

I'd been using Claude Code heavily for several months, and one source of friction kept coming back, which was managing GitHub issues. Creating issues, closing them, and adding labels was fine. GitHub's `gh` command-line tool handles those, and Claude can drive it without much trouble. The friction was in the relationships between issues.

I organize work in a hierarchy. Epics contain stories, stories contain tasks, and tasks sometimes have sub-tasks. That structure keeps an assistant oriented. Telling Claude that a task is part of story #42, which is part of epic #15, which is the payment system redesign, gives it the context to know what it's building and why.

GitHub had added sub-issues and blocking relationships over the previous year, but they were available only through the web interface and the GraphQL API. Each time I asked Claude to restructure a hierarchy or track a dependency, it would attempt a `gh api graphql` call, get the syntax wrong, try again, get the escaping wrong, try again, and eventually succeed, by which time I'd lost track of the problem I was working on.

There was a permissions problem as well. To let Claude manage issues without asking me each time, I'd have had to approve `Bash(gh api:*)` in my settings. That pattern allows any API call to GitHub, far more than issue management.

I could have lived with this, as most people live with the rough edges of their tools while waiting for someone to build something better. I built the tool I needed, and I used Claude Code to help build it.

We started with research. I asked Claude to investigate the GraphQL API, find the operations for sub-issues and blocking relationships, and establish what was possible. That took trial and error. We created test issues and experimented with calls. We found that sub-issues require a special `GraphQL-Features: sub_issues` header, and that blocking relationships take parameters named `issueId` and `blockingIssueId`, which weren't the names I'd guessed. Each failed call and each error message narrowed things down. Claude kept notes and I asked questions until we knew what was possible and what syntax it required.

All of those operations could be wrapped in an extension to `gh`. Claude would no longer construct a complex API call each time. It would run a simple command such as `gh issue-ext sub add 10 42`. I could also grant permission for `Bash(gh issue-ext:*)`, which covers issue management and nothing else.

The extension took about twenty minutes to write. It's a bash script that parses arguments, constructs the GraphQL queries, and presents results both in readable form and as JSON. Claude did most of the implementation while I reviewed it, asked questions, and occasionally corrected its course.

The extension was half of the solution, because Claude also had to know how to use it. So we built a Claude Code plugin: a skill document that teaches Claude about GitHub issue management, reference documentation for each command, a setup command that installs the extension, and a hook that runs at the start of a session and reminds the user if the extension isn't installed. The plugin is in my [claude-code-plugins repository](https://github.com/jwilger/claude-code-plugins), and the extension is [gh-issue-ext](https://github.com/jwilger/gh-issue-ext).

Research, experiments, the extension, the plugin, and the documentation took an hour in total.

## Why an hour matters

The plugin is a wrapper around existing APIs with some documentation, and anyone could have built it. Few people build things like it, because most of us treat our tools as fixed. The tool does what it does, and the job is to work within its constraints. When something is frustrating, we put up with it or switch tools and hope the next one is better.

That attitude made sense when tools were expensive to modify. Writing an IDE plugin was a significant undertaking, and customizing a build system took deep expertise. Adapting the workflow to the tool was usually the cheaper course.

It's no longer the cheaper course. With an assistant that can help build tools, the cost of a custom one has fallen a long way. I couldn't have built the issue extension that quickly five years earlier. The research alone would have taken longer than the whole project took with Claude's help. The gains also build on each other, since a better tool makes the assistant more effective, and a more effective assistant makes the next tool quicker to build.

The engineers doing well have made a habit of this. They notice friction, find its cause, and build something, where others accept friction as the price of new technology. The habit has a few parts.

They treat configuration as code. Rules files, system prompts, custom commands, and plugins are part of the development environment and deserve the attention given to any other code a team maintains. They're kept in version control and revised. They're shared when they might help someone else, without any expectation that another person's configuration will solve your problems.

They pay attention to repetition. Working around the same limitation again, watching the assistant make the same mistake twice, and stepping in by hand where something should be automatic are all signs of a problem worth solving. The way to find them is to write down each point of friction for a week and then choose the smallest one with real value, such as a single command that automates a repetitive task or a short document that explains a project's conventions.

They understand the problem before building. My extension works because I spent the time to learn how the API behaves, what parameters it expects, and what errors it returns. That understanding is built into the tool and its documentation.

They build in increments and test in real work. I started with sub-issues because that was the most pressing need. Blocking relationships and linked branches came later, each prompted by a problem I'd run into. A minimal tool used for a few days shows what's missing or awkward.

They document for the assistant. Half the work of effective tooling is teaching the assistant to use it. The skill document I wrote for Claude is written for Claude to read and apply, with clear examples, explicit command syntax, and common workflows.

There's a consequence in this that I find uncomfortable. The people who benefit most from AI coding assistants are the people who needed them least. Experienced engineers who understand their problem domain can direct an assistant well. They know what to ask, they can evaluate what comes back, they can tell when the assistant is confidently wrong, and they have the skill to build a tool when the delivered one falls short. Less experienced engineers often struggle because they're using the assistant as a way around understanding. They want correct answers without having to evaluate them, and when friction appears they lack the context to see that a solution might exist. These tools do lower the barrier to building software, but they lower it most for people who are already over it.

I don't have a resolution for that. The most useful thing experienced engineers can do is build their tools in the open and share how they did it along with the result: how they noticed the friction, how they investigated it, and how they got to something that worked. Someone else has the same friction and may not have realized that building a solution is possible.

For a team, the same reasoning says where the effort should go. Searching for a better configuration is a search for someone else's solution to someone else's problem. Time given to the people who know the team's own friction, to build tools that remove it, buys something that fits.
