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

There's a pattern I've noticed among developers working with AI coding assistants. Some are having transformative experiences—shipping features faster, tackling problems they'd previously avoided, genuinely enjoying their work more. Others are frustrated, producing buggy code, and increasingly skeptical that these tools offer anything beyond fancy autocomplete.

The difference isn't the model they're using. It's not their prompting technique. It's not even their underlying programming skill, though that certainly matters.

The developers succeeding with LLM-augmented development have stopped waiting for the perfect out-of-the-box experience and started building their own tools to solve their own problems.

# The Myth of the Perfect Configuration

When Claude Code, Cursor, Windsurf, and similar tools started gaining traction, a cottage industry of "optimal configurations" emerged. GitHub repositories full of system prompts. Blog posts about the "ultimate" rules file. YouTube videos promising 10x productivity if you just copy these exact settings.

I tried many of them. Some helped marginally. Most did nothing. A few actively made things worse because they were optimized for someone else's workflow, someone else's codebase, someone else's pain points.

This shouldn't have surprised me. I've spent two decades watching the same pattern play out with every development tool and methodology. Cargo-culting someone else's Agile process doesn't make you agile. Copying another team's CI/CD pipeline doesn't give you their deployment confidence. Using the same text editor as a famous programmer doesn't make you write better code.

The tool is never the thing. The thing is understanding your own problems deeply enough to know what tool you need.

# A Problem Worth Solving

I'd been using Claude Code heavily for several months, and one friction point kept recurring: GitHub issue management.

Not the basic stuff—creating issues, closing them, adding labels. The `gh` CLI handles that fine, and Claude can drive it without much trouble. The friction was in the relationships between issues.

I work with hierarchical issue structures. Epics contain stories. Stories contain tasks. Tasks might have sub-tasks. When you're trying to keep Claude oriented on what you're building and why, being able to say "this task is part of story #42, which is part of epic #15, which is about the payment system redesign" provides crucial context.

GitHub added sub-issues and blocking relationships over the past year, but they're only accessible through the web UI or the GraphQL API. Every time I needed Claude to help me restructure issue hierarchies or track dependencies, we'd end up in a frustrating dance: Claude would attempt some `gh api graphql` call, get the syntax wrong, try again, get the escaping wrong, try again, finally succeed, and by then I'd lost my train of thought on the actual problem I was trying to solve.

Worse, if I wanted to grant Claude permission to manage issues autonomously, I'd have to approve `Bash(gh api:*)` in my settings—which is far too broad. That pattern would let Claude make arbitrary API calls to GitHub, not just issue management operations.

I could have lived with this friction. Most people do. They work around limitations, accept the rough edges, wait for someone else to build a better solution.

Instead, I decided to build the tool I needed.

# The Development Process (With an AI Partner)

Here's where things get interesting. I didn't just sit down and write a GitHub CLI extension from scratch. I used Claude Code to help me build the tool that would make Claude Code more effective.

The process started with research. I asked Claude to investigate the GitHub GraphQL API, find the relevant mutations for sub-issues and blocking relationships, and figure out what operations were possible. This took some trial and error—we created test issues, experimented with API calls, discovered that sub-issues require a special `GraphQL-Features: sub_issues` header, learned that blocking relationships use `issueId` and `blockingIssueId` parameters (not the more intuitive names I initially guessed).

Every failed API call taught us something. Every error message refined our understanding. Claude kept notes, I asked questions, and gradually a clear picture emerged of what was possible and what syntax was required.

Then came the key insight: we could wrap all these GraphQL operations in a `gh` CLI extension. Instead of Claude needing to construct complex API calls every time, it could use simple commands like `gh issue-ext sub add 10 42`. And critically, I could grant permission for `Bash(gh issue-ext:*)` without opening the door to arbitrary API access.

The extension itself took maybe 20 minutes to write—a bash script that handles argument parsing, constructs the appropriate GraphQL queries, and presents results in both human-readable and JSON formats. Claude did most of the implementation work while I reviewed, asked questions, and occasionally corrected course.

But the extension was only half the solution. I also needed Claude to *know* how to use it effectively. So we built a Claude Code plugin: a skill document that teaches Claude about GitHub issue management, comprehensive reference documentation for every command, a setup command that installs the extension, and a session-start hook that reminds users if they haven't installed the extension yet.

The whole thing—research, experimentation, extension development, plugin creation, documentation—took an hour. And now I have a tool that solves my specific problem in exactly the way I need it solved.

# Why This Matters

Let me be clear about something: the plugin I built isn't revolutionary. It's a wrapper around existing APIs with some documentation. Anyone could have built it.

But almost no one does.

Most developers treat their AI coding tools as fixed artifacts. The tool does what it does; your job is to figure out how to work within its constraints. If something is frustrating, you either live with it or switch to a different tool and hope it's better.

This mindset made sense when tools were expensive to modify. Writing an IDE plugin used to be a significant undertaking. Customizing your build system required deep expertise. The cost of building your own tools was high enough that it was usually better to adapt your workflow to existing solutions.

But that equation has changed. When you have an AI assistant that can help you build tools, the cost of custom solutions drops dramatically. That time I spent building the GitHub issue extension? I couldn't have done it that quickly five years ago. The research alone would have taken longer than the entire project did with Claude's help.

This creates a flywheel effect. You use AI to build tools. Better tools make your AI assistant more effective. A more effective AI assistant helps you build better tools faster. Each iteration compounds.

# The Meta-Skill

The developers I see thriving with AI coding assistants have developed a specific meta-skill: they notice friction, investigate root causes, and build solutions—rather than accepting friction as the cost of using new technology.

This requires a particular mindset:

**Treat configuration as code.** Your rules files, system prompts, custom commands, and plugins are part of your development environment. They deserve the same attention you'd give any other code you maintain. Version control them. Iterate on them. Share them when they might help others, but don't expect others' configurations to solve your problems.

**Pay attention to repeated friction.** Every time you find yourself working around a limitation, every time Claude makes the same mistake twice, every time you have to manually intervene in something that should be automatic—that's a signal. You've found a problem worth solving.

**Invest in understanding.** Before building a solution, make sure you understand the problem deeply. My GitHub issue extension works because I spent time learning exactly how the GraphQL API behaves, what parameters it expects, what errors it returns. That understanding is embedded in the tool and the documentation.

**Build incrementally.** You don't need to solve everything at once. I started with just sub-issue management because that was my most pressing pain point. Blocking relationships and linked branches came later. Each addition was motivated by a real problem I'd encountered.

**Document for your AI partner.** Half of building effective tooling is teaching your AI assistant how to use it. The skill documentation I wrote for Claude isn't just for human readers—it's optimized for Claude to consume and apply. Clear examples, explicit command syntax, common patterns and workflows.

# The Uncomfortable Truth

There's an uncomfortable truth in all of this: the people who benefit most from AI coding assistants are the people who needed them least.

Experienced developers who already understand their problem domains deeply can direct AI assistants effectively. They know what questions to ask. They can evaluate generated solutions. They can identify when the AI is confidently wrong. And crucially, they have the skills to build custom tools when off-the-shelf solutions fall short.

Less experienced developers often struggle because they're trying to use AI assistants as a shortcut past understanding. They want the tool to just work, to give them correct answers without requiring them to evaluate those answers critically. When friction appears, they lack the context to even recognize that a solution might exist.

I don't have a neat resolution for this tension. AI coding tools genuinely do lower the barrier to building software. But they lower it most for people who've already climbed over that barrier.

Perhaps the best thing experienced developers can do is model this tool-building behavior openly. When you solve a problem by building a custom extension or plugin, share not just the artifact but the process. Show how you identified the friction, how you investigated solutions, how you iterated toward something that worked.

The tools we build are artifacts of our understanding. Sharing them helps. But sharing how we built them helps more.

# Getting Started

If you've read this far and want to try building your own Claude Code tooling, here's what I'd suggest:

**Start with your actual problems.** Don't go looking for things to optimize. Instead, pay attention over the next week. When do you feel friction? When does Claude struggle with something that should be straightforward? Write these down.

**Pick the smallest valuable problem.** You don't need to build a comprehensive solution. Find something specific and bounded. Maybe it's a single command that automates a repetitive task. Maybe it's a snippet of documentation that helps Claude understand your project's conventions.

**Use Claude to build it.** This is genuinely effective. Describe the problem you're trying to solve, work through potential solutions, iterate until you have something that works. You'll learn about Claude's capabilities and limitations in the process.

**Test it in real work.** The best tools emerge from actual use. Build something minimal, use it for a few days, notice what's missing or awkward, improve it.

**Share what you learn.** Not just the finished tool—the process, the problems, the failed approaches. Someone else has the same friction you do. They might not have realized yet that building a solution is possible.

---

The GitHub issue management plugin I built is available at [https://github.com/jwilger/claude-code-plugins](https://github.com/jwilger/claude-code-plugins), and the gh extension is at [https://github.com/jwilger/gh-issue-ext](https://github.com/jwilger/gh-issue-ext). You're welcome to use them if they solve problems you have.

But more than that, I hope this piece encourages you to notice your own friction and do something about it. The tools you build for yourself will always fit better than the tools you borrow from others.
