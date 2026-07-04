#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../data"
DATA_FILE="${DATA_DIR}/projects.json"
GITHUB_USER="jwilger"
PREFERRED_OWNER="slipstream-eng"

mkdir -p "$DATA_DIR"

echo "Fetching pinned repositories for ${GITHUB_USER}..."

QUERY='{"query": "query { user(login: \"jwilger\") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name owner { login } description url stargazerCount primaryLanguage { name } } } } } }"}'

# Use GH_TOKEN or GITHUB_TOKEN for auth (required for GraphQL API)
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

if [ -z "$TOKEN" ] && command -v gh >/dev/null 2>&1; then
    TOKEN="$(gh auth token 2>/dev/null || true)"
fi

github_graphql() {
    if [ -n "$TOKEN" ]; then
        curl -sL -X POST https://api.github.com/graphql \
            -H "Authorization: Bearer ${TOKEN}" \
            -H "Content-Type: application/json" \
            -d "$QUERY" 2>/dev/null || echo ''
    else
        # Unauthenticated fallback (may hit rate limits)
        curl -sL -X POST https://api.github.com/graphql \
            -H "Content-Type: application/json" \
            -d "$QUERY" 2>/dev/null || echo ''
    fi
}

github_get() {
    local url="$1"

    if [ -n "$TOKEN" ]; then
        curl -sL "$url" \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${TOKEN}" 2>/dev/null || echo ''
    else
        curl -sL "$url" \
            -H "Accept: application/vnd.github+json" 2>/dev/null || echo ''
    fi
}

repo_response_to_project() {
    jq -c '
        select(type == "object" and (.owner.login? // "") != "" and (.html_url? // "") != "")
        | {
            name,
            owner: { login: .owner.login },
            description,
            url: .html_url,
            stargazerCount: .stargazers_count,
            primaryLanguage: (if .language then { name: .language } else null end)
        }
    ' 2>/dev/null || true
}

is_contributor() {
    local owner="$1"
    local name="$2"
    local contributors

    contributors="$(github_get "https://api.github.com/repos/${owner}/${name}/contributors?per_page=100")"
    echo "$contributors" | jq -e --arg user "$GITHUB_USER" 'type == "array" and any(.[]; .login == $user)' >/dev/null 2>&1
}

RESPONSE="$(github_graphql)"

if ! echo "$RESPONSE" | jq -e '.data.user.pinnedItems.nodes | type == "array"' >/dev/null 2>&1; then
    echo "Warning: Could not fetch projects from GitHub API. Response:"
    echo "$RESPONSE" | head -5
    echo '[]' > "$DATA_FILE"
    exit 0
fi

# Extract pinned repositories, preserving owner so moved repos still resolve.
PINNED_PROJECTS=$(echo "$RESPONSE" | jq '[.data.user.pinnedItems.nodes // [] | .[] | {name, owner, description, url, stargazerCount, primaryLanguage}]')

if [ -z "$PINNED_PROJECTS" ] || [ "$PINNED_PROJECTS" = "null" ]; then
    echo "Warning: No pinned repositories found. Using fallback."
    echo '[]' > "$DATA_FILE"
    exit 0
fi

FILTERED_PROJECTS='[]'

while IFS= read -r project; do
    owner="$(echo "$project" | jq -r '.owner.login // empty')"
    name="$(echo "$project" | jq -r '.name // empty')"
    selected_project=''

    if [ -z "$owner" ] || [ -z "$name" ]; then
        continue
    fi

    if [ "$owner" != "$PREFERRED_OWNER" ]; then
        preferred_response="$(github_get "https://api.github.com/repos/${PREFERRED_OWNER}/${name}")"
        preferred_project="$(echo "$preferred_response" | repo_response_to_project)"

        if [ -n "$preferred_project" ] && is_contributor "$PREFERRED_OWNER" "$name"; then
            selected_project="$preferred_project"
        fi
    fi

    if [ -z "$selected_project" ] && is_contributor "$owner" "$name"; then
        selected_project="$project"
    fi

    if [ -n "$selected_project" ]; then
        FILTERED_PROJECTS="$(jq -c --argjson project "$selected_project" '. + [$project]' <<< "$FILTERED_PROJECTS")"
    fi
done < <(echo "$PINNED_PROJECTS" | jq -c '.[]')

PROJECTS="$(echo "$FILTERED_PROJECTS" | jq '.')"

if [ -z "$PROJECTS" ] || [ "$PROJECTS" = "null" ]; then
    echo "Warning: No pinned repositories with ${GITHUB_USER} contributions found. Using fallback."
    echo '[]' > "$DATA_FILE"
    exit 0
fi

echo "$PROJECTS" > "$DATA_FILE"
echo "Projects saved to $DATA_FILE"
