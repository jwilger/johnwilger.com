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
