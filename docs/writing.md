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

- **The benchmark is MIT Sloan Management Review.** Every article should feel at home there (John, 2026-11-20). That means: the management problem and the argument are clear within the first few paragraphs; claims rest on evidence and first-hand practice; technical detail is led by the principle it serves, in plain language, with the mechanism after it; the consequences for someone running an organisation (hiring, buying, measuring, staffing) are stated where the argument earns them; the tone is measured and adult. It does not mean consultant vocabulary, frameworks with invented names, or a recap list at the end.

- **Open in the reader's situation, not John's.** John rejected an opening built on his own experience of being misunderstood ("When I tell someone… I can usually see within a few seconds whether they've heard what I meant") as weird, unlike Sloan, and not drawing readers in "with their *own* experience, insecurity, or curiosity". Start with something the reader has seen, been asked, or worried about (the demo they watched, the budget question it raised), then state the argument. John's own observation can follow as one supporting sentence. (2026-11-20.)

- **State the thesis in general terms and save the case for where it's told.** "Automating the assembly of cars created a second engineering profession" gave away the car history a section early; John preferred "Automated assembly lines…". The opening makes the argument; the specific story that proves it should arrive fresh in its own section. (2026-11-20.)

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

- **State the thought; don't label it as one.** John: "Don't hedge things with phrases like 'I think'. Be authoritative. Don't tell people it's what I think, that's obvious. Just provide the thought." Cut "I think", "I believe", "I'd argue", "in my view", "the claim I'm making is", "I'm not saying…", and "I've argued that…" as wrappers around a claim, and write the claim. Keep first person for what John did, saw, or wants. Real uncertainty is stated once, as a fact about the evidence ("I haven't seen those submissions"), not as a softener on the sentence. (2026-11-20.)

- **No hyperbole.** John: "Avoid hyperbole!" Flagged in the factory rewrite: "It would be hard to find a more thoroughly engineered place", "than Benz could have imagined", "grew enormously", "at great expense", "nobody had managed before", "constantly", "costs nothing", "nothing downstream can be trusted". Being authoritative means stating a claim at the size the evidence supports. Check superlatives, intensifiers ("enormous", "great", "massive"), absolutes ("nothing", "never", "every", "nobody"), and "could have imagined"-style flourishes, and replace each with the plain measure or cut it. (2026-11-20.)
- **Don't undercut the argument with a staged objection.** John disliked "The comparison to manufacturing has a hole in it" because it undermines the article. Where a comparison differs from the subject, state the difference as part of the argument (what software's line produces, what it demands that a press doesn't) without first declaring the analogy broken. (2026-11-20.)
- **Polishing sentences doesn't fix a machine-written draft.** John called the first factory rewrite "AI trash" although its points were sound. The tells were structural: a punchline closing most paragraphs, staccato fragments, an analogy mapped item by item, and a clever callback ending. When a draft reads that way, rewrite it from the argument up in connected explanatory prose, and don't preserve the original's sentences. (2026-11-20.)

- **No teaser sentences, no cute compression, no "people get this wrong".** John hated "When I use it, about half the people I'm talking to hear the demo. The term describes something else." Three faults: "hear the demo" is a compressed figure the reader has to decode; "The term describes something else" withholds the point to build suspense; and the pair casts John as the misunderstood expert and the reader as likely among the mistaken. Say what is true in the sentence where the question arises, and let the reader's mistaken picture go uncommented. (2026-11-20.)

- **Describe the factory by its invariants, not by a TDD recipe.** In the factory article John replaced a step list ("a test is written that fails for the right reason, and then the code that makes it pass") with the underlying idea: every unit of work is different, but invariants hold for all of them, and those invariants are the tolerances that let the parts fit and operate together. The factory is the designed systems and processes that ensure parts are within spec before delivery. Test-first is one way to get there and shouldn't be presented as the definition. More generally: when John's practice could be mistaken for a familiar named method, state the principle it serves. (2026-11-20.)

- **Don't add a term for the sake of precision.** John cut the "job shop running standard work" comparison from the factory article: not wrong, but it "introduces another term for the sake of pedantry and provides little value to the reader". A new term or a more exact analogy has to help the reader understand or decide something. If it only shows the writer knows the finer distinction, leave it out. (2026-11-20.)

- **Keep John's own tooling out of an argument aimed at leaders unless the argument needs it.** John removed the Lanyard anecdote and then every detail of his personal harness from the factory article as "an awkward aside". In a piece arguing a general point, the specifics of his setup pull the reader away from their own situation. Make the point in general terms and link to the posts that hold the implementation detail. (2026-11-20.)

- **Don't tidy a claim into something false.** "The factory adds to that work without taking any of it away" was inaccurate, and John corrected it: the factory takes away the toil of fitting that engineers do when no process enforces tolerances; the interesting work that needs experience, intuition, and judgment remains; and designing the factory presents new challenges. When condensing, check that a neat sentence still says what John holds to be true. His position on AI and engineering work is: toil goes, judgment stays, new problems arrive. (2026-11-20.)

- **After any correction, reread the whole article.** John: "when I correct something, you should review the full article to make sure that correction flows." A corrected claim changes what earlier paragraphs must set up and what later ones may say. Reread from the top, fix every passage that now contradicts, repeats, or fails to prepare for the correction, and report what changed. Don't flag a possible inconsistency and leave it for John. (2026-11-20.)

- **Don't echo a word inside a sentence, and edit John's chat notes before they become prose.** "Reliably builds a product that reliably does" was lifted from an instruction John typed quickly; he mocked it on sight. His corrections state the idea he wants, in working shorthand. Write the finished sentence for him, and read it aloud for repeated words. (2026-11-20.)

- **Don't argue with a position nobody holds.** John cut "Anyone who says the move to agentic development will go smoothly for everyone now employed is guessing…": "I've never heard anyone say that." Rebut only claims the reader has met. (2026-11-20.)
- **No coda.** John called the factory article's closing paragraph ("Deciding what to build is the same job it was… It's where I've spent most of the last year") dumb. Don't end by restating the thesis in balanced sentences or signing off with John's biography. End on the last thing the reader needs: the consequence for them. (2026-11-20.)
- **Keep evidence on the point.** Ford's turnover and five-dollar-day figures were cut from the factory article as tangential to the point that the job becomes a different job. A striking statistic stays only if it proves the sentence it sits in. (2026-11-20.)
- **Check a supposition before writing it as fact, and do the research without asking about the cost.** John supposed the best fitters became tool designers, then said not to state it as fact without evidence, and was annoyed at any suggestion that looking would take time. Find the source, write only what it supports, and name it. Source used: Stephen Meyer, *The Five Dollar Day* (SUNY Press, 1981), ch. 2, p. 25 and pp. 52-53. It supports shop-trained toolmakers, patternmakers, and draftsmen working beside engineers ("little delineated the tasks of the college-educated engineer and the shop-bred mechanic"), 59 draftsmen and 472 toolmakers in June 1914, 871 skilled workers in all, fewer than 13,000 workers, and a Ford apprenticeship school for toolmakers and diemakers. It does not say that fitters became tool designers. (2026-11-20.)

- **Say what the evidence shows before giving it.** John couldn't follow a paragraph of sourced facts about Highland Park's toolmakers because it never said what they proved. Open the paragraph with the claim (here: experience of the old job is part of what qualifies someone for the new one, and there were few such jobs), then give the facts, each attached to the part of the claim it supports. (2026-11-20.)

- **One paragraph, one direction.** John read "There weren't many of these jobs… Ford ran its own apprenticeship school… from fewer people" as arguing opposite things ("WUT?"). Facts that pull different ways (a small share of jobs, yet enough demand to need a school) must be reconciled in the sentence that introduces them, or one of them goes. Don't use "though" and "still" to stack qualifications and leave the reader to work out the net claim. (2026-11-20.)

- **"Most experienced engineers", not "senior engineers".** John: "senior engineer" is "kind of meaningless and almost entry level these days thanks to title inflation". Describe people by experience, not by title ("senior", "staff"). And when writing about what changes for them, do their existing skill and knowledge justice: it is the basis of the new work, not something they must leave behind to retrain. (2026-11-20.)

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
