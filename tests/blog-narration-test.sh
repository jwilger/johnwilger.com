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

narrated_post_html="$(cat "${TMP_DIR}/site/blog/somebody-has-to-design-the-factory/index.html")"

if [[ "$narrated_post_html" != *'<section class="post-narration" aria-labelledby="listen-to-this">'* ]]; then
    printf 'not ok - a narrated post exposes its audio near the top of the article\n' >&2
    exit 1
fi

printf 'ok - a narrated post exposes its audio near the top of the article\n'

rendered_audio_src="$(
    printf '%s' "$narrated_post_html" |
        sed -n 's/.*<source src="\([^"]*\)" type="[^"]*">.*/\1/p' |
        head -n 1
)"

if [[ "$rendered_audio_src" != "/audio/blog/somebody-has-to-design-the-factory.mp3" ]]; then
    printf 'not ok - the narrated post renders its configured audio URL\n' >&2
    exit 1
fi

printf 'ok - the narrated post renders its configured audio URL\n'

if [[ ! -s "${TMP_DIR}/site${rendered_audio_src}" ]]; then
    printf 'not ok - the narrated post audio URL resolves to a non-empty published file\n' >&2
    exit 1
fi

printf 'ok - the narrated post audio URL resolves to a non-empty published file\n'

disclosure_contract=(
    '<small class="post-narration-fine-print">'
    '<em>'
    'This narration uses an AI-generated voice.'
    '<a href="https://freesound.org/people/Breviceps/sounds/564237/">Retro Audio Logo</a> by Breviceps'
    '<a href="https://freesound.org/people/pushkin/sounds/215293/">01 room tone low frequency hvac</a> by pushkin'
    '<a href="https://creativecommons.org/publicdomain/zero/1.0/">CC0 1.0</a>'
)

for disclosure_fragment in "${disclosure_contract[@]}"; do
    if [[ "$narrated_post_html" != *"$disclosure_fragment"* ]]; then
        printf 'not ok - narration disclosure identifies AI voice use and credits the sound designers\n' >&2
        exit 1
    fi
done

printf 'ok - narration disclosure identifies AI voice use and credits the sound designers\n'
