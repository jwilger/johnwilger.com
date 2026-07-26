#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    printf 'usage: %s POST_MARKDOWN\n' "$0" >&2
    exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
POST_PATH="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
slug="$(
    python3 \
        "${SCRIPT_DIR}/extract-post.py" \
        "$POST_PATH" \
        --print-slug
)"
OUTPUT_MP3="${PROJECT_ROOT}/static/audio/blog/${slug}.mp3"
BUILD_ROOT="${PROJECT_ROOT}/.build/narration/${slug}"
RUNTIME_DIR="${BUILD_ROOT}/runtime"

for command_name in ffmpeg ffprobe node npm python3; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'missing required command: %s\n' "$command_name" >&2
        exit 1
    fi
done

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    printf 'OPENAI_API_KEY is required\n' >&2
    exit 1
fi

mkdir -p "$BUILD_ROOT" "$RUNTIME_DIR" "$(dirname "$OUTPUT_MP3")"

python3 \
    "${SCRIPT_DIR}/extract-post.py" \
    "$POST_PATH" \
    --output-dir "$BUILD_ROOT"

cp \
    "${SCRIPT_DIR}/package.json" \
    "${SCRIPT_DIR}/package-lock.json" \
    "${SCRIPT_DIR}/render-realtime.mjs" \
    "$RUNTIME_DIR/"

npm ci \
    --ignore-scripts \
    --cache "${PROJECT_ROOT}/.build/npm-cache" \
    --prefix "$RUNTIME_DIR"

node "${RUNTIME_DIR}/render-realtime.mjs" "$BUILD_ROOT"
"${SCRIPT_DIR}/assemble-audio.sh" "$BUILD_ROOT" "$OUTPUT_MP3"

metadata_json="${BUILD_ROOT}/metadata.json"
title="$(
    python3 -c \
        'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["title"])' \
        "$metadata_json"
)"

cat > "${BUILD_ROOT}/narration-frontmatter.toml" <<EOF
[extra.narration]
src = "/audio/blog/${slug}.mp3"
type = "audio/mpeg"

[[extra.narration.credits]]
title = "Retro Audio Logo"
creator = "Breviceps"
source_url = "https://freesound.org/people/Breviceps/sounds/564237/"
license = "CC0 1.0"
license_url = "https://creativecommons.org/publicdomain/zero/1.0/"

[[extra.narration.credits]]
title = "01 room tone low frequency hvac"
creator = "pushkin"
source_url = "https://freesound.org/people/pushkin/sounds/215293/"
license = "CC0 1.0"
license_url = "https://creativecommons.org/publicdomain/zero/1.0/"
EOF

printf 'title: %s\n' "$title"
printf 'front matter: %s\n' "${BUILD_ROOT}/narration-frontmatter.toml"
