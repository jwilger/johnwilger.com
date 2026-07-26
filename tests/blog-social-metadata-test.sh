#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

(
    cd "$ROOT_DIR"
    zola build \
        --drafts \
        --output-dir "${TMP_DIR}/site" \
        >/dev/null
)

post_html="$(cat "${TMP_DIR}/site/blog/somebody-has-to-design-the-factory/index.html")"
expected='<meta property="og:image" content="https://johnwilger.com/images/blog/somebody-has-to-design-the-factory-cover.png">'

if [[ "$post_html" != *"$expected"* ]]; then
    printf 'not ok - local post cover is exposed as an absolute Open Graph image\n' >&2
    exit 1
fi

printf 'ok - local post cover is exposed as an absolute Open Graph image\n'

legacy_post_html="$(cat "${TMP_DIR}/site/blog/generative-ai-is-a-ux-revolution/index.html")"
legacy_cover='https://cdn.hashnode.com/res/hashnode/image/upload/v1709947871106/d67141a9-cb94-4a05-aaca-4cbade411abd.webp'
legacy_og_expected="<meta property=\"og:image\" content=\"${legacy_cover}\">"
legacy_twitter_expected="<meta name=\"twitter:image\" content=\"${legacy_cover}\">"

if [[ "$legacy_post_html" != *"$legacy_og_expected"* || "$legacy_post_html" != *"$legacy_twitter_expected"* ]]; then
    printf 'not ok - external post cover remains the social preview image URL\n' >&2
    exit 1
fi

printf 'ok - external post cover remains the social preview image URL\n'

social_metadata=(
    '<meta property="og:type" content="article">'
    '<meta property="og:site_name" content="John Wilger">'
    '<meta property="og:title" content="Somebody Has to Design the Factory">'
    '<meta property="og:description" content="&quot;Dark factory&quot; software development doesn&#x27;t mean typing an idea into a box. Automating assembly created a second engineering discipline, and that&#x27;s where senior judgment goes.">'
    '<meta property="og:url" content="https://johnwilger.com/blog/somebody-has-to-design-the-factory/">'
    '<meta name="twitter:card" content="summary_large_image">'
    '<meta name="twitter:title" content="Somebody Has to Design the Factory">'
    '<meta name="twitter:description" content="&quot;Dark factory&quot; software development doesn&#x27;t mean typing an idea into a box. Automating assembly created a second engineering discipline, and that&#x27;s where senior judgment goes.">'
    '<meta name="twitter:image" content="https://johnwilger.com/images/blog/somebody-has-to-design-the-factory-cover.png">'
)

for metadata in "${social_metadata[@]}"; do
    if [[ "$post_html" != *"$metadata"* ]]; then
        printf 'not ok - blog post exposes a complete social preview contract\n' >&2
        exit 1
    fi
done

printf 'ok - blog post exposes a complete social preview contract\n'

lazy_inline_image='<img src="/images/blog/somebody-has-to-design-the-factory-fitter-and-gauge.png" alt="On the left, a worker files one mismatched component until it fits; on the right, a fixed gauge rejects an out-of-tolerance component before it enters an automated line." loading="lazy">'

if [[ "$post_html" != *"$lazy_inline_image"* ]]; then
    printf 'not ok - below-the-fold raster illustration loads lazily\n' >&2
    exit 1
fi

printf 'ok - below-the-fold raster illustration loads lazily\n'
