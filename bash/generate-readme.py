#!/usr/bin/env python3
"""
Parses the alias/function definitions out of the shared configs repo (bash/commands/*.sh) plus
this repo's own bashrc_local.sh, and writes a Markdown reference to bash/README.md.

This is invoked by generate-readme.sh — do not run directly unless you know what you are doing.
"""

import re
import sys
from pathlib import Path

ALIAS_RE = re.compile(r'^alias\s+([A-Za-z0-9_-]+)=(.*)$')
FUNCTION_RE = re.compile(r'^([A-Za-z0-9_-]+)\s*\(\)\s*[{(]\s*$')
BANNER_RE = re.compile(r'^# -{3,}$')


def strip_comment(line: str) -> str:
    line = line.rstrip("\n")
    if line == "#":
        return ""
    return re.sub(r'^#\s?', "", line)


def extract_banner_title(lines: list[str]) -> str | None:
    """Grabs the title out of a "# ----\\n# Title\\n# ----" banner at the top of the file."""
    for i, line in enumerate(lines[:6]):
        if BANNER_RE.match(line.strip()) and i + 1 < len(lines):
            candidate = lines[i + 1].strip()
            if candidate.startswith("#"):
                return strip_comment(candidate)
    return None


def collect_preceding_comment(lines: list[str], index: int) -> str:
    """Walks upward from `index` collecting a contiguous block of "#" comment lines."""
    comment_lines: list[str] = []
    i = index - 1
    while i >= 0:
        stripped = lines[i].strip()
        if stripped.startswith("# ---") or stripped == "":
            break
        if stripped.startswith("#"):
            comment_lines.insert(0, strip_comment(stripped))
            i -= 1
            continue
        break
    return "\n".join(line for line in comment_lines if line != "").strip()


def parse_file(path: Path) -> tuple[str, list[dict]]:
    lines = path.read_text().splitlines()
    title = extract_banner_title(lines) or path.stem.replace("-", " ").replace("_", " ").title()

    entries = []
    seen_names = set()
    for i, raw_line in enumerate(lines):
        line = raw_line.strip()

        alias_match = ALIAS_RE.match(line)
        function_match = FUNCTION_RE.match(line) if not alias_match else None

        if alias_match:
            name, value = alias_match.group(1), alias_match.group(2).strip()
            value = value.strip('"').strip("'")
            kind = "alias"
        elif function_match:
            name = function_match.group(1)
            value = None
            kind = "function"
        else:
            continue

        if name in seen_names:
            continue
        seen_names.add(name)

        description = collect_preceding_comment(lines, i)
        entries.append(
            {
                "name": name,
                "kind": kind,
                "value": value,
                "description": description,
            }
        )

    return title, entries


def render_entry(entry: dict) -> str:
    out = [f"### `{entry['name']}`"]
    out.append("")
    if entry["description"]:
        out.append(entry["description"])
    elif entry["value"]:
        out.append(f"Shortcut for `{entry['value']}`.")
    else:
        out.append("_(undocumented)_")
    if entry["value"]:
        out.append("")
        out.append(f"```sh\nalias {entry['name']}=\"{entry['value']}\"\n```")
    out.append("")
    return "\n".join(out)


def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: generate-readme.py <configs-repo-path> <local-configs-bash-dir>", file=sys.stderr)
        sys.exit(1)

    configs_repo_path = Path(sys.argv[1])
    local_bash_dir = Path(sys.argv[2])

    commands_dir = configs_repo_path / "bash" / "commands"
    command_files = sorted(commands_dir.glob("*.sh"))

    sections = []
    for command_file in command_files:
        title, entries = parse_file(command_file)
        if not entries:
            continue
        sections.append((title, command_file.name, entries))

    local_bashrc = local_bash_dir / "bashrc_local.sh"
    if local_bashrc.is_file():
        title, entries = parse_file(local_bashrc)
        if entries:
            sections.append(("Personal Overrides (this repo)", local_bashrc.name, entries))

    out = []
    out.append("# Bash Command Reference")
    out.append("")
    out.append(
        "This is an auto-generated reference of every alias and helper function loaded by "
        "`.bash_profile` — most come from [Jeenil/configs](https://github.com/Jeenil/configs)'s "
        "`bash/commands/` directory, plus a few personal additions in `bashrc_local.sh` here."
    )
    out.append("")
    out.append(f"Regenerate this file after configs change by running `./generate-readme.sh`.")
    out.append("")
    out.append("## Table of Contents")
    out.append("")
    for title, filename, entries in sections:
        anchor = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
        count = len(entries)
        noun = "command" if count == 1 else "commands"
        out.append(f"- [{title}](#{anchor}) ({filename}) — {count} {noun}")
    out.append("")

    for title, filename, entries in sections:
        out.append(f"## {title}")
        out.append("")
        out.append(f"_Source: `{filename}`_")
        out.append("")
        for entry in entries:
            out.append(render_entry(entry))

    readme_path = local_bash_dir / "README.md"
    readme_path.write_text("\n".join(out).rstrip() + "\n")
    total = sum(len(entries) for _, _, entries in sections)
    print(f"Wrote {readme_path} with {total} documented commands across {len(sections)} sections.")


if __name__ == "__main__":
    main()
