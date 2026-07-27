#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="${ROOT_DIR}/.agents/skills/narrate-blog-post"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

cat > "${TMP_DIR}/fixture.md" <<'EOF'
+++
title = "A Small Test"
slug = "canonical-test-slug"
date = 2026-07-26
+++

Opening prose with [useful link text](https://example.com).

```rust
fn implementation_detail() {
    println!("never narrate this source code");
}
```

| Date | Milestone |
| --- | --- |
| 2026-07-26 | Test |

## A heading that is not spoken

![An image that is not spoken](/image.png)

Closing prose.
EOF

actual_slug="$(
    python3 \
        "${SKILL_DIR}/scripts/extract-post.py" \
        "${TMP_DIR}/fixture.md" \
        --print-slug
)"

if [[ "$actual_slug" != "canonical-test-slug" ]]; then
    printf 'not ok - narration skill uses the front-matter slug as the output identity\n' >&2
    exit 1
fi

printf 'ok - narration skill uses the front-matter slug as the output identity\n'

mkdir -p "${TMP_DIR}/work"
printf 'obsolete speech' > "${TMP_DIR}/work/segment-99.pcm"

python3 \
    "${SKILL_DIR}/scripts/extract-post.py" \
    "${TMP_DIR}/fixture.md" \
    --output-dir "${TMP_DIR}/work"

if [[ -e "${TMP_DIR}/work/segment-99.pcm" ]]; then
    printf 'not ok - narration extraction clears stale rendered segments before a rerender\n' >&2
    exit 1
fi

printf 'ok - narration extraction clears stale rendered segments before a rerender\n'

expected_transcript='Opening prose with useful link text.

The relevant example code is available on my website.

A table referenced here is available on my website.

Closing prose.'
actual_transcript="$(cat "${TMP_DIR}/work/transcript.txt")"

if [[ "$actual_transcript" != "$expected_transcript" ]]; then
    printf 'not ok - narration skill extracts prose while preserving spoken link text\n' >&2
    exit 1
fi

printf 'ok - narration skill extracts prose and replaces code examples and tables\n'

expected_signoff="I'm John Wilger, and you've been listening to A Small Test, published on July 26, 2026, and copyright 2026, all rights reserved. You can read or listen to more of my work at johnwilger.com."
actual_signoff="$(cat "${TMP_DIR}/work/signoff.txt")"

if [[ "$actual_signoff" != "$expected_signoff" ]]; then
    printf 'not ok - narration skill derives the standard sign-off from post metadata\n' >&2
    exit 1
fi

printf 'ok - narration skill derives the standard sign-off from post metadata\n'

ffmpeg \
    -y \
    -loglevel error \
    -f lavfi \
    -i 'sine=frequency=180:sample_rate=24000:duration=0.2' \
    -f s16le \
    -ac 1 \
    "${TMP_DIR}/work/segment-01.pcm"

ffmpeg \
    -y \
    -loglevel error \
    -f lavfi \
    -i 'anullsrc=sample_rate=24000:channel_layout=mono:duration=4' \
    -f s16le \
    -ac 1 \
    "${TMP_DIR}/work/signoff.pcm"

"${SKILL_DIR}/scripts/assemble-audio.sh" \
    "${TMP_DIR}/work" \
    "${TMP_DIR}/a-small-test.mp3" \
    >/dev/null

duration="$(
    ffprobe \
        -v error \
        -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 \
        "${TMP_DIR}/a-small-test.mp3"
)"

if ! awk "BEGIN { exit !(${duration} > 19) }"; then
    printf 'not ok - narration skill assembles both stingers, narration, and sign-off\n' >&2
    exit 1
fi

printf 'ok - narration skill assembles both stingers, narration, and sign-off\n'

signoff_tail_mean_db="$(
    ffmpeg \
        -hide_banner \
        -sseof -1 \
        -i "${TMP_DIR}/work/signoff-room-tone.wav" \
        -af 'highpass=f=1000,volumedetect' \
        -f null /dev/null \
        2>&1 |
        sed -n 's/.*mean_volume: \([-0-9.]*\) dB.*/\1/p'
)"

if ! awk "BEGIN { exit !(${signoff_tail_mean_db} > -75) }"; then
    printf 'not ok - room tone remains audible through a sign-off longer than the article (tail mean %s dB)\n' "$signoff_tail_mean_db" >&2
    exit 1
fi

printf 'ok - room tone remains audible through a sign-off longer than the article\n'
