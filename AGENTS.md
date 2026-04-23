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

## Deployment

GitHub Actions workflow in `.github/workflows/deploy.yml` builds and deploys to GitHub Pages on every push to `main`.

## Accessibility

This site aims for WCAG 2.1 AA compliance:
- Color contrast ratios meet or exceed 4.5:1 for normal text
- Keyboard-navigable interface with visible focus indicators
- Semantic HTML with proper landmark regions
- Skip-to-content link
- Respects `prefers-reduced-motion` and `prefers-color-scheme`
