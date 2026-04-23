#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="${SCRIPT_DIR}/../data/projects.json"

echo "Fetching pinned repositories for jwilger..."

# Query GitHub GraphQL API for pinned repositories
QUERY='{"query": "query { user(login: \"jwilger\") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name description url stargazerCount primaryLanguage { name } } } } } }"}'

# Use gh CLI if authenticated, otherwise use curl with no auth (public data)
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    RESPONSE=$(gh api graphql -f query='query { user(login: "jwilger") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name description url stargazerCount primaryLanguage { name } } } } } }' 2>/dev/null || echo '')
else
    RESPONSE=$(curl -sL -X POST https://api.github.com/graphql \
        -H "Content-Type: application/json" \
        -d "$QUERY" 2>/dev/null || echo '')
fi

if [ -z "$RESPONSE" ] || echo "$RESPONSE" | grep -q '"errors"'; then
    echo "Warning: Could not fetch projects from GitHub API. Using fallback."
    echo '[]' > "$DATA_FILE"
    exit 0
fi

# Extract pinned repositories
PROJECTS=$(echo "$RESPONSE" | jq '[.data.user.pinnedItems.nodes // [] | .[] | {name, description, url, stargazerCount, primaryLanguage}]')

if [ -z "$PROJECTS" ] || [ "$PROJECTS" = "null" ]; then
    echo "Warning: No pinned repositories found. Using fallback."
    echo '[]' > "$DATA_FILE"
    exit 0
fi

echo "$PROJECTS" > "$DATA_FILE"
echo "Projects saved to $DATA_FILE"
