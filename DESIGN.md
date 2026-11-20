---
name: John Wilger
description: A quiet editorial publication, anchored by a natural portrait and a low alpine ridgeline.
colors:
  primary: "#22536c"
  link-hover: "#122e40"
  sky: "#e5edf0"
  ink: "#182f3b"
  muted: "#495e68"
  rule: "#92a3aa"
  sheet: "#e5edf0"
  mark: "#214859"
  mark-ink: "#fff"
  code: "#e7eef1"
  focus: "#22536c"
  ridge-far: "#c7d8df"
  ridge-near: "#abc3cd"
typography:
  display:
    fontFamily: 'Bodoni Moda, Georgia, "Times New Roman", serif'
    fontWeight: 500
    lineHeight: 1.04
    letterSpacing: "-0.038em"
  headline:
    fontFamily: 'Bodoni Moda, Georgia, "Times New Roman", serif'
    fontWeight: 500
    lineHeight: 1.12
    letterSpacing: "-0.032em"
  body:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "1.0625rem"
    fontWeight: 400
    lineHeight: 1.55
  reading:
    fontFamily: 'Georgia, "Times New Roman", serif'
    fontWeight: 400
    lineHeight: 1.68
  label:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 650
  code:
    fontFamily: "ui-monospace, SFMono-Regular, Consolas, monospace"
spacing:
  space-1: "0.5rem"
  space-2: "1rem"
  space-3: "1.5rem"
  space-4: "2rem"
  space-5: "3rem"
components:
  navigation:
    textColor: "{colors.ink}"
  read-action:
    textColor: "{colors.primary}"
  read-action-hover:
    textColor: "{colors.link-hover}"
  editorial-sheet:
    backgroundColor: "{colors.sheet}"
    textColor: "{colors.ink}"
    padding: "{spacing.space-3}"
  ridgeline-compact:
    height: "1.85rem"
---

# Design System: John Wilger

## Overview

**Creative North Star: "Portrait and Ridgeline"**

A natural portrait introduces the person behind the writing. A low, two-layer ridge echoes the terrain in the photo: distinct enough to see, quiet enough to leave the words and portrait in charge. This is a personal publication for engineers and engineering leaders, not an engineering console or an extension of 10kR’s brand.

### Key Characteristics
- Natural portrait and minimal terrain.
- Cool paper, slate ink, and thin rules.
- Editorial headlines, plainspoken copy, and a quiet reading column.

## Colors

The site uses one light palette. Browser forced colors remain supported.

- **Primary:** Slate-blue links (`--link`) carry actions, with a deeper tone on hover. Keep article title links in ink where the list treatment calls for it; the underline does the work.
- **Neutrals:** Sky is the ground across the site, including long reads. Use ink for type, muted slate for metadata, and thin rules for separation. Use spacing rather than colored panels around article navigation; code has its own tint.
- **Interaction and terrain:** Use the focus color for keyboard outlines and the mark/mark-ink pair for text selection. Use the near/far colors only for decorative terrain, never for text or status.

## Typography

Use **Bodoni Moda** for balanced headings, not for reading paragraphs. The masthead uses `clamp(3.2rem, 6.65vw, 6rem)` before narrower overrides; default H1, H2, and H3 use `clamp(2.75rem, 6.5vw, 5.75rem)`, `clamp(1.55rem, 3vw, 2.5rem)`, and `clamp(1.2rem, 2.1vw, 1.55rem)` respectively. **Hanken Grotesk** is for navigation, introductions, and metadata. Use **Georgia** for sustained reading (`clamp(1.125rem, 1.12rem + 0.24vw, 1.3rem)`) and editorial excerpts; reserve monospace for code.

**Font provenance.** The Latin variable WOFF2s were downloaded independently from their canonical Google Fonts URLs. The local files match the upstream downloads byte-for-byte and are served same-origin at runtime with `font-display: swap`.

- [`static/fonts/bodoni-moda-latin-v28.woff2`](static/fonts/bodoni-moda-latin-v28.woff2) — [Google Fonts WOFF2](https://fonts.gstatic.com/s/bodonimoda/v28/aFTH7PxzY382XsXX63LUYL6GYFcan6NJrKp-VPj1KOxQVAS1Eg.woff2), SHA-256 `c1de3473cec36815a9cfb203f3b6202971e26ac642017d08f097df2368cfe195`. [Local OFL](static/fonts/bodoni-moda-OFL.txt) matches [google/fonts at `634558fcbd9225a88591dec164f9fdb2716d0bf5`](https://github.com/google/fonts/blob/634558fcbd9225a88591dec164f9fdb2716d0bf5/ofl/bodonimoda/OFL.txt).
- [`static/fonts/hanken-grotesk-latin-v12.woff2`](static/fonts/hanken-grotesk-latin-v12.woff2) — [Google Fonts WOFF2](https://fonts.gstatic.com/s/hankengrotesk/v12/ieVn2YZDLWuGJpnzaiwFXS9tYtpd59CxCis4.woff2), SHA-256 `1f21c6eaa0000f3329cfcfac966b43d5bebf5aa610303e33294ac31bc6f4bb59`. [Local OFL](static/fonts/hanken-grotesk-OFL.txt) matches [google/fonts at `714891563e901b1a0d8ebcaaa003b01604793888`](https://github.com/google/fonts/blob/714891563e901b1a0d8ebcaaa003b01604793888/ofl/hankengrotesk/OFL.txt).

## Layout

Center the editorial frame (up to `72rem`) with fluid gutters (`clamp(1.2rem, 5vw, 5rem)`). Keep the reading measure at `63ch`. Let navigation wrap and let aligned, ruled rows give way to stacked content as space narrows; don’t compress the type to keep columns.

The portrait and introduction sit side by side on wide screens; the ridge sits below the copy. At `45rem` and below, the portrait comes first in a wider crop that stops growing at `13.75rem` high (see [`sass/_home.scss`](sass/_home.scss)), followed by the introduction and then the ridge in flow, aligned to the end. The ridge never sits behind text.

On articles, pair the headline, standfirst, and date with any local cover in one opener; use a wider text-only opener if there’s no local cover. A fine rule separates the opener from the reading column. The collapsed contents disclosure sits in the margin on wide screens and directly above the prose at `50rem` and below (see [`sass/_article.scss`](sass/_article.scss)).

## Elevation & Depth

Use flat surfaces, whitespace, and hairline rules rather than shadows. The muted near and far silhouettes give the terrain depth; soft fades at the ends let it meet the sky ground without a hard edge. Keep it static: hover and focus changes are immediate, and reduced-motion readers get the same composition without a reveal or parallax.

## Shapes

Use square-edged image crops, sheets, and controls. Keep the irregular silhouette specific to terrain, not a shape for buttons or containers. Reuse the natural alpine portrait at [`static/images/profile.jpg`](static/images/profile.jpg) as a photograph, not a graphic texture. This handoff does not establish its original authorship or license. Article openers use existing local cover art, decorative unless `cover_alt` deliberately describes the image. External cover URLs are reserved for social previews (see [`templates/blog-page.html`](templates/blog-page.html)).

## Components

- **Navigation and actions:** Use bold text links for navigation and explicit reading actions rather than filled buttons. Underline the current navigation location and expose it via `aria-current`. Keep prose links underlined; hover thickens the underline. Navigation and main reading actions have a `2.75rem` minimum block size.
- **Editorial rows and contents:** Separate list rows with `1px` rules. Contents use a native disclosure on the page background, with no card or fill.
- **Wide diagrams:** Scroll horizontally in place without widening the page. Keep the scroll region keyboard-focusable with a visible focus indicator (see [`sass/_components.scss`](sass/_components.scss)).
- **Keyboard and system settings:** Preserve the skip link and semantic header, navigation, main, and footer. Use a `3px` focus-visible outline with a `4px` offset. In forced colors, use `Highlight` for focus and omit the decorative ridge. WCAG 2.1 AA is a requirement, not a conformance claim.

## Do's and Don'ts

- Do keep the portrait natural, the ridge legible but subordinate, and the reading ground free of decoration.
- Do use plain labels, visible link states, and a clear keyboard focus indicator.
- Don't imitate 10kR or dress the publication as an engineering console.
- Don't turn the portrait into a costume, the terrain into a spectacle, or the copy into editorial affectation.
