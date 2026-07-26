+++
title = "Somebody Has to Design the Factory"
description = "\"Dark factory\" software development doesn't mean typing an idea into a box. Automating assembly created a second engineering discipline, and that's where senior judgment goes."
slug = "somebody-has-to-design-the-factory"
date = 2026-07-26
draft = false

[extra]
cover = "/images/blog/somebody-has-to-design-the-factory-cover.png"

[extra.narration]
src = "/audio/blog/somebody-has-to-design-the-factory.mp3"
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
tags = ["ai", "llm", "software-engineering", "workflow", "manufacturing"]
+++

Four rules got added to my agent harness [the morning I built
Lanyard](/blog/the-software-i-wouldnt-have-bothered-to-build/). Ticket work has to
happen in an isolated worktree. Commits and pushes from the primary checkout are
blocked. A deployment isn't a deployment until a live URL answers. And a
task-closing command's exit code doesn't count as evidence that the task closed.

Each of them came from something going wrong that day. None of them are features
of Lanyard, which is an SSH proxy and has nothing to do with any of it. Lanyard
was close to a byproduct. What I actually spent the morning on was a slightly
better factory.

That word has started showing up in conversations about where agentic development
is heading, usually as "dark factory," and about half the time I use it I can
watch the person across from me hear something I didn't say.

## What people picture

The image is a text box. You type what you want, some quantity of machine
intelligence happens, and a finished product comes out the other side. No
engineers, no designers, no product manager, no argument about what the thing
should do. The prompt is the spec, the output is the product, and the entire
middle got vaporized.

Products shaped like that exist and some are good at what they do, in exactly the
way Canva is good at making you a [coffee mug with a squirrel on
it](https://www.canva.com/newsroom/news/brand-campaign-2026/). They aren't what
the dark factory argument is about, and treating them as its endpoint makes the
actual claim impossible to discuss.

What's happening there is a category error rather than a disagreement. It
collapses three separate activities into one: deciding what to build, engineering
how it works, and producing it. A dark factory isn't a wish granted. [FANUC has
run one in Oshino since
2001](https://www.industrialautomationindia.in/articles/fanuc-lights-out-manufacturing-benchmark),
where robots assemble roughly fifty robots a day and the line runs unsupervised
for up to thirty days at a stretch. The lights are off because nobody is on the
floor to need them. According to one of their VPs, they turn off the heat and air
conditioning too.

That plant is one of the most heavily engineered objects on the planet. Every one
of those thirty unattended days rests on people who decided what a robot should
be, people who worked out how to make one, and people who worked out how to make
a machine make one. Nobody typed "robot" into anything.

## Benz's workshop had no factory

When Carl Benz and Gottlieb Daimler were building the first automobiles in the
mid-1880s, they worked in engineering workshops. Parts were forged, cast, and
machined, often by specialist suppliers who had been making something else
entirely the year before. Then skilled workers assembled the car by hand, filing,
shimming, and reaming each piece until it mated with the one next to it.

That fitting wasn't unskilled labor. A fitter was reading the actual assembly in
front of him, feeling where it bound, and correcting for the gap between what the
drawing claimed and what the shop had produced.

An enormous amount of product design and mechanical engineering went into those
cars, and much of the learning was only available with your hands on the thing.
You found out how a component behaved by making one, setting it next to another
one, and watching what happened.

## Ford automated the fitting, not the designing

The moving assembly line arrived at Highland Park in 1913, and the thing that
made it possible wasn't the conveyor. It was parts held to tolerance tightly
enough that fitting became unnecessary. A line only works if the part coming down
the chute drops into place without anyone deciding anything about it. Ford didn't
invent that idea; armory practice in the American arms industry had been chasing
interchangeable parts for most of the preceding century. Ford industrialized it,
at a scale and a price nobody had managed before.

Getting there took a body of engineering that had barely existed as a job. Somebody
had to design the gauges that said whether a part was in spec. Somebody had to
design the jigs and fixtures that held the work in exactly one orientation so it
couldn't be machined backwards. Somebody had to cut the dies, balance the stations
so no position starved or flooded the next, and run the tolerance stack-up analysis
that tells you whether a chain of individually acceptable parts still adds up to a
door that closes.

Product design didn't shrink when the line showed up. A second design discipline
grew up beside it, hard and expert and well paid, and we now call it manufacturing
engineering.

Notice what the tolerance regime actually eliminated. The fitter with a file was a
human compensating, one part at a time, for a process that couldn't hold its own
spec. Holding the spec is what made the compensation unnecessary. Filing the part
down is what you do when the factory doesn't work.

## The fitters didn't become tool designers

The aggregate story is that automotive engineering employment grew enormously over
the following century. The story for an individual fitter in 1913 was worse than
that.

Work on the line was miserable in a way the craft work hadn't been. Ford hired
50,448 people that year to sustain an average workforce of 13,623, a turnover rate
around 370 percent, which meant that growing the workforce by a hundred took
hiring nearly a thousand. In January 1914 Ford answered by roughly doubling pay:
[five dollars for an eight-hour
day](https://www.thehenryford.org/collections/explore/articles/fords-five-dollar-day)
against the previous $2.34 for nine. Turnover fell to 54 percent. Nobody doubles
wages to keep people in a job they like.

So the claim I'm making is narrow. The work didn't disappear, and there turned out
to be more of it, at higher skill, than before. That isn't the same statement as
"your job is safe," and I'm not making the second one. Aggregate growth is cold
comfort when the growth lands on different people, in a different city, a decade
later. Anyone promising you that the transition to agentic development will be
smooth for everyone currently employed is guessing, and guessing in the direction
that happens to be comfortable for them.

## Nobody sells you a factory

Cars didn't get simpler. Neither did the engineering. A modern vehicle program
employs more engineers across more disciplines than Benz could have imagined, and
it delivers more variety at lower cost to more people.

What matters most for software is what happens when a company decides to build a
new model. They don't roll the last one's factory over onto it.
They design a production system for that product: new dies, new fixtures, new
gauges, a rebalanced line, a revalidated supply chain. Platforms and plants get
shared, and a flexible line can build more than one model, but the tooling specific
to a product is designed fresh, by experts, at large expense, every single program.

That's the fact that should make you suspicious of anyone offering to sell you a
software factory. In manufacturing, machinery is a thing you can buy. The
production system is a thing your engineers design for what you're building. When
somebody's pitch is that you can buy the second one, they're selling you machinery
and calling it a factory.

## The line produces changes, not products

The analogy has an obvious hole and it's worth walking straight into it. Physical
factories exist because replication is expensive. You design a car once and then
face the separate, enormous problem of producing a hundred thousand identical ones.
Software solved that problem decades ago. Copying a build costs nothing. `cp` is
the entire assembly line, and it was never the interesting part.

So what would a software factory be for?

The thing that repeats in software isn't the product, it's the process. The unit
coming off the line is a change: a feature, a fix, a migration, a dependency bump.
Each one runs the same sequence. Work out what the behavior should be, decide what
will be expensive to reverse later, write a test that fails for the right reason,
make it pass, review it, integrate it, produce evidence that it actually deployed.
Different content every run, identical sequence.

<div class="diagram-scroll" role="region" aria-label="Scrollable diagram: different software changes move through one validated sequence" tabindex="0">
  <img src="/images/blog/somebody-has-to-design-the-factory-change-line.svg" alt="A feature, fix, migration, and dependency bump entering the same sequence of behavior definition, reversal-risk analysis, a failing test, implementation, review, integration, and live deployment evidence.">
</div>

A factory that outputs changes is still a factory, and it describes what's being
automated better than a conveyor of identical bodies does. The closer physical
analogue is a job shop running standard work: every job different, every job pushed
through the same validated process with the same fixtures and the same gauges.

This is where the analogy strains hardest. A stamping press doesn't read an
acceptance criterion and decide whether it's been met. My harness has to. The
automated steps need judgment in them, and bounding that judgment is the whole
design problem: enough to absorb a different change every time, not so much that
the process becomes a negotiation.

## Tolerances, for software

Tolerance stops being a metaphor as soon as you ask what the harness refuses to do.

Production code can't exist before a failing test has been observed, and the
failure has to come from the behavior being missing rather than from a typo or a
broken fixture. Code that shows up without that gets reverted rather than debated.
That's a station that can't be run out of sequence.

Test evidence is bound to a hash of the exact diff it was produced against, and the
clean-review streak resets to zero the moment that hash changes. Three clean review
passes followed by one more edit is zero clean review passes. An inspection record
belongs to a specific part, not to the general vicinity of the part.

A critical security or human-safety problem introduced by the change itself can
only be dispositioned as fixed. "Defended" and "accepted risk" exist for other
categories and are unavailable for that one. That's a gauge rejecting a part rather
than a reviewer holding an opinion about it.

CI recovery runs off a table compiled into the tool instead of described in a
document. A failure classified as caused by the change may only be repaired. One
classified unrelated or transient may only be rerun at the unchanged commit. There
is no third option, the classification has to be recorded before an action is
chosen, and the hold doesn't release until a matching replacement run reaches
terminal success. Queued isn't success. Neither is a zero exit code.

Reviews run in fresh contexts that have to attest they were fresh, and the
reviewing role has no write tools at all, because an inspector who can adjust the
part isn't an inspector.

The rule underneath all of them is the one I'd point at first. No agent working in
my repositories may install a substitute tool, weaken a required gate, or fall back
on stale memory in order to keep moving. When nothing available can satisfy a gate,
the correct behavior is to stop at the gate and come get me.

That rule is the fitter's file, confiscated on purpose. Weakening a gate so a
change can land is hand-fitting: a human compensating, one part at a time, for a
process that can't hold its own spec. It works, it's invisible in the finished
product, and it's the reason nothing downstream of it can be trusted. The entire
point of a tolerance regime is that nobody has to reach for the file.

<img src="/images/blog/somebody-has-to-design-the-factory-fitter-and-gauge.png" alt="On the left, a worker files one mismatched component until it fits; on the right, a fixed gauge rejects an out-of-tolerance component before it enters an automated line." loading="lazy">

Stations get different capability on purpose. Bounded mechanical work runs on a
small model with read-only tools and has to hand back evidence the caller can
verify independently, because its own account of what it did doesn't count.
Architecture and security analysis go to a stronger model that also can't write.
That's a fixture-and-gauge argument rather than a model-quality argument.

None of this is the model getting better. I've written before about [making bad
states structurally impossible rather than
discouraged](/blog/make-fabrication-unrepresentable/), and about how [a guardrail
nobody has tested for behavior change may not be a
guardrail](/blog/coding-harness-plugins-are-agentic-systems/).

## The part that needs your best people

The product manager still decides what the product is. The senior engineers still
decide which parts go together and which choices will be expensive to reverse.
None of that moved. What's new is that those same people are needed to design the
factory, and that's the work I'd put the most experienced person in the room on.

Every gate I described started as something a staff-level engineer already knows.
Don't trust an exit code. Don't let a green review outlive the diff it reviewed.
Don't let the author sign off on their own work. That knowledge is normally tacit,
exercised a few dozen times a week by people who would struggle to write it down if
you asked them to.

Encoding it is harder than exercising it. Exercising judgment lets it stay vague.
Encoding it forces you to state exactly what the standard is, exactly what evidence
satisfies it, and exactly what happens when the evidence is missing, in a form
something else can check with you out of the room. Most teams have never had to do
that, which is a large part of why they don't have a factory. The machinery isn't
what's missing. What's missing is a written-down definition of good, precise enough
to gauge.

Two claims get mashed together here and they're worth separating. The line didn't
make any individual worker faster at fitting a part. It removed the fitting. What
improved was throughput and rework, which are properties of a system rather than of
anybody's hands. I've argued that [AI probably isn't making you
faster](/blog/ai-might-not-make-you-faster-it-can-make-you-free/), and I still
think that holds for one person doing one task. A factory is a different unit of
analysis. You can have a well-designed one and remain personally slower at
everything, and that would be fine.

## Where the lights stay on

The lights go off over the line. They stay on in the room where somebody decides
what to build, and in the room next door where somebody decides how it gets built
the same way ten thousand times.

That second room barely existed for software five years ago. It's where I've spent
most of the last year.
