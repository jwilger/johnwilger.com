#!/usr/bin/env python3
"""Migrate blog posts from jwilger/blog repo to Zola content format."""

import base64
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

REPO = "jwilger/blog"
DEST_DIR = Path(__file__).parent.parent / "content" / "blog"

def run_gh(args):
    """Run gh CLI and return parsed JSON output."""
    result = subprocess.run(
        ["gh", "api"] + args,
        capture_output=True,
        text=True,
        check=True
    )
    return json.loads(result.stdout)

def parse_date(date_str):
    """Parse Hashnode date format to YYYY-MM-DD."""
    # Example: Tue Mar 12 2024 18:47:59 GMT+0000 (Coordinated Universal Time)
    try:
        # Extract just the date part before the time
        match = re.match(r'\w{3}\s+(\w{3})\s+(\d{1,2})\s+(\d{4})', date_str)
        if match:
            month_str, day, year = match.groups()
            month_map = {
                'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            }
            month = month_map.get(month_str, 1)
            return f"{year}-{month:02d}-{int(day):02d}"
    except Exception:
        pass
    
    # Try ISO format
    try:
        dt = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
        return dt.strftime('%Y-%m-%d')
    except Exception:
        pass
    
    return None

def convert_front_matter(yaml_text):
    """Convert Hashnode YAML front matter to Zola TOML."""
    lines = yaml_text.strip().split('\n')
    data = {}
    
    for line in lines:
        line = line.strip()
        if not line or line == '---':
            continue
        if ':' in line:
            key, value = line.split(':', 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            data[key] = value
    
    # Build TOML
    toml_lines = ["+++"]
    
    if 'title' in data:
        title = data['title'].replace('"', '\\"')
        toml_lines.append(f'title = "{title}"')
    
    if 'slug' in data:
        toml_lines.append(f'slug = "{data["slug"]}"')
    
    if 'datePublished' in data:
        date = parse_date(data['datePublished'])
        if date:
            toml_lines.append(f'date = {date}')
    
    if 'cover' in data:
        toml_lines.append(f'[extra]')
        toml_lines.append(f'cover = "{data["cover"]}"')
    
    # Tags
    if 'tags' in data and data['tags']:
        tags = [t.strip() for t in data['tags'].split(',') if t.strip()]
        if tags:
            toml_lines.append('[taxonomies]')
            tags_str = ', '.join(f'"{t}"' for t in tags)
            toml_lines.append(f'tags = [{tags_str}]')
    
    toml_lines.append("+++")
    
    return '\n'.join(toml_lines)

def process_file(filename, content_b64):
    """Process a single blog post file."""
    content = base64.b64decode(content_b64).decode('utf-8')
    
    # Split front matter and body
    if not content.startswith('---'):
        print(f"  Skipping {filename}: no front matter")
        return
    
    parts = content.split('---', 2)
    if len(parts) < 3:
        print(f"  Skipping {filename}: invalid front matter")
        return
    
    yaml_fm = parts[1]
    body = parts[2].strip()
    
    # Convert front matter
    toml_fm = convert_front_matter(yaml_fm)
    
    # Determine output filename from slug if available
    slug_match = re.search(r'slug:\s*(\S+)', yaml_fm)
    if slug_match:
        slug = slug_match.group(1).strip().strip('"').strip("'")
        output_name = f"{slug}.md"
    else:
        output_name = filename
    
    output_path = DEST_DIR / output_name
    
    # Write converted file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(toml_fm)
        f.write('\n\n')
        f.write(body)
    
    print(f"  Written: {output_path}")

def main():
    DEST_DIR.mkdir(parents=True, exist_ok=True)
    
    print(f"Fetching file list from {REPO}...")
    files = run_gh([f"repos/{REPO}/contents"])
    
    md_files = [
        f for f in files
        if f['type'] == 'file'
        and f['name'].endswith('.md')
        and f['name'] not in ('README.md', 'example-post.md')
    ]
    
    print(f"Found {len(md_files)} markdown files to migrate.\n")
    
    for file_info in md_files:
        filename = file_info['name']
        print(f"Processing {filename}...")
        
        # Download content
        file_data = run_gh([f"repos/{REPO}/contents/{filename}"])
        content_b64 = file_data['content']
        
        process_file(filename, content_b64)
    
    print(f"\nMigration complete! {len(md_files)} posts saved to {DEST_DIR}")

if __name__ == '__main__':
    main()
