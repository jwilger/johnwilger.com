+++
title = "Somebody Has to Design the Factory"
description = "Automated assembly lines created a second engineering profession, the one that designs the line. Software is acquiring its own, and the work belongs with a company's most experienced engineers."
slug = "somebody-has-to-design-the-factory"
date = 2026-07-26
draft = false

[extra]
cover = "/images/blog/somebody-has-to-design-the-factory-cover.png"

[taxonomies]
tags = ["ai", "llm", "software-engineering", "workflow", "manufacturing"]
+++

If you run a company that builds software, you've likely seen the demo by now. Someone types a paragraph into a box and a working application appears. It's hard to watch without doing some arithmetic on your engineering budget. If a paragraph can produce an application, it's fair to ask what your most experienced engineers are for, and whether their salaries would be better spent on the tool.

The name that has attached itself to this future is "dark factory," a manufacturing term for a plant that runs with nobody on the floor. The comparison is a good one, but the plants it refers to weren't built by removing engineers. Automated assembly lines created a second engineering profession, devoted to designing the line, alongside the one that designs the product. Software is acquiring the same second profession now, and the companies that benefit will be the ones whose most experienced engineers are doing that work.

[FANUC has operated a dark factory in Oshino, Japan, since 2001](https://www.industrialautomationindia.in/articles/fanuc-lights-out-manufacturing-benchmark), where an automated assembly line produces about fifty robots per day and can run unsupervised for up to thirty days. The lights are off because there's no one there to need them, and according to one of the company's VPs the heat and air conditioning are off as well. A great deal of engineering stands behind that empty floor. People decided what those robots should be, other people worked out how to make them, and still others worked out how to get machines to do the making. Only that last step, production, runs in the dark.

## How cars came to be built on a line

In the mid-1880s, when Carl Benz and Gottlieb Daimler were building the first automobiles, a car was made in an engineering workshop. The parts were forged, cast, and machined, often by suppliers who had been making something else entirely the year before. Skilled fitters then assembled each car by hand, filing, shimming, and reaming every piece until it mated with its neighbor. This was demanding work, and it had to be done again for every part of every car. A fitter had to read the assembly in front of him, feel where it bound, and make up the difference between what the drawing said and what the shop had produced. A good deal of what those early builders knew about cars they had learned that way, by making a component, setting it against another, and seeing what happened.

The moving assembly line that Ford opened at Highland Park in 1913 is remembered for its conveyor, but the conveyor depended on something less visible. A line only works if each part drops into place without anyone having to decide anything about it, and that takes parts made to tolerances tight enough that fitting is unnecessary. The idea wasn't Ford's. American arms makers had pursued interchangeable parts for most of the previous century. Ford's contribution was achieving it at industrial scale and low cost.

Doing so required engineering that had barely existed as an occupation. Gauges had to be designed to show whether a part was within specification, along with jigs and fixtures that held each piece in exactly one orientation so that it couldn't be machined backwards. Dies had to be cut. The stations on the line had to be balanced so that none starved or flooded the next. The tolerances of individual parts had to be analyzed together, because a chain of parts that are each acceptable can still add up to a door that won't close. We call this manufacturing engineering now. It grew up beside product design without replacing any of it, and it was hard, expert, well-paid work.

It also changed what the fitter's file meant. In the workshop, filing a part until it fit had been craftsmanship. Once the process could hold its own specification, that labor was no longer needed, and a part that did need filing was evidence that something upstream had failed.

The engineering didn't get simpler afterwards. A modern vehicle program employs many more engineers, in more disciplines, than the early workshops did, and it delivers more variety at lower cost to more people. When a carmaker introduces a new model, it designs a production system for that model: new dies, fixtures, and gauges, a rebalanced line, a revalidated supply chain. Plants and platforms are shared, and a flexible line can build more than one model, but the tooling specific to a product is designed fresh by experts, at considerable expense, for every program.

## What a software factory produces

A car plant exists to make many copies of one design. Software doesn't need a plant for that, since copying a finished program costs next to nothing. What a software organization produces over and over is changes to its products: a new feature, a bug fix, a data migration, an upgrade to a library the product depends on. Each change is different from the last.

What makes the work factory-like is that the same things have to be true of every change, whatever it contains. Its intended behavior was defined before anyone built it. The decisions that would be expensive to reverse were identified and made on purpose. There's evidence that it does what was intended and doesn't break what already worked. Someone other than its author has examined it, and it has been shown to be running where customers use it. These invariants do the job that tolerances do in a plant. A part made within tolerance fits the parts around it without adjustment, and a change that satisfies the invariants can be combined with the rest of the product, and with the other changes in progress, without anyone having to make it fit afterwards.

Designing a software factory means designing the systems and processes that ensure every change is within spec before it's delivered.

<a href="/images/blog/somebody-has-to-design-the-factory-change-line.svg">
  <img src="/images/blog/somebody-has-to-design-the-factory-change-line.svg" alt="A feature, fix, migration, and dependency bump entering the same sequence of behavior definition, reversal-risk analysis, a failing test, implementation, review, integration, and live deployment evidence. Opens the full-size diagram.">
</a>

Software asks more of its stations than a car plant does. A stamping press never has to read an acceptance criterion and decide whether it has been met, and an AI agent working on a change does that at nearly every step. The process has to allow judgment, enough to cope with a different change each time, and keep that judgment bounded tightly enough that the process doesn't turn into a negotiation. Most of the design effort goes into setting those bounds.

The bounds only work if they hold when holding them is inconvenient. When an agent can't satisfy a check, the easy way to keep moving is to weaken the check, substitute a different tool, or go on what it remembers, so that the change can land. That's the software version of the fitter's file. It gets the part to fit, it leaves no trace in the finished product, and it undermines the evidence that every later step relies on. A well-designed factory stops the line and asks a person.

<img src="/images/blog/somebody-has-to-design-the-factory-fitter-and-gauge.png" alt="On the left, a worker files one mismatched component until it fits; on the right, a fixed gauge rejects an out-of-tolerance component before it enters an automated line." loading="lazy">

None of this depends on the models getting better. It depends on [making bad states structurally impossible rather than discouraged](/blog/make-fabrication-unrepresentable/), and on testing the checks themselves, because [a guardrail nobody has tested for behavior change may not be a guardrail](/blog/coding-harness-plugins-are-agentic-systems/).

## Who designs it

The factory does take work away. It takes away the fitting, the toil of making each change work with everything around it by hand, which is where engineers' time goes when no process holds the tolerances. Fitting takes skill, as it did in the early workshops, but the skill is spent compensating for the process, one change at a time. With the fitting gone, that experience, intuition, and judgment go to the questions that remain, and to a new one. The product manager still decides what the product is. Experienced engineers still decide how its parts fit together and which choices will be costly to undo. The new question is the factory itself, and how to design it so that it consistently turns out a product that does what it's meant to do. That work belongs with the most experienced engineers a company has.

The reason is where the checks come from. They start as things an experienced engineer already knows: a command that finishes without an error hasn't proved it did its job, an approval shouldn't outlive the change it approved, authors shouldn't sign off on their own work. Engineers apply knowledge like that dozens of times a week, and most would struggle to write it down. Writing it down is the harder job. A person exercising judgment can leave the standard vague. A rule that a machine will enforce has to say exactly what the standard is, what evidence satisfies it, and what happens when the evidence is missing, and it has to hold when its author isn't in the room. Few teams have had to do this, which helps explain why they don't have a factory. They have the machinery. They lack a definition of good work that's precise enough to check against.

This is also why a factory can't be bought. In manufacturing, machinery is something a company buys, and the production system is something its own engineers design for the product being built. A vendor offering a complete software factory is selling machinery under a bigger name.

A factory should be judged the way a line is judged, too. The assembly line didn't make any worker faster at fitting parts. It did away with fitting, and the gains showed up as throughput and reduced rework, which are measures of a system. [AI probably isn't making you faster](/blog/ai-might-not-make-you-faster-it-can-make-you-free/) at an individual task, and a well-designed factory doesn't change that. A company that evaluates its factory by asking whether each engineer got faster is measuring the wrong thing.

The job itself becomes a different job, and experience of the old one is part of what qualifies someone for it. Ford's tooling at Highland Park was designed and built by college-trained engineers together with craftsmen who had learned their trades in the shop: toolmakers, patternmakers, and draftsmen. Stephen Meyer, in *The Five Dollar Day*, his history of the plant, writes that both were essential and that little separated what the two groups did. Craft skill had stopped being something most of the plant needed and had become the specialty of one part of it. In June 1914, 871 skilled workers designed, built, and arranged the equipment that fewer than 13,000 people worked on. Ford trained people for that work itself, in an apprenticeship school for toolmakers and diemakers.

A company that watches the demo and wonders what its most experienced engineers are for can take its answer from that history. They are the people who know why changes fail to fit, and what it takes to keep a product working as it grows. A factory is that knowledge, written down precisely enough to be enforced. Designing one is new work, and it depends on what they learned doing the old.
