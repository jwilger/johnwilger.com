#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    printf 'usage: %s WORK_DIR OUTPUT_MP3\n' "$0" >&2
    exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="$(cd "$1" && pwd)"
OUTPUT_DIR="$(cd "$(dirname "$2")" && pwd)"
OUTPUT_MP3="${OUTPUT_DIR}/$(basename "$2")"
STINGER="${SKILL_DIR}/assets/retro-audio-logo-cc0.mp3"
ROOM_TONE="${SKILL_DIR}/assets/room-tone-low-frequency-hvac-cc0.mp3"

cd "$WORK_DIR"

segment_pcm_files=(segment-*.pcm)
if [[ ! -e "${segment_pcm_files[0]}" ]]; then
    printf 'no rendered segment PCM files found in %s\n' "$WORK_DIR" >&2
    exit 1
fi

: > narration-concat.txt
for pcm_file in "${segment_pcm_files[@]}"; do
    stem="${pcm_file%.pcm}"
    ffmpeg \
        -y \
        -loglevel error \
        -f s16le \
        -ar 24000 \
        -ac 1 \
        -i "$pcm_file" \
        -c:a pcm_s16le \
        "${stem}.wav"
    printf "file '%s.wav'\n" "$stem" >> narration-concat.txt
done

ffmpeg \
    -y \
    -loglevel error \
    -f concat \
    -safe 0 \
    -i narration-concat.txt \
    -c:a pcm_s16le \
    full-narration-dry.wav

narration_duration="$(
    ffprobe \
        -v error \
        -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 \
        full-narration-dry.wav
)"

ffmpeg \
    -y \
    -loglevel error \
    -f s16le \
    -ar 24000 \
    -ac 1 \
    -i signoff.pcm \
    -c:a pcm_s16le \
    signoff-dry.wav

signoff_duration="$(
    ffprobe \
        -v error \
        -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 \
        signoff-dry.wav
)"

bed_target_duration="$(
    awk \
        "BEGIN { print (${narration_duration} > ${signoff_duration}) ? ${narration_duration} : ${signoff_duration} }"
)"

ffmpeg \
    -y \
    -loglevel error \
    -i "$ROOM_TONE" \
    -af 'highpass=f=60,lowpass=f=7000,volume=18' \
    -ar 24000 \
    -ac 1 \
    -c:a pcm_s16le \
    room-bed-00.wav

bed_file="room-bed-00.wav"
bed_duration="$(
    ffprobe \
        -v error \
        -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 \
        "$bed_file"
)"
bed_generation=0

while awk "BEGIN { exit !(${bed_duration} < ${bed_target_duration}) }"; do
    bed_generation=$((bed_generation + 1))
    next_bed="$(printf 'room-bed-%02d.wav' "$bed_generation")"
    ffmpeg \
        -y \
        -loglevel error \
        -i "$bed_file" \
        -filter_complex \
        '[0:a]asplit=2[a][b];[a][b]acrossfade=d=2:c1=tri:c2=tri[out]' \
        -map '[out]' \
        -c:a pcm_s16le \
        "$next_bed"
    bed_file="$next_bed"
    bed_duration="$(
        ffprobe \
            -v error \
            -show_entries format=duration \
            -of default=noprint_wrappers=1:nokey=1 \
            "$bed_file"
    )"
done

ffmpeg \
    -y \
    -loglevel error \
    -i "$bed_file" \
    -t "$narration_duration" \
    -c:a pcm_s16le \
    full-room-bed.wav

ffmpeg \
    -y \
    -loglevel error \
    -i "$bed_file" \
    -t "$signoff_duration" \
    -c:a pcm_s16le \
    signoff-room-bed.wav

ffmpeg \
    -y \
    -loglevel error \
    -i full-narration-dry.wav \
    -i full-room-bed.wav \
    -filter_complex \
    '[0:a][1:a]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.95[out]' \
    -map '[out]' \
    -c:a pcm_s16le \
    full-narration-room-tone.wav

ffmpeg \
    -y \
    -loglevel error \
    -i signoff-dry.wav \
    -i signoff-room-bed.wav \
    -filter_complex \
    '[0:a][1:a]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.95[out]' \
    -map '[out]' \
    -c:a pcm_s16le \
    signoff-room-tone.wav

ffmpeg \
    -y \
    -loglevel error \
    -i "$STINGER" \
    -af 'loudnorm=I=-18:TP=-3:LRA=7' \
    -ar 24000 \
    -ac 1 \
    -c:a pcm_s16le \
    retro-stinger-24k.wav

cat > final-concat.txt <<'EOF'
file 'retro-stinger-24k.wav'
file 'full-narration-room-tone.wav'
file 'retro-stinger-24k.wav'
file 'signoff-room-tone.wav'
EOF

title="$(
    python3 -c \
        'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["title"])' \
        metadata.json
)"

ffmpeg \
    -y \
    -loglevel error \
    -f concat \
    -safe 0 \
    -i final-concat.txt \
    -map_metadata -1 \
    -metadata "title=${title}" \
    -metadata artist='John Wilger' \
    -metadata comment='Narration generated with OpenAI Realtime (Cedar). Retro Audio Logo by Breviceps, CC0. Room tone by pushkin, CC0.' \
    -c:a libmp3lame \
    -b:a 192k \
    "$OUTPUT_MP3"

ffmpeg -v error -i "$OUTPUT_MP3" -f null /dev/null

if ffmpeg \
    -hide_banner \
    -i full-room-bed.wav \
    -af silencedetect=noise=-65dB:d=0.05 \
    -f null /dev/null \
    2>&1 |
    grep -q 'silence_start'; then
    printf 'continuous room-tone verification failed\n' >&2
    exit 1
fi

printf 'rendered %s\n' "$OUTPUT_MP3"
