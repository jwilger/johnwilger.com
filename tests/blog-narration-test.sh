#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

(
    cd "$ROOT_DIR"
    zola build --drafts --output-dir "${TMP_DIR}/site" >/dev/null
)

site="${TMP_DIR}/site"
test -f "$site/index.html"
test -f "$site/blog/somebody-has-to-design-the-factory/index.html"

if grep -Eril --include='*.html' --include='*.xml' \
    'post-narration|Listen to this|Audio available|/audio/blog/' "$site"; then
    printf 'not ok - generated pages and feeds do not advertise synthetic narration\n' >&2
    exit 1
fi
printf 'ok - generated pages and feeds do not advertise synthetic narration\n'

if [[ -d "$site/audio/blog" ]] && [[ -n "$(find "$site/audio/blog" -type f -print -quit)" ]]; then
    printf 'not ok - archived synthetic narration is not published as a static asset\n' >&2
    exit 1
fi
printf 'ok - archived synthetic narration is not published as a static asset\n'
