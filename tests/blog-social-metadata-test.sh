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

python3 - "${TMP_DIR}/site/blog/somebody-has-to-design-the-factory/index.html" <<'PY'
from html.parser import HTMLParser
from pathlib import Path
import sys


class MetadataParser(HTMLParser):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.values = {}

    def handle_starttag(self, tag, attrs):
        if tag == "meta":
            fields = dict(attrs)
            key = fields.get("property") or fields.get("name")
            if key:
                self.values.setdefault(key, []).append(fields.get("content"))


title = "Somebody Has to Design the Factory"
description = ("Automated assembly lines created a second engineering profession, the one that designs the line. "
               "Software is acquiring its own, and the work belongs with a company's most experienced engineers.")
expected = {
    "og:type": "article",
    "og:site_name": "John Wilger",
    "og:title": title,
    "og:description": description,
    "og:url": "https://johnwilger.com/blog/somebody-has-to-design-the-factory/",
    "twitter:card": "summary_large_image",
    "twitter:title": title,
    "twitter:description": description,
    "twitter:image": "https://johnwilger.com/images/blog/somebody-has-to-design-the-factory-cover.png",
}
parser = MetadataParser()
parser.feed(Path(sys.argv[1]).read_text(encoding="utf-8"))
for key, value in expected.items():
    if parser.values.get(key) != [value]:
        sys.exit(f"not ok - {key}: expected {[value]!r}, got {parser.values.get(key)!r}")
PY

printf 'ok - blog post exposes a complete social preview contract\n'

lazy_inline_image='<img src="/images/blog/somebody-has-to-design-the-factory-fitter-and-gauge.png" alt="On the left, a worker files one mismatched component until it fits; on the right, a fixed gauge rejects an out-of-tolerance component before it enters an automated line." loading="lazy">'

if [[ "$post_html" != *"$lazy_inline_image"* ]]; then
    printf 'not ok - below-the-fold raster illustration loads lazily\n' >&2
    exit 1
fi

printf 'ok - below-the-fold raster illustration loads lazily\n'
