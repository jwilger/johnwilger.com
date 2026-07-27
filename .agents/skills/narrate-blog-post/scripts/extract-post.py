#!/usr/bin/env python3
"""Extract narration text and metadata from a Zola Markdown post."""

from __future__ import annotations

import argparse
import json
import re
import tomllib
from datetime import date, datetime
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("post", type=Path)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--print-slug", action="store_true")
    parser.add_argument("--max-segment-chars", type=int, default=1500)
    args = parser.parse_args()
    if not args.print_slug and args.output_dir is None:
        parser.error("--output-dir is required unless --print-slug is used")
    return args


def split_front_matter(source: str) -> tuple[dict[str, object], str]:
    parts = source.split("+++", 2)
    if len(parts) != 3 or parts[0].strip():
        raise ValueError("expected Zola TOML front matter delimited by +++")
    return tomllib.loads(parts[1]), parts[2].strip()


def replace_code_blocks(body: str) -> str:
    """Replace source code with a concise spoken pointer, never source text."""
    return re.sub(
        r"```[^\n]*\n.*?```",
        "\n\nThe relevant example code is available on my website.\n\n",
        body,
        flags=re.DOTALL,
    )


def strip_non_prose_blocks(body: str) -> str:
    body = replace_code_blocks(body)
    body = re.sub(
        r"(?:^\|.*\|\n)+",
        "\nA table referenced here is available on my website.\n",
        body,
        flags=re.MULTILINE,
    )
    body = re.sub(r"<div\b.*?</div>", "", body, flags=re.DOTALL | re.IGNORECASE)
    body = re.sub(r"<figure\b.*?</figure>", "", body, flags=re.DOTALL | re.IGNORECASE)
    body = re.sub(r"^\s*<img\b[^>]*>\s*$", "", body, flags=re.MULTILINE | re.IGNORECASE)
    body = re.sub(r"^\s*#{1,6}\s+.*$", "", body, flags=re.MULTILINE)
    body = re.sub(r"!\[[^\]]*]\([^)]*\)", "", body)
    return body


def strip_inline_markdown(body: str) -> str:
    previous = None
    while previous != body:
        previous = body
        body = re.sub(r"\[([^\]]+)]\((?:[^()]|\([^)]*\))*\)", r"\1", body)
    body = re.sub(r"<[^>]+>", "", body)
    body = re.sub(r"(?<!\\)[*_]{1,3}", "", body)
    body = body.replace("`", "")
    body = body.replace("\\*", "*").replace("\\_", "_")
    return body


def normalize_paragraphs(body: str) -> str:
    paragraphs: list[str] = []
    for paragraph in re.split(r"\n\s*\n", body):
        text = re.sub(r"\s+", " ", paragraph).strip()
        if text:
            paragraphs.append(text)
    return "\n\n".join(paragraphs)


def segment_text(text: str, max_chars: int) -> list[str]:
    segments: list[str] = []
    current = ""
    for paragraph in text.split("\n\n"):
        candidate = f"{current}\n\n{paragraph}" if current else paragraph
        if current and len(candidate) > max_chars:
            segments.append(current)
            current = paragraph
        else:
            current = candidate
    if current:
        segments.append(current)
    return segments


def human_date(value: date | datetime | str) -> tuple[str, int]:
    if isinstance(value, datetime):
        parsed = value.date()
    elif isinstance(value, date):
        parsed = value
    else:
        parsed = date.fromisoformat(str(value))
    return f"{parsed.strftime('%B')} {parsed.day}, {parsed.year}", parsed.year


def main() -> None:
    args = parse_args()
    front_matter, body = split_front_matter(args.post.read_text(encoding="utf-8"))
    title = str(front_matter["title"])
    slug = str(front_matter.get("slug") or args.post.stem)
    if args.print_slug:
        print(slug)
        return

    assert args.output_dir is not None
    publication_date, year = human_date(front_matter["date"])
    transcript = normalize_paragraphs(strip_inline_markdown(strip_non_prose_blocks(body)))
    segments = segment_text(transcript, args.max_segment_chars)
    signoff = (
        f"I'm John Wilger, and you've been listening to {title}, published on "
        f"{publication_date}, and copyright {year}, all rights reserved. You can "
        "read or listen to more of my work at johnwilger.com."
    )

    args.output_dir.mkdir(parents=True, exist_ok=True)
    for stale_segment in args.output_dir.glob("segment-*.pcm"):
        stale_segment.unlink()
    (args.output_dir / "transcript.txt").write_text(
        f"{transcript}\n", encoding="utf-8"
    )
    (args.output_dir / "segments.json").write_text(
        f"{json.dumps(segments, indent=2)}\n", encoding="utf-8"
    )
    (args.output_dir / "signoff.txt").write_text(f"{signoff}\n", encoding="utf-8")
    (args.output_dir / "metadata.json").write_text(
        json.dumps(
            {
                "title": title,
                "slug": slug,
                "publication_date": publication_date,
                "year": year,
                "segment_count": len(segments),
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
