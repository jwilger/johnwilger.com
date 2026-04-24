#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../data"
DATA_FILE="${DATA_DIR}/projects.json"

mkdir -p "$DATA_DIR"

echo "Fetching pinned repositories for jwilger..."

QUERY='{"query": "query { user(login: \"jwilger\") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name description url stargazerCount primaryLanguage { name } } } } } }"}'

# Use GH_TOKEN or GITHUB_TOKEN for auth (required for GraphQL API)
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

if [ -n "$TOKEN" ]; then
    RESPONSE=$(curl -sL -X POST https://api.github.com/graphql \
        -H "Authorization: bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$QUERY" 2>/dev/null || echo '')
else
    # Unauthenticated fallback (may hit rate limits)
    RESPONSE=$(curl -sL -X POST https://api.github.com/graphql \
        -H "Content-Type: application/json" \
        -d "$QUERY" 2>/dev/null || echo '')
fi

if [ -z "$RESPONSE" ] || echo "$RESPONSE" | grep -q '"errors"'; then
    echo "Warning: Could not fetch projects from GitHub API. Response:"
    echo "$RESPONSE" | head -5
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
