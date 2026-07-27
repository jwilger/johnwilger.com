+++
title = "AI Might Not Make You Faster. It Can Make You Free."
description = "Speed is the wrong metric for AI-assisted development. With real guardrails, the win is higher-quality work and attention you get to spend somewhere else."
slug = "ai-might-not-make-you-faster-it-can-make-you-free"
date = 2026-07-10

[extra]
cover = "/images/blog/ai-wont-make-you-faster-cover.png"

[extra.narration]
src = "/audio/blog/ai-might-not-make-you-faster-it-can-make-you-free.mp3"
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

[taxonomies]
tags = ["ai", "llm", "software-engineering", "productivity", "workflow"]
+++

Every pitch for AI-assisted development leads with speed. Ship faster, close more tickets, multiply your output. I've spent the past year and a half building my daily workflow around coding agents, and speed isn't what I got out of the deal. Some days I doubt I got any. What I got back was my attention, and it took me longer than I'd like to admit to notice that was the better prize.

## Nobody checks the stopwatch

For a single, well-defined unit of work, my agent-assisted workflow takes about as long as doing the work myself. Sometimes longer. I haven't timed myself rigorously, so take that as an honest impression rather than data. METR did the rigorous version: a [randomized trial in mid-2025](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) where experienced open-source developers working in their own repositories were about 19% *slower* with AI tools, while estimating afterward that they'd been about 20% faster. Tokens stream onto the screen instantly, so the whole thing feels fast. Whether the work actually finished sooner is a different question, and almost nobody goes back and checks the clock.

I know where my time goes, because I make the agent do everything I'd demand from a human engineer, and I refuse to skip steps just because a machine is doing them. In my [ai-plugins setup](https://github.com/jwilger/ai-plugins), the agent works test-first, debugs by forming and falsifying hypotheses instead of pattern-matching a fix, and can't claim work is done without running the verification it's claiming. The engineering-standards rules add the gates I'd want on any team: strict lints, mutation testing where the stack supports it, ADRs for decisions that will outlive the branch, a real review pass before anything gets called ready.

None of that is fast. It isn't fast when humans do it either. We just already knew that about humans.

## Slop is a choice

The standard complaint about AI code — verbose, subtly wrong, untested, architecturally incoherent — describes what you get when you accept the first thing the model produces. It doesn't describe a ceiling.

With those gates in place, the code coming out of my agent workflow is regularly better than what I'd produce by hand, and better than what most teams I've worked with typically ship. Not because the model is smarter than the team. Because the agent actually does the discipline, every time, without getting tired of it.

Be honest about your own team for a second. By the fifteenth PR of the week, does every change still get a failing test written first? Does anyone still run the mutation suite before review? Does the ADR get written, or does the decision live in a Slack thread that expires? Humans negotiate with discipline when we're tired or behind. An agent with the discipline encoded as hard gates doesn't negotiate. It will write the property test, chase the surviving mutant, update the ADR, and run a fourth review pass, because tedium isn't something it experiences. (Though it will occasionally *claim* otherwise. Claude Code has told me, with a straight face, that it wasn't going to bother with something "due to time constraints" — despite having no clock, no deadline, and no meeting to get to. That's not tedium. That's a training set full of humans who've said the same thing to get out of writing one more test. Brilliant!)

The quality ceiling is set by the guardrails you build, not by the model. Most teams haven't built these up sufficiently, and then blame the model for the slop.

## The slot machine

So if better-than-usual quality is on the table, why is so much AI-assisted code garbage?

Because [the interface is a slot machine](https://sourcegraph.com/blog/the-brute-squad), as Steve Yegge put it: each request a pull of the lever with potentially infinite upside or downside. Type a prompt, tokens pour out, something that looks like working software materializes in seconds. Pull the lever, get a reward, pull again. The loop trains you to value the moment code appears instead of the moment work is done, and those two moments can be hours apart.

![A retro slot machine with code symbols on its reels spilling a jackpot of glowing characters into a tray, while a hand reaches eagerly for the lever.](/images/blog/ai-wont-make-you-faster-slot-machine.png)

The waiting is the hard part, and not for the reason I expected. When my agent picks up a task, there's a long stretch where it's writing tests, watching them fail, making them pass, fighting the mutation suite, reviewing its own diff. It doesn't need me for any of that. The work is happening — but it *feels* like I'm not doing anything, because like most of us I've spent my whole career being trained to equate time at the keyboard with productivity. My brain refuses to count work it can see happening if my hands aren't the ones doing it. And the reflex that itch produces isn't to interrupt the agent. It's to pull another lever: spin up a second track of work, then a third, until the feeling of idleness goes away.

The gap between code appearing and work being done is where the machine collects. In [March 2025](/blog/the-hidden-pitfalls-of-ai-software-development/) I was sitting alone at a restaurant table, waiting for my wife to join me for date night, when Google emailed to thank me for my payments. Just under $2,000 in Places API fees, run up earlier that day by an agent-built utility. The code wasn't wrong. I'd reviewed it, understood it, watched the tests pass. What I'd skipped was the slower engineering around it, like reading the pricing page for the API tier that two innocent-looking output fields had quietly bumped me into. No guardrail I had in place forced that review, and the agent wasn't going to volunteer it. This was personal money, not a client's, which is the only mercy in the story — though the buck stops with the engineer either way, and this time it was literal bucks. My wife arrived to find me staring at my phone, and explaining what the number on it was did not improve the evening. The code had shown up fast. The engineering hadn't happened yet.

The people who tell me AI coding produces garbage are, almost without exception, describing a workflow where output gets accepted at the moment of generation. They're playing the slot machine and complaining about the payout. The patience to let the full process finish, even when it takes as long as doing the work yourself, turns out to be the actual skill, and it's rarer than prompt-writing.

## What you do with the hours

So a unit of work takes as long or longer, and the quality comes out higher. What changed is where you are while it happens. The agent needs you at the edges — defining the problem, making the architectural calls, reviewing the result — and doesn't need you in the middle. The middle is most of the hours.

One thing you can do with those hours is run more of them. One person, several parallel tracks of work. This works; I've had an agent [babysitting a PR through CI and review](https://github.com/jwilger/ai-plugins) while another worked a feature branch in its own worktree and I did design work on a third thing. And for all my hedging about raw speed, the volume is real: I've never been more prolific on the side projects I actually care about — [eventcore](https://github.com/jwilger/eventcore), [auto_review](https://github.com/jwilger/auto_review), and [a bunch of others](/projects/) that would have stayed ideas in a notes file for lack of nights and weekends to spend on them.

But parallelism also rebuilds the slot machine one level up. Three levers now, and one of them is always worth checking. It creeps into evenings, and I can tell you exactly which work did the creeping, because it was those same side projects. I've caught myself checking agent progress from my phone at dinner the way other people check markets. If parallelism turns you into a fourteen-hour-a-day agent supervisor, you've automated the work and doubled the job.

The other thing you can do with the hours is live them. The agent turns ideas and architecture into working, tested, reviewed software over an afternoon, and nothing about that requires you to watch. Go for a walk. Cook dinner. Pick your kid up from school without a laptop in the car. The work finishes to a higher standard than a rushed human afternoon would have produced, and you weren't chained to the desk while it happened.

That same keyboard-hours training that makes the waiting feel like slacking is what makes this option so hard to choose — the best version of this job now involves *not watching*, and every instinct I built over twenty-plus years says that can't be right. But that's the dividend. Not velocity. Autonomy over your own attention.

## If you want the good version

Encode your discipline as gates the agent can't skip: test-first, verification before any "done" claim, a real review. Instructions the agent can talk its way past don't count; I've written [before](/blog/coding-harness-plugins-are-agentic-systems/) about testing whether these guardrails actually change behavior, because plenty of them don't.

Judge the workflow by finished work, not by how fast code appears on screen. When the agent is mid-process, let it finish, and notice what the idle time makes you want to do; the itch to fill it is the tell that you're pulling the lever instead of running an engineering process. And decide on purpose what the freed hours are for, because if you don't choose, the itch will choose for you, and its answer is always more levers.

## The time between

Since I stopped treating the middle hours as a problem to fill with more work, I've put them into something I never saw coming: I'm learning to play the violin.

Learning a new piece or a new technique takes my full attention, so I don't attempt it while agents are running. But technique practice — scales, drills, bowing exercises — fits in the gaps, and there are hours of it to do. The ear listening for intonation and the muscle memory forming in my hands run on different parts of the brain than reading agent output and thinking about product and architecture, so I can practice and still notice when a gate fails or a decision needs a human. My hands are too busy to pull levers. It turns out that's exactly what was needed to stop the all-day-every-day-must-be-making-code addiction that had started to set in.

Speed was never the real offer. The real offer is better software and your life back, and you only collect if you can stop pulling the lever long enough to let the machine finish.

What would you do with the time between?
