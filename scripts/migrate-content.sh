#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${SCRIPT_DIR}/../content/blog"
REPO="jwilger/blog"

echo "Fetching blog posts from ${REPO}..."

# Get list of markdown files (excluding README.md and example-post.md)
FILES=$(gh api repos/${REPO}/contents --paginate --jq '.[] | select(.type == "file" and .name | endswith(".md") and .name != "README.md" and .name != "example-post.md") | .name')

for file in $FILES; do
  echo "Processing ${file}..."
  
  # Download file content
  CONTENT=$(gh api repos/${REPO}/contents/${file} --jq '.content' | base64 -d)
  
  # Extract YAML front matter and body
  if echo "$CONTENT" | head -1 | grep -q '^---'; then
    FRONT_MATTER=$(echo "$CONTENT" | sed -n '/^---/,/^---/p')
    BODY=$(echo "$CONTENT" | sed '1,/^---/d' | sed '1,/^---/d')
    
    # Parse YAML fields
    TITLE=$(echo "$FRONT_MATTER" | grep '^title:' | sed 's/^title: *//; s/^"//; s/"$//; s/^'