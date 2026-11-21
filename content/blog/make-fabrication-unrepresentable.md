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

A company that puts an AI assistant in front of its own data is trusting it with numbers that people will act on. I helped build one of these a while back. It lived inside a business application and answered questions about the company's data. You asked it something, it called the right tools, pulled the real figures, and returned a short summary with a table and a recommendation at the bottom. Most of the time it was useful. Every so often it reported a number that no tool had returned.

The errors were small. A percentage would be a few points off, or a projected total would look plausible and match nothing in the tool results. The real data was in those results. On the way to writing its answer, the model had done some arithmetic of its own, got it wrong, and stated the outcome as confidently as it stated everything else.

We added a line to the prompt: *do not compute or invent numbers that didn't come back from a tool.* It helped a little. The next regression earned another paragraph, and then a bulleted list of the specific things the model wasn't allowed to make up. By the time I looked closely, the part of the system prompt devoted to asking the model not to lie ran to a couple hundred words, and we had a test whose only job was to assert that those words were still there.

That test showed how little we had. A paragraph of English that a team is afraid to delete expresses a hope about the model's behavior and enforces nothing. The fix we arrived at was to change what the model was able to say, so that a number without a source couldn't appear in an answer.

The weakness wasn't confined to one prompt. A system like this usually passes prose between its own parts. One component decides which sub-task should handle the question and writes it a brief in prose. That step calls some tools and returns an answer in prose. A final step composes the reply the user sees from those answers. Somewhere in the middle, code scrapes numbers and statuses back out of formatted text so that it can do something with them. Each handoff relies on the next reader working out what the last writer meant.

We wouldn't accept that from our own code. A reviewer wouldn't approve a function whose signature was a comment reading `// returns the right number, promise`. We'd want the type to say what comes out. When a language model joins a system, that standard tends to be dropped.

I've written before that [the language model is just another user](/blog/the-language-model-is-just-another-user/). It shouldn't be treated as a trusted internal component. It should be treated as a user at a keyboard sending input to the system. What it tries to change goes through the same commands the interface uses and is validated against the same rules, and when it gets something wrong it receives the plain-language error a person would see, so that it can correct itself. Unpredictable input becomes a matter of form validation.

That still holds, but it governs only what the model tries to do to the system. It doesn't cover what the model says to the user. The fabricated number never went through a command and never tried to change any state we were validating. It went from the model's prose into a chat bubble. We had put a check on what the model could write to the system and none on what it could tell the person using it.

## A number without a source is a guess

The output needs a boundary too, and it should be a type, which the system enforces, and not a request, which the model may or may not honor.

The model is no longer allowed to write a number down. It can cite a value, by pointing at a specific tool call from the current turn and the field to read from its result. Or it can ask for a computed value, by naming a formula from a fixed set and citing the inputs to run it over. In outline:

```typescript
type FormulaName = "rate" | "delta" | "rollup"; // a closed, named set

type Cite    = { toolCallId: string; field: string };   // "read this"
type Compute = { formula: FormulaName; inputs: Cite[] }; // "run this over these"
type Claim   = Cite | Compute;                           // all the model may emit
```

No variant of `Claim` carries a value. The model can say where a value should come from, and it has no way to supply one.

Our code does the rest. The step that turns the answer into prose walks through every `Claim`. For a `Cite`, it reads the field out of the actual tool result. For a `Compute`, it runs the named formula over inputs that it reads the same way. A citation that points at a tool call that didn't happen in this turn, or a formula that doesn't exist, fails to resolve, and the answer doesn't go out. The characters the user sees are produced by code. The model chose what to point at.

The computed half matters as much as the cited half. A model is bad at arithmetic and good at language, so it shouldn't be asked to do arithmetic. A rate, a rolling total, and a percentage of a percentage are each a named function in the code, and all the model can do is ask for one over inputs that are themselves citations. The total at the bottom of the table then comes from the same function on every request, where before it was worked out again in prose each time.

## A sourced number can still be wrong

This removes invented numbers. It doesn't guarantee correct ones.

Asked how many items were overdue, the assistant would cite the right tool, read the right field, and still report a wrong number, because "overdue" doesn't mean "past its due date." A finished item isn't overdue, and neither is a cancelled one. The tool was returning a count that ignored status, the citation pointed at that count, and every value resolved. The answer had a source and was wrong.

Two different mistakes are possible here. One is citing the wrong field: asked for a total, the model cites the subtotal, and a real number answers a different question. The other is a number that means something other than what was asked, as when the count was computed with the wrong definition of "overdue" before it reached the model. A citation shows that a number is real. It doesn't show that it's the number the user meant.

The second mistake is an old one. Six years ago I wrote about [enforcing an awkward uniqueness rule in Postgres](/blog/complex-unique-constraints-with-postgresql-triggers-in-ecto/): a room can't be double-booked, but only against reservations that are confirmed, or that are on hold and less than a day old. The naive constraint is wrong because the rule depends on status, as "overdue" does. When a definition like that lives in two places, once in the tool and once in whatever the model reconstructs, the two drift apart, and the model's copy is the one that goes wrong.

So "overdue" became a single function, defined once, which the tool and the formula registry both call. The question of what counts as overdue has one answer, and it's in code.

None of this is particular to AI. It's established practice applied to a new kind of component. Engineers learned long ago to design types so that an invalid value can't be constructed, to parse untrusted input into trusted shapes at the edge of a system, and to put each rule where the system can't route around it. The short forms are "make illegal states unrepresentable" and "parse, don't validate." A language model is an untrustworthy caller: fluent, eager, and occasionally wrong without any sign of doubt. What we know about defending a system against bad input applies to it. The risk is that because it writes well, we forget it's a source of input like any other.

## Where to look in your own systems

Most companies that have built an assistant have some version of this problem. The prompt is the first place to look. Rules that amount to "please be accurate" or "don't make things up" each mark a property the team is hoping for and not enforcing. Some of those rules can't leave the prompt. Others can, and those are the ones failing in production without anyone noticing.

The next place is the handoffs between your own components. If two parts of your system communicate in free text that a third part then parses, the model isn't at fault, and this is the easiest item here to fix. Give the handoff a typed contract so that the structure survives the trip.

Then let the model refer to values and not assert them. Anything that can be computed should be computed, with the model given a fixed menu of named operations over cited inputs and no opportunity to do the math in prose.

Finally, give the output a boundary it has to clear: a step that resolves every reference before the answer goes out, and that rejects an answer with an unresolved reference and tells the model in plain language why, so it can try again. That's the discipline already applied on the input side.

The limits of the approach are specific. It does nothing for a citation that points at the wrong field, or for a definition that was wrong before the model touched it, which is what a single shared function is for. It does nothing for a model that answers the same question two ways on two turns, which calls for consistency testing. And it does nothing about the sentence the model wraps around a correctly sourced number: a real `0` can sit inside "good news, everything's on track" when that `0` was a tool error. The structural fix shrinks the room for fabrication without eliminating it.

The practices that make human engineers' work reliable make a model's work reliable too, and the model shouldn't be excused from them because it writes well. An assistant that's asked to be accurate will be accurate most of the time. If people are going to act on its numbers, the system has to make the unsourced answer impossible to deliver, wherever that can be done in code.
