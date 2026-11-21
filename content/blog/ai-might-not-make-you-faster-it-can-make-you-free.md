+++
title = "AI Might Not Make You Faster. It Can Make You Free."
description = "Speed is the wrong metric for AI-assisted development. With real guardrails, the win is higher-quality work and attention you get to spend somewhere else."
slug = "ai-might-not-make-you-faster-it-can-make-you-free"
date = 2026-07-10

[extra]
cover = "/images/blog/ai-wont-make-you-faster-cover.png"

[taxonomies]
tags = ["ai", "llm", "software-engineering", "productivity", "workflow"]
+++

If you've approved a budget for AI coding tools, the case made to you was probably about speed: more features shipped, more tickets closed, more output from each engineer. I've built my daily work around coding agents for the past year and a half, and speed isn't what I got. For a single, well-defined piece of work, my agent-assisted process takes about as long as doing the work myself, and sometimes longer. What I got was better software and most of my attention back. A company that judges these tools by speed is likely to miss both.

I haven't timed myself, so that comparison is an impression. METR has done the measuring. In a [randomized trial in mid-2025](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/), experienced open-source developers working in their own repositories were about 19% slower with AI tools, and estimated afterward that they'd been about 20% faster. The gap between those two numbers has a plain cause. Text streams onto the screen within seconds, so the work feels fast, and few people go back to check when it was finished.

My time goes into the things I'd require of a human engineer, which I don't skip because a machine is doing them. In my [ai-plugins setup](https://github.com/jwilger/ai-plugins), the agent writes a failing test before it writes the code, debugs by forming a hypothesis and trying to disprove it, and can't report work as done without running the verification it claims to have run. On top of that sit the checks I'd want on any team: strict lints, mutation testing where the stack supports it (the code is broken on purpose to see whether the tests notice), written records of decisions that will outlive the branch, and a review before anything is called ready. None of that is fast when people do it, either.

## Quality depends on the checks

The standard complaint about AI-written code is that it's verbose, subtly wrong, untested, and incoherent in its design. That describes what you get by accepting the first thing a model produces. With the checks in place, the code that comes out of my agent workflow is regularly better than what I'd write by hand, and better than what most teams I've worked with typically ship. The model isn't smarter than those teams. The agent does the disciplined work on every change and doesn't tire of it.

People do tire of it. By the fifteenth pull request of the week, the failing test doesn't always get written first, the mutation suite doesn't always run before review, and the decision that should have been recorded lives in a Slack thread that will expire. We negotiate with discipline when we're tired or behind. An agent whose discipline is enforced by checks it can't get past has nothing to negotiate with. It writes the property test, chases the mutation the tests missed, updates the decision record, and runs a fourth review pass.

The quality of the result is set by the checks you build more than by the model. Most teams haven't built enough of them, and they blame the model for what comes out.

## Why the first answer is tempting

Steve Yegge described [the interface as a slot machine](https://sourcegraph.com/blog/the-brute-squad): each request is a pull of the lever, with potentially unlimited upside or downside. You type a prompt, and within seconds something that looks like working software appears. The loop teaches you to value the moment code appears over the moment the work is done, and those two moments can be hours apart.

![A retro slot machine with code symbols on its reels spilling a jackpot of glowing characters into a tray, while a hand reaches eagerly for the lever.](/images/blog/ai-wont-make-you-faster-slot-machine.png)

Waiting through those hours is the hard part. While my agent writes tests, watches them fail, makes them pass, works through the mutation suite, and reviews its own diff, it doesn't need me. The work is happening, but it feels as though I'm doing nothing, because like most engineers I've spent a career learning to equate time at the keyboard with productivity. The urge that follows is to start a second piece of work, and then a third, until the feeling of idleness goes away.

Those hours are also when the costs arrive. In [March 2025](/blog/the-hidden-pitfalls-of-ai-software-development/) I was sitting alone at a restaurant table, waiting for my wife to join me for date night, when Google emailed to thank me for my payments: just under $2,000 in Places API fees, run up earlier that day by a utility an agent had built for me. The code wasn't wrong. I'd reviewed it, understood it, and watched the tests pass. What I'd skipped was the slower engineering around it, such as reading the pricing page for the API tier that two harmless-looking output fields had moved me into. No check I had in place forced that review, and the agent wasn't going to volunteer it. It was my own money and not a client's, though the engineer is responsible either way. My wife arrived to find me staring at my phone, and explaining the number on it didn't improve the evening. The code had arrived quickly, and the engineering hadn't been done yet.

The people who tell me AI coding produces garbage are usually describing a workflow in which output is accepted at the moment it's generated. Letting the whole process finish, even when it takes as long as doing the work by hand, is the skill that matters, and it's rarer than skill at writing prompts.

## What the hours are for

A piece of work takes as long as it did, or longer, and comes out better. What changes is where the engineer is while it happens. The agent needs a person at the edges, to define the problem, make the architectural decisions, and review the result. It doesn't need one in the middle, and the middle is most of the hours.

One use for those hours is more work. A single person can run several tracks in parallel, and I've done it: one agent [shepherding a pull request through CI and review](https://github.com/jwilger/ai-plugins), another on a feature branch in its own working copy, and me doing design work on a third thing. The volume is real. I've never been more prolific on the side projects I care about, including [eventcore](https://github.com/jwilger/eventcore), [auto_review](https://github.com/jwilger/auto_review), and [a number of others](/projects/) that would have stayed in a notes file for lack of nights and weekends.

Parallelism also rebuilds the slot machine one level up. With three tracks running, one of them is always worth checking. The checking crept into my evenings, and the work that crept was those same side projects. I've caught myself looking at agent progress on my phone at dinner the way other people look at markets. Someone who becomes a fourteen-hour-a-day supervisor of agents has automated the work and doubled the job.

The other use is to spend the hours on something else. An agent can turn an idea and an architecture into working, tested, reviewed software over an afternoon, and it doesn't need to be watched. You can go for a walk, cook dinner, or pick your kid up from school without a laptop in the car. The work finishes to a higher standard than a rushed afternoon at the keyboard would have reached. This is the harder choice, because the habit that makes waiting feel like slacking argues against it. The best version of the job now involves not watching, and the instincts I built over twenty-plus years say that can't be right.

Since I stopped treating the middle hours as a gap to fill with more work, I've been learning to play the violin. A new piece or a new technique takes my full attention, so I don't attempt those while agents are running. Technique practice, meaning scales, drills, and bowing exercises, fits in the gaps, and there are hours of it to do. Listening for intonation and building muscle memory don't compete with reading agent output or thinking about product and architecture, so I can practice and still notice when a check fails or a decision needs a person. My hands are too busy to start another track of work, which turned out to be what I needed to stop the habit of making code all day, every day, that had begun to set in.

None of this happens by default. The discipline has to be enforced by checks the agent can't skip: a test before the code, verification before any claim that work is done, and a real review. Instructions an agent can talk its way past don't count, and [plenty of guardrails don't change behavior](/blog/coding-harness-plugins-are-agentic-systems/) when someone tests them. The workflow has to be judged by finished work and not by how quickly code appears on a screen. And what the freed hours are for has to be decided on purpose, by engineers and by the people who manage them, because the default answer is more parallel work, and that leads back to the fourteen-hour day.
