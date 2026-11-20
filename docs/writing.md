# Writing for the site

Write for engineers and engineering leaders. A post should teach a concrete engineering lesson and show John's judgment through specific decisions, constraints, tradeoffs, and implementation details. Don't turn it into generic marketing copy. See the [product brief](../PRODUCT.md) for the publication's goals.

John's preferred sources for writing are his own work and the published work of Scott Wlaschin, Martin Fowler, Rob Hornsby (AlixPartners), President Barack Obama, Willem Larsen, and Garrison Keillor. Use the relevant original work as a starting point, not a template or evidence about this site's readers.

## Voice

- Prefer contractions in normal prose: “didn't”, “don't”, “isn't”, “can't”, “I'd”, “I'm”, “you're”.
- Use first person when the post is grounded in John's experience, implementation work, or decision-making.
- Explain why a choice was made, what failed, what changed, and what evidence supports the claim.
- Keep claims narrow and defensible. Name caveats, measurement limits, and scope boundaries instead of overstating outcomes.
- Prefer concrete artifacts, commands, data, code snippets, dates, and repo behavior over abstract value claims.
- Let expertise show through the work. Avoid telling the reader that something is innovative, robust, seamless, or important unless the post proves it.

## Openings

- Give the reader a reason to keep going in the first few paragraphs: a situation they recognise from their own work, a decision they've had to make, or a cost they've paid. Make it relatable without being campy, corny, or fake. Don't invent anecdotes or manufacture stakes; use what happened and say why it would matter to someone running an engineering organisation or a business. (John, 2026-11-20.)
- Readers include VP/CTO-level engineering leaders and non-technical business leaders judging the idea or John's expertise. Technical posts stay technical, with enough plain explanation that the second group can follow the argument.

## Structure

- Use headings sparingly. An essay that argues one point should read as continuous prose, with transition sentences carrying the reader between parts. Keep headings for how-to and reference posts where a reader would jump around. A heading on every few paragraphs reads as machine-generated. (John, 2026-11-20.)
- Restructuring a post is fine when it still makes the same points.

## Lessons from John's edits

Record each editorial correction here with the lesson it carries, and apply the lessons to later posts.

- **Keep irritation measured.** John rejected "What I can't stand is…" in the political-promises essay; the restored wording is "What bothers me, and has for a long time, is…". He states a frustration plainly and at conversational volume. Avoid heated or theatrical idioms for annoyance ("can't stand", "drives me crazy", "infuriating"), and prefer his own phrasing from the original when it already does the job. (2026-11-20.)

- **Don't announce what's coming.** John cut "So here are three cases, the first two from the Obama years and the third from this week" as noise: "Announcing what you are about to say right before you say it makes it read like a teenager wrote it." No roadmap sentences, previews of the next section, or "here's what I'll say" lead-ins. Start the thing itself, and make a transition carry information the reader needs (a date, a contrast, a fact) or drop it. (2026-11-20.)

- **No bolted-on disclaimers.** John flagged "Those figures are contractual reference amounts. They're useful for… and they aren't estimates of…" as an AI-generated disclaimer. A caveat has to do work for the argument around it: explain the term in passing and say what the numbers do show (here, that the amended rule reaches about a fortieth of the original). If a caveat only protects the writer, drop it. (2026-11-20.)

- **A change of subject still needs a turn.** After the headings came out, "With the new Russia sanctions, the gap was written into the law from the start" read as if it continued the preceding Warren paragraph. When prose moves to a new case without a heading, the first sentence has to close the previous one and reorient the reader, by contrast with what came before or by returning to something already established (here, the news story from the opening). That is different from announcing: the sentence makes a point of its own. (2026-11-20.)

- **Pick a person and hold it.** John changed "Before I give anyone credit… that tells me… I assumed" to "we" and "us", then rejected the half-applied fix "Before we give anyone credit, I start with…" ("grammar much?"). Advice the reader is meant to act on, and judgments citizens share, take "we" throughout the passage. Keep "I" for John's own reactions and experience. Never switch person inside a sentence, and when John corrects a pronoun, apply it to the whole sentence and the passage around it. (2026-11-20.)

- **Check sweeping words against the essay's own argument.** "Amendments fail and investigations get stonewalled, and that's no mark against anyone" was wrong: a blocked amendment may well be a mark against the people who blocked it, which the same essay argues about the Meeks amendment. Words like "anyone", "nobody", "always", and "never" make a claim about every case. Say who the claim covers ("the official who tried"), and don't smooth a sentence into something broader than John would defend. (2026-11-20.)

- **Say it the direct way.** "Expand surveillance restrictions" became "further restrict surveillance". When a verb is stacked on an abstract noun that hides the real verb ("expand restrictions", "increase limitations", "provide support for"), use the real verb. This is most likely where the phrasing was carried over from a source's headline or official language. (2026-11-20.)

## Revision

- Avoid stock punchlines like “That last part matters” and generic transitions like “It is worth noting”, “Importantly”, “Moreover”, “Furthermore”, “In today's landscape”, “The broader lesson”, and “The omission is deliberate”.
- Avoid marketing filler such as “unlock”, “leverage” when “use” is meant, “seamless”, “robust” without specifics, “game-changer”, “crucial”, and “not only … but also” constructions.
- Cut polished-but-empty summary paragraphs that could fit any technical topic. Avoid formal-paper phrasing in blog prose when a contraction would sound natural.
- Don't call implementations “intentionally boring”, “deliberately simple”, or “mundane” unless the phrase carries a concrete technical claim. Say what the implementation avoids, what boundary it preserves, or what property it gives you.

Before finishing a post, scan it for these tells and revise the surrounding sentence, not just the phrase. Treat matches as prompts for review; they may be right in code, quotes, titles, or deliberately formal contexts.

```bash
rg -n "That last part matters|It is worth noting|It's worth noting|Importantly|Moreover|Furthermore|In today|landscape|delve|unlock|seamless|robust|leverage|crucial|game-changer|not only|broader lesson|omission is deliberate|intentionally boring|deliberately simple|deliberately boring|intentionally simple|mundane" content/blog
rg -n "\bI did not\b|\bI do not\b|\bI am\b|\bI would\b|\bI could not\b|\bI cannot\b|\bit is\b|\bIt is\b|\bdoes not\b|\bdo not\b|\bdid not\b|\bcannot\b|\bwould not\b|\bshould not\b|\bis not\b|\bare not\b|\bthey are\b|\bThere is\b|\bthere is\b|\byou are\b" content/blog
```
