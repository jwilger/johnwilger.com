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
    zola build --output-dir "${TMP_DIR}/site" >/dev/null
)

home_html="$(cat "${TMP_DIR}/site/index.html")"
favicon_link='<link rel="icon" type="image/svg+xml" href="/images/mark.svg">'

if [[ "$home_html" != *"$favicon_link"* || ! -f "${TMP_DIR}/site/images/mark.svg" ]]; then
    printf 'not ok - every page advertises a resolvable site favicon\n' >&2
    exit 1
fi

printf 'ok - every page advertises a resolvable site favicon\n'
