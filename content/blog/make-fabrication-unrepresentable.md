+++
title = "Make Fabrication Unrepresentable"
description = "A practical approach to preventing AI assistants from fabricating numbers by making model outputs cite or compute values instead of asserting them."
slug = "make-fabrication-unrepresentable"
date = 2026-06-04

[extra]
cover = "/images/blog/make-fabrication-unrepresentable.jpg"

[taxonomies]
tags = ["ai", "llm", "generative-ai", "software-engineering"]
+++

A while back I helped build an AI assistant that lived inside a business application and answered questions about the company's data. You'd ask it something, it would call the right tools, pull the real numbers, and hand you a clean little summary with a table and a recommendation at the bottom. Most of the time it was genuinely useful.

And every so often, it made something up.

Nothing dramatic. It would report a percentage that was a few points off, or a projected total that looked entirely plausible and matched nothing any tool had returned. The real data was sitting right there in the tool results. The model just did a little arithmetic in its head on the way to writing the answer, got it wrong, and stated the result with the same calm confidence it used for everything else.

We added a line to the prompt: *do not compute or invent numbers that didn't come back from a tool.* It helped, a little. The next regression earned us another paragraph, then a bulleted list of the specific things it wasn't allowed to make up. By the time I started paying real attention, the part of the system prompt devoted to "please don't lie" ran a couple hundred words, and we had a test whose only job was to assert that those couple hundred words were still there.

That test should have been the tell. When your defense against a category of bug is a paragraph of English you're afraid to delete, you don't have a defense. You have a wish.

## Markdown and pray

Here's how a system like this usually talks to itself.

One component decides which sub-task should handle your question and writes it a brief — in prose. That step calls some tools and answers — in prose. A final step takes those answers and composes the reply you actually see — in prose. Somewhere in the middle, code is scraping numbers and statuses back out of formatted text so it can do something with them.

Every handoff has the same contract: I'll format something, and you'll figure out what I meant.

We would never accept this from our own code. You wouldn't merge a function whose signature was a comment that read `// returns the right number, promise`; you'd want the type to say what comes out. But the moment a language model joins the system, we drop the standard, pass prose around, and hope the next reader recovers our intent from the formatting.

## The model is just another user

A while back I wrote that [the language model is just another user](https://johnwilger.com/blog/the-language-model-is-just-another-user/). The short version: don't treat it as a trusted internal component, treat it as a user at a keyboard sending inputs to your system. Route what it tries to change through the same commands your UI uses, validate against the same invariants, and when it gets something wrong, hand back the same plain-language error you'd show a person so it can correct itself. The unpredictable-input problem turns into form validation.

I still believe that. But it only disciplines what the model tries to *do* to your system. It says nothing about what the model *says* to your user.

The fabricated number never went through a command. It never tried to change any state I was validating. It went from the model's prose straight into a chat bubble in front of a user. We'd locked the door the model writes through and left the one it talks through wide open.

## A number without a source is a guess

The fix is to put a boundary on the output side too, and make it a real one — a type, not a plea.

The move is to stop letting the model write numbers down at all. It doesn't get to *report* a value; it gets to *reference* one. Either it cites a value (points at a specific tool call from this turn and the field to read) or it requests a computed one (names a formula from a closed set, plus the cited inputs to run it over). Roughly:

```typescript
type FormulaName = "rate" | "delta" | "rollup"; // a closed, named set

type Cite    = { toolCallId: string; field: string };   // "read this"
type Compute = { formula: FormulaName; inputs: Cite[] }; // "run this over these"
type Claim   = Cite | Compute;                           // all the model may emit
```

Notice what's missing: a number. No variant of `Claim` carries a value, so the model has no way to hand you one. It can only tell you where a value should come from.

Your code does the rest. The step that turns the answer into prose walks every `Claim`: for a `Cite`, it reads the field out of the actual tool result; for a `Compute`, it runs the named formula over inputs it reads the same way. If a citation points at a tool call that didn't happen this turn, or a formula that doesn't exist, it won't resolve, and the answer doesn't ship. The bytes the user sees are produced by your code, every time. The model chose what to point at. It never got to write the number itself.

The `Compute` half matters as much as the `Cite` half. The model is bad at arithmetic and good at language, so stop asking it to do arithmetic. A rate, a rolling total, a percentage of a percentage — each is a function in your code with a name, and the model's only move is to ask for it over inputs that are themselves citations. The total at the bottom of the table comes out of the same function every time, instead of being re-derived in prose by a model that can't be relied on to add.

## Provenance is necessary, not sufficient

This kills invented numbers. It does not, by itself, give you correct ones.

Ask how many items are overdue and the assistant would cite the right tool, read the right field, and still hand you a wrong number — because "overdue" isn't "past its due date." A finished item isn't overdue. A cancelled one isn't overdue. The tool was handing back a count that ignored status, the citation pointed at exactly that count, every value resolved cleanly. Provenance was satisfied. The answer was wrong.

Two different mistakes hide in there. One is which field gets cited: ask for a total, cite the subtotal, and you've sourced a real number that answers a different question. The other is what the number means: the count was computed with the wrong definition of "overdue" before it ever reached the model. A citation proves a number is real. It says nothing about whether it's the number you meant.

That second mistake is old. Ten years ago I wrote about [enforcing an awkward uniqueness rule in Postgres](https://johnwilger.com/blog/complex-unique-constraints-with-postgresql-triggers-in-ecto/) — a room can't be double-booked, but only against reservations that are confirmed, or on hold and less than a day old. The naive constraint is wrong because the rule has a status gate baked into it. Same shape, different decade. The instant a definition like "overdue" lives in two places (once in the tool, once in whatever the model reconstructs), they drift, and the copy the model is working from is the one that's wrong.

So "overdue" becomes a single function, defined once, that the tool and the formula registry both call. There is exactly one answer to what counts as overdue, and it's code.

## Make the bad state impossible, not discouraged

None of this is an AI technique. It's the oldest move we have, pointed at a new kind of component. We've spent decades learning not to validate-and-pray: design the types so the invalid value can't be constructed, parse untrusted input into trusted shapes at the edge, put each invariant somewhere the system can't route around it. Make illegal states unrepresentable. Parse, don't validate.

A language model is the least trustworthy caller you will ever integrate — fluent, eager, and every so often serenely wrong. Everything we already know about defending a system against bad input applies to it. We just have to actually apply it, instead of being so charmed that the thing writes paragraphs that we forget it's an input source like any other.

## Where to look in your own stack

You probably don't have my assistant, but you likely have a cousin of it somewhere. A few places I'd check.

Start with the prompt. Search your system prompts for the rules that boil down to "please be accurate" or "don't make things up." Each one marks a property you're hoping for instead of enforcing. Some of them can't leave the prompt. Some can, and those are the ones quietly failing in production.

**Stop passing prose between your own components.** If two parts of *your* system talk through free text that a third part then parses, that isn't the model's fault and it's the easiest thing on this list to fix. Put a typed contract on the wire and let the structure survive the trip.

**Let the model reference values, not assert them.** Anything you can compute, compute. Give it a closed menu of named operations over cited inputs rather than a blank check to do math in prose.

**Give the output a boundary it has to clear** — something that resolves every reference before the answer ships, and when a reference doesn't resolve, rejects the answer and hands the model a plain-language reason to try again. The same discipline you already put on the input side.

And be honest about what it doesn't buy you. Provenance kills invented numbers. It does nothing for a citation that points at the wrong field, or a definition that was already wrong before the model touched it — that's what single-source-of-truth functions are for. It does nothing for a model that answers the same question two ways on two turns; that's consistency testing, a different tool entirely. And it does nothing about the sentence the model wraps around a correctly-sourced number: a real `0` can still sit inside "good news, everything's on track" when that `0` was a tool error wearing a disguise. The structural fix shrinks the surface area for fabrication. It doesn't erase it.

## The model doesn't get an exemption

The practices that make human engineers reliable are the practices that make language models reliable. The model doesn't get a pass on any of them because it happens to be articulate.

You can ask it to be honest, and it mostly will — right up until the day it doesn't. Or you can build a system where the dishonest answer has nowhere to go: where a number with no source was never something the model could say in the first place.

Stop telling the model not to lie. Build the thing so the lie has nowhere to land.
