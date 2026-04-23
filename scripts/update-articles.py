#!/usr/bin/env python3
"""Add descriptions and cover images to all blog posts."""

import os
import re
from pathlib import Path

BLOG_DIR = Path("/Users/jwilger/projects/blog/content/blog")

# Article metadata: (filename, description, unsplash_cover_url)
ARTICLES = [
    (
        "acceptance-and-integration-testing-with-kookaburra.md",
        "How we built Kookaburra to solve the fragility problem in Cucumber acceptance tests by isolating UI details from test specifications.",
        "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=800&q=80"
    ),
    (
        "apprenticeship-program-at-renewable-funding-thoughts.md",
        "Designing an apprenticeship program to grow talent, contribute to open source, and build a stronger engineering community.",
        "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80"
    ),
    (
        "capybara-selenium-and-firefox-35.md",
        "A quick fix for Capybara timeout errors when running Selenium tests against older Firefox versions in CI.",
        "https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=800&q=80"
    ),
    (
        "complex-unique-constraints-with-postgresql-triggers-in-ecto.md",
        "Handling complex multi-column unique constraints in Ecto by leveraging PostgreSQL triggers and custom changeset validations.",
        None  # Already has cover from Hashnode
    ),
    (
        "elixir-ci-cd-with-artifact-promotion-fly-io.md",
        "A test article about CI/CD pipelines for Elixir applications deployed on Fly.io.",
        "https://images.unsplash.com/photo-1667372393119-c8f473882e8e?w=800&q=80"
    ),
    (
        "generative-ai-is-a-ux-revolution.md",
        "How conversational AI interfaces are breaking the GUI vs. CLI dichotomy and creating a new paradigm for human-computer interaction.",
        None  # Already has cover from Hashnode
    ),
    (
        "kookaburra-0240-released-exorcised-activesupport.md",
        "Removing the ActiveSupport dependency from Kookaburra to improve compatibility across Rails versions.",
        "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80"
    ),
    (
        "kookaburra-rewrite-for-0151.md",
        "Lessons learned from treating early versions as a spike and rewriting Kookaburra from the ground up with proper tests.",
        "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80"
    ),
    (
        "production-release-workflow-with-git.md",
        "Transforming a painful multi-hour release process into a five-minute, low-stress workflow using Git branching strategies.",
        "https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?w=800&q=80"
    ),
    (
        "retrospective-facilitation.md",
        "Practical techniques for facilitating effective team retrospectives that surface hidden issues before they become problems.",
        "https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80"
    ),
    (
        "the-hidden-pitfalls-of-ai-software-development.md",
        "How a $2,000 surprise from the Google Places API taught me that AI-assisted coding requires reviewing more than just the code.",
        None  # Already has cover from Hashnode
    ),
    (
        "the-language-model-is-just-another-user.md",
        "A CQRS-inspired approach to integrating LLMs: treat the language model as a user sending commands, not an internal system component.",
        None  # Already has cover from Hashnode
    ),
    (
        "the-tools-you-build-are-more-important-than-the-tools-you-use.md",
        "Why developers succeeding with AI coding assistants stop searching for perfect configurations and start building their own tools.",
        None  # Already has cover from Hashnode
    ),
    (
        "tmux-and-the-osx-clipboard.md",
        "Fixing clipboard integration between tmux and macOS using reattach-to-user-namespace.",
        "https://images.unsplash.com/photo-1629654297299-c8506221ca97?w=800&q=80"
    ),
    (
        "using-jeweler-for-private-gems.md",
        "Configuring Jeweler to manage private Ruby gems without accidentally publishing them to rubygems.org.",
        "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=800&q=80"
    ),
    (
        "using-the-27-lg-ultrafine-5k-display-with-linux.md",
        "Getting the LG UltraFine 5K display working reliably with Linux, including Thunderbolt AIC compatibility notes.",
        "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&q=80"
    ),
    (
        "what-it-really-means-to-be-agile.md",
        "Two simple questions that cut through process dogma to determine if your team is actually agile.",
        "https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800&q=80"
    ),
]

def update_article(filename, description, cover_url):
    filepath = BLOG_DIR / filename
    if not filepath.exists():
        print(f"  SKIP: {filename} not found")
        return

    content = filepath.read_text()

    # Extract front matter
    if not content.startswith("+++"):
        print(f"  SKIP: {filename} has no TOML front matter")
        return

    parts = content.split("+++", 2)
    if len(parts) < 3:
        print(f"  SKIP: {filename} invalid front matter")
        return

    fm = parts[1].strip()
    body = parts[2].strip()

    # Parse existing front matter
    lines = fm.split("\n")
    new_lines = []
    has_description = False
    has_extra = False
    has_taxonomies = False
    in_extra = False
    in_taxonomies = False

    for line in lines:
        if line.startswith("description"):
            has_description = True
            new_lines.append(f'description = "{description}"')
        elif line.startswith("[extra]"):
            in_extra = True
            has_extra = True
            new_lines.append(line)
        elif line.startswith("[taxonomies]"):
            in_taxonomies = True
            has_taxonomies = True
            new_lines.append(line)
        elif in_extra and line.strip() == "" and has_taxonomies:
            # End of extra section before taxonomies
            in_extra = False
            new_lines.append(line)
        elif in_extra and not line.startswith("  ") and not line.startswith("\t") and line.strip() != "":
            in_extra = False
            new_lines.append(line)
        elif in_taxonomies and not line.startswith("  ") and not line.startswith("\t") and line.strip() != "":
            in_taxonomies = False
            new_lines.append(line)
        else:
            new_lines.append(line)

    if not has_description:
        new_lines.insert(1, f'description = "{description}"')

    # Handle cover image
    if cover_url:
        # Check if we need to add [extra] section
        if not has_extra:
            # Insert before [taxonomies] or at end
            if has_taxonomies:
                # Find [taxonomies] line
                for i, line in enumerate(new_lines):
                    if line.startswith("[taxonomies]"):
                        new_lines.insert(i, "[extra]")
                        new_lines.insert(i + 1, f'cover = "{cover_url}"')
                        new_lines.insert(i + 2, "")
                        break
            else:
                new_lines.append("")
                new_lines.append("[extra]")
                new_lines.append(f'cover = "{cover_url}"')
        else:
            # Add cover to existing [extra]
            # Find [extra] and add cover after it
            for i, line in enumerate(new_lines):
                if line.startswith("[extra]"):
                    # Check if cover already exists
                    has_cover = any(new_lines[j].startswith("cover") for j in range(i+1, min(i+5, len(new_lines))))
                    if not has_cover:
                        new_lines.insert(i + 1, f'cover = "{cover_url}"')
                    break

    # Rebuild front matter
    new_fm = "\n".join(new_lines)
    new_content = f"+++\n{new_fm}\n+++\n\n{body}\n"

    filepath.write_text(new_content)
    print(f"  UPDATED: {filename}")

def main():
    print("Updating blog articles with descriptions and cover images...\n")
    for filename, description, cover_url in ARTICLES:
        update_article(filename, description, cover_url)
    print("\nDone!")

if __name__ == "__main__":
    main()
