# John Wilger — Personal Website

## Development

This site is built with [Zola](https://www.getzola.org/), a Rust-based static site generator.

### Prerequisites

- Nix with flakes enabled
- `direnv` (optional, for automatic shell activation)

### Getting Started

```bash
nix develop
just dev
```

The site will be available at `http://127.0.0.1:1111`.

### Build for Production

```bash
just build
```

Output is generated in `public/`.

## Architecture

| Component | Technology |
|-----------|-----------|
| SSG | Zola |
| Styling | Sass + CSS Custom Properties |
| Themes | Catppuccin Latte (light) / Mocha (dark) |
| Client JS | HTMX + Alpine.js |
| Comments | Giscus (GitHub Discussions) |
| Projects | GitHub pinned repos via GraphQL |
| Hosting | GitHub Pages |

## Content

- Blog posts are written in Markdown in `content/blog/`.
- The site supports tags via Zola taxonomies.
- Content is automatically built and deployed on push to `main`.

### Blog Writing Voice

When creating or editing blog posts, write for engineers first. The post should teach a concrete engineering lesson and demonstrate John's judgment through specific decisions, constraints, tradeoffs, and implementation details. Do not turn the post into generic marketing copy.

Use a conversational, technically precise voice:
- Prefer contractions in normal prose: "didn't", "don't", "isn't", "can't", "I'd", "I'm", "you're".
- Use first person when the post is grounded in John's experience, implementation work, or decision-making.
- Explain why a choice was made, what failed, what changed, and what evidence supports the claim.
- Keep claims narrow and defensible. Name caveats, measurement limits, and scope boundaries instead of overstating outcomes.
- Prefer concrete artifacts, commands, data, code snippets, dates, and repo behavior over abstract value claims.
- Let expertise show through the work. Avoid telling the reader that something is innovative, robust, seamless, or important unless the post proves it.

Avoid classic AI-generated-content tells:
- Do not use stock punchline sentences such as "That last part matters."
- Avoid generic transitions like "It is worth noting", "Importantly", "Moreover", "Furthermore", "In today's landscape", "The broader lesson", and "The omission is deliberate."
- Avoid marketing filler such as "unlock", "leverage" when "use" is meant, "seamless", "robust" without specifics, "game-changer", "crucial", and "not only ... but also" constructions.
- Avoid polished-but-empty summary paragraphs that could fit any technical topic.
- Avoid formal-paper phrasing in blog prose, especially repeated "I did not", "I do not", "is not", "does not", "would not", and similar forms when a contraction would sound natural.
- Avoid calling implementation pieces "intentionally boring", "deliberately simple", "mundane", or similar unless the phrase carries a concrete technical claim. These phrases become a recognizable AI-style tic when they only signal taste. Prefer naming the exact constraint or behavior instead: what the code avoids, what boundary it preserves, or what property the plain implementation gives you.

Before considering a blog post finished, scan it for these tells and rewrite the surrounding sentence, not just the single phrase:

```bash
rg -n "That last part matters|It is worth noting|It's worth noting|Importantly|Moreover|Furthermore|In today|landscape|delve|unlock|seamless|robust|leverage|crucial|game-changer|not only|broader lesson|omission is deliberate|intentionally boring|deliberately simple|deliberately boring|intentionally simple|mundane" content/blog
rg -n "\bI did not\b|\bI do not\b|\bI am\b|\bI would\b|\bI could not\b|\bI cannot\b|\bit is\b|\bIt is\b|\bdoes not\b|\bdo not\b|\bdid not\b|\bcannot\b|\bwould not\b|\bshould not\b|\bis not\b|\bare not\b|\bthey are\b|\bThere is\b|\bthere is\b|\byou are\b" content/blog
```

Treat these scans as prompts for review, not as absolute rules. Some matches may be correct in code, quotes, titles, or deliberately formal contexts.

## Deployment

GitHub Actions workflow in `.github/workflows/deploy.yml` builds and deploys to GitHub Pages on every push to `main`.

## Accessibility

This site aims for WCAG 2.1 AA compliance:
- Color contrast ratios meet or exceed 4.5:1 for normal text
- Keyboard-navigable interface with visible focus indicators
- Semantic HTML with proper landmark regions
- Skip-to-content link
- Respects `prefers-reduced-motion` and `prefers-color-scheme`
