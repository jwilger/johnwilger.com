---
name: narrate-blog-post
description: Create, mix, verify, and publish narrated audio for Zola blog posts in this repository. Use when asked to narrate an article, update an existing narration, add a post audio player, reproduce the approved Cedar/public-radio treatment, or inspect the narration pipeline and its CC0 sound assets.
---

# Narrate a blog post

Generate a verbatim article narration, mix it with the approved continuous room
tone and retro stinger, add the standard spoken sign-off, and install the MP3
for Zola to publish.

## Run the pipeline

From the repository root:

```bash
.agents/skills/narrate-blog-post/scripts/render-blog-narration.sh \
  content/blog/<post>.md
```

Require `OPENAI_API_KEY`, Python 3.11+, Node/npm, FFmpeg, and FFprobe. The script
installs its pinned WebSocket dependency under `.build/`, never in the
repository.

Use `NARRATION_MODEL` or `NARRATION_VOICE` only when the user explicitly asks
to change the approved defaults (`gpt-realtime-2` and `cedar`).

## Workflow

1. Inspect the post title, publication date, prose, code, and non-prose blocks.
2. Run the pipeline. It writes intermediates to `.build/narration/<slug>/` and
   the finished MP3 to `static/audio/blog/<slug>.mp3`.
3. Read `.build/narration/<slug>/transcript.txt`. Confirm that headings,
   images, and diagrams are absent; link text and article prose must remain.
4. Inspect every `segment-*-transcript.txt` and `signoff-transcript.txt`.
   Rendering retries automatically when normalized spoken words differ from
   the source. Never accept an added introduction, repeated phrase, omitted
   word, or paraphrase.
5. Copy the emitted `narration-frontmatter.toml` fields into the post's
   `[extra]` area without replacing its other metadata.
6. Run `bash tests/blog-narration-test.sh`, `just test`, and `just build`.
7. Check the rendered post at wide and mobile viewport sizes. Confirm the audio
   URL loads, the native player is usable, and the disclosure/credits are
   legible.

## Audio contract

Assemble these sections without overlap:

```text
retro stinger | narration + continuous room tone | retro stinger | spoken sign-off + room tone
```

Keep the room-tone stream continuous across every narration segment. Build one
crossfaded bed for the complete dry narration, then mix once; never mix each
speech segment independently.

Generate the sign-off from post metadata using this exact form:

```text
I'm John Wilger, and you've been listening to [article title], published on
[publication date], and copyright [year], all rights reserved. You can read or
listen to more of my work at johnwilger.com.
```

Use the bundled source assets. Read [references/licensing.md](references/licensing.md)
when publishing or changing credits.

## Site contract

Narrated posts declare `extra.narration.src`, MIME type, and credit records.
`templates/blog-page.html` conditionally renders the compact listening section;
posts without narration metadata must not render it.

Always disclose the AI-generated voice. Keep the linked sound-designer credits
even though the bundled sources are CC0 and attribution is not legally
required.
