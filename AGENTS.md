# John Wilger — Personal Website

## User constraints

- The site must meet **WCAG 2.1 AA**. This is a requirement, not a claim that the current site conforms.
- Use the Nix flake for the development toolchain for now. Be strict about linting and formatting; warnings are errors where checks are in use. No new lint or format tool has been chosen.
- Evolve the project-local Pi harness only for problems observed in real work. Reflect after meaningful slices or repeated friction; search for existing tooling first. Record the problem, why the change helps, validation, and when to revisit or remove it. Prefer the smallest check that works without Pi for costly objective mistakes; verify a valid case passes and an invalid one fails. Keep decisions, evidence, and open questions in the repo.
- Before adding or updating third-party tooling, read the code and install scripts, check provenance and maintenance, and review data access, outbound data and permissions. For updates, compare with the last reviewed revision. Pin exactly where supported and record the review alongside the change. If safety is unclear, don't add it. Ask before making changes outside this project or granting account, credential, or service access.
- After saving a skill, extension, Pi package, or MCP config that needs loading, call [`reload_and_continue`](.pi/packages/reload-and-continue/README.md) alone. Name the resource, how to verify it loaded, and the next step. Verify before relying on it.

## User preferences

- [Product direction](PRODUCT.md): a publication for engineers and engineering leaders. Writing should give readers something useful at work and build John's reputation as an expert. Follow the [writing guidance](docs/writing.md) when editing posts.
- Work directly on `main` for now; pushes deploy through [GitHub Actions](.github/workflows/deploy.yml) to GitHub Pages. Short, descriptive signed commits are a convention, not a gate. Check the workflow when a deployment fails.
- Prefer browser tests for changes to reader interactions. Keep `just test` local for now; CI builds before deployment.
- For building, start with published work by Scott Wlaschin, Kent Beck, and Brad Frost as relevant. Read primary sources for consequential decisions; cite what shaped the decision, not as evidence about our users. The writing influences are recorded with the writing guidance.

## Current defaults

- `nix develop`, then `just dev` serves Zola at `http://127.0.0.1:1111`. `just test` runs local checks; `just build` writes `public/`. Content lives in `content/blog/` and uses Zola tags.
- Preserve keyboard navigation and visible focus, semantic landmarks and the skip link, sufficient contrast, and support for users' motion and color-scheme preferences.
- For Impeccable raster assets in Pi, see [subscription image generation](docs/image-generation.md) for the tool, sign-in, and transparency limits.
- Leave future architecture, the redesign's visual system, additional data rules, and reputation measurement open until there's a concrete decision. Check available models before choosing one and weigh quality, cost, latency, and data handling.
