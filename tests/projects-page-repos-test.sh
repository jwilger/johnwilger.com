#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_FILE="${ROOT_DIR}/data/projects.json"
TMP_DIR="$(mktemp -d)"
HAD_DATA_FILE=0

cleanup() {
    if [ "$HAD_DATA_FILE" -eq 1 ]; then
        cp "${TMP_DIR}/projects.json.bak" "$DATA_FILE"
    else
        rm -f "$DATA_FILE"
    fi
    rmdir "${ROOT_DIR}/data" 2>/dev/null || true
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [ -f "$DATA_FILE" ]; then
    HAD_DATA_FILE=1
    cp "$DATA_FILE" "${TMP_DIR}/projects.json.bak"
fi

failures=0

assert() {
    local message="$1"
    shift

    if ! "$@"; then
        printf 'not ok - %s\n' "$message" >&2
        failures=$((failures + 1))
    else
        printf 'ok - %s\n' "$message"
    fi
}

contains() {
    local needle="$1"
    local haystack="$2"
    [[ "$haystack" == *"$needle"* ]]
}

does_not_contain() {
    local needle="$1"
    local haystack="$2"
    [[ "$haystack" != *"$needle"* ]]
}

keeps_pinned_contributor_repos() {
    jq -e '
        length == 2
        and (map(.url) | index("https://github.com/slipstream-eng/eventcore"))
        and (map(.url) | index("https://github.com/jwilger/personal-tool"))
    ' "$DATA_FILE" >/dev/null
}

excludes_pinned_non_contributor_repos() {
    jq -e 'map(.url) | index("https://github.com/example/not-my-repo") | not' "$DATA_FILE" >/dev/null
}

uses_github_project_descriptions() {
    jq -e '
        any(.[]; .url == "https://github.com/slipstream-eng/eventcore"
            and .description == "Rust event-sourcing library for commands that atomically read and write across multiple event streams.")
    ' "$DATA_FILE" >/dev/null
}

project_cards_do_not_render_star_counts() {
    local project_card_template

    project_card_template="$(sed -n '/macro project_card/,/endmacro/p' "${ROOT_DIR}/templates/macros.html")"
    does_not_contain 'stargazerCount' "$project_card_template" \
        && does_not_contain '⭐' "$project_card_template"
}

run_fetch_projects_with_stubbed_github() {
    mkdir -p "${TMP_DIR}/bin"

    cat > "${TMP_DIR}/bin/curl" <<'FAKE_CURL'
#!/usr/bin/env bash
set -euo pipefail

payload=''
url=''
auth_header=''

while [ "$#" -gt 0 ]; do
    case "$1" in
        -d)
            shift
            payload="${1:-}"
            ;;
        -H)
            shift
            header="${1:-}"
            if [[ "$header" == Authorization:* ]]; then
                auth_header="$header"
            fi
            ;;
        http://*|https://*)
            url="$1"
            ;;
    esac
    shift || true
done

if [[ "$url" == 'https://api.github.com/graphql' ]]; then
    printf '%s\n' "$payload" > "$PROJECTS_QUERY_LOG"
    printf '%s\n' "$auth_header" > "$AUTH_HEADER_LOG"

    if [[ "${REQUIRE_AUTH_HEADER:-0}" == '1' && "$auth_header" != 'Authorization: Bearer test-gh-token' ]]; then
        printf '{"message":"API rate limit exceeded"}\n'
        exit 0
    fi

    if [[ "$payload" != *'user(login: \"jwilger\")'* ]]; then
        printf '{"errors":[{"message":"expected personal pinned-items query"}]}\n'
        exit 0
    fi

    cat <<'JSON'
{
  "data": {
    "user": {
      "pinnedItems": {
        "nodes": [
          {
            "name": "eventcore",
            "owner": {
              "login": "jwilger"
            },
            "description": "Moved to a new owner.",
            "url": "https://github.com/jwilger/eventcore",
            "stargazerCount": 11,
            "primaryLanguage": {
              "name": "Rust"
            }
          },
          {
            "name": "not-my-repo",
            "owner": {
              "login": "example"
            },
            "description": "A pinned repo without jwilger contributions.",
            "url": "https://github.com/example/not-my-repo",
            "stargazerCount": 3,
            "primaryLanguage": {
              "name": "Go"
            }
          },
          {
            "name": "personal-tool",
            "owner": {
              "login": "jwilger"
            },
            "description": "A personal pinned repo with jwilger contributions.",
            "url": "https://github.com/jwilger/personal-tool",
            "stargazerCount": 7,
            "primaryLanguage": {
              "name": "Nix"
            }
          }
        ]
      }
    }
  }
}
JSON
    exit 0
fi

printf '%s\n' "$url" >> "$CONTRIBUTOR_URL_LOG"

case "$url" in
    *'/repos/slipstream-eng/eventcore')
        cat <<'JSON'
{
  "name": "eventcore",
  "owner": {
    "login": "slipstream-eng"
  },
  "description": "Rust event-sourcing library for commands that atomically read and write across multiple event streams.",
  "html_url": "https://github.com/slipstream-eng/eventcore",
  "stargazers_count": 42,
  "language": "Rust"
}
JSON
        ;;
    *'/repos/slipstream-eng/eventcore/contributors'*)
        printf '[{"login":"jwilger"},{"login":"other-contributor"}]\n'
        ;;
    *'/repos/jwilger/eventcore/contributors'*)
        printf '[{"login":"jwilger"}]\n'
        ;;
    *'/repos/example/not-my-repo/contributors'*)
        printf '[{"login":"someone-else"}]\n'
        ;;
    *'/repos/slipstream-eng/not-my-repo'|*'/repos/slipstream-eng/personal-tool')
        printf '{"message":"Not Found"}\n'
        ;;
    *'/repos/jwilger/personal-tool/contributors'*)
        printf '[{"login":"jwilger"}]\n'
        ;;
    *)
        printf '{"message":"unexpected contributors URL"}\n'
        ;;
esac
FAKE_CURL

    cat > "${TMP_DIR}/bin/gh" <<'FAKE_GH'
#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "auth" ] && [ "${2:-}" = "token" ]; then
    printf 'test-gh-token\n'
    exit 0
fi

exit 1
FAKE_GH

    chmod +x "${TMP_DIR}/bin/curl"
    chmod +x "${TMP_DIR}/bin/gh"
    : > "${TMP_DIR}/contributor-urls.txt"
    : > "${TMP_DIR}/auth-header.txt"

    if [ "${1:-env-token}" = "gh-token" ]; then
        env -u GH_TOKEN -u GITHUB_TOKEN \
            PROJECTS_QUERY_LOG="${TMP_DIR}/query.json" \
            CONTRIBUTOR_URL_LOG="${TMP_DIR}/contributor-urls.txt" \
            AUTH_HEADER_LOG="${TMP_DIR}/auth-header.txt" \
            REQUIRE_AUTH_HEADER=1 \
            PATH="${TMP_DIR}/bin:${PATH}" \
            bash "${ROOT_DIR}/scripts/fetch-projects.sh" > "${TMP_DIR}/fetch.log"
    else
        PROJECTS_QUERY_LOG="${TMP_DIR}/query.json" \
            CONTRIBUTOR_URL_LOG="${TMP_DIR}/contributor-urls.txt" \
            AUTH_HEADER_LOG="${TMP_DIR}/auth-header.txt" \
            GH_TOKEN="test-token" \
            PATH="${TMP_DIR}/bin:${PATH}" \
            bash "${ROOT_DIR}/scripts/fetch-projects.sh" > "${TMP_DIR}/fetch.log"
    fi
}

run_fetch_projects_with_stubbed_github

query="$(cat "${TMP_DIR}/query.json")"
contributor_urls="$(cat "${TMP_DIR}/contributor-urls.txt")"

assert "fetch-projects queries jwilger's personal pinned repositories" \
    contains 'user(login: \"jwilger\")' "$query"

assert "fetch-projects no longer treats slipstream-eng organization pins as the source list" \
    does_not_contain 'organization(login: \"slipstream-eng\")' "$query"

assert "fetch-projects checks contributor lists for pinned repositories" \
    contains '/repos/slipstream-eng/eventcore/contributors' "$contributor_urls"

assert "fetch-projects resolves moved personal pins to slipstream-eng repos by name" \
    contains '/repos/slipstream-eng/eventcore' "$contributor_urls"

assert "fetch-projects keeps pinned repositories where jwilger is a contributor" \
    keeps_pinned_contributor_repos

assert "fetch-projects uses GitHub project descriptions" \
    uses_github_project_descriptions

assert "fetch-projects excludes pinned repositories where jwilger is not a contributor" \
    excludes_pinned_non_contributor_repos

projects_page="$(cat "${ROOT_DIR}/content/projects.md")"

assert "Projects page links readers to the personal pinned GitHub profile" \
    contains '[GitHub](https://github.com/jwilger)' "$projects_page"

assert "Projects page copy does not link readers to slipstream-eng as the source list" \
    does_not_contain '[GitHub](https://github.com/slipstream-eng)' "$projects_page"

assert "Project cards do not render star counts" \
    project_cards_do_not_render_star_counts

run_fetch_projects_with_stubbed_github gh-token
gh_auth_header="$(cat "${TMP_DIR}/auth-header.txt")"

assert "fetch-projects falls back to gh auth token when token env vars are unset" \
    contains 'Authorization: Bearer test-gh-token' "$gh_auth_header"

assert "fetch-projects writes contributor-filtered pinned repos when using gh auth token" \
    keeps_pinned_contributor_repos

if [ "$failures" -gt 0 ]; then
    exit 1
fi
