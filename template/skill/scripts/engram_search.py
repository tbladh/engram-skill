#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ENTRY_RE = re.compile(r"^(?P<date>\d{4}-\d{2}-\d{2})/(?P<sequence>\d+)-(?P<slug>[a-z0-9][a-z0-9-]*)$")
TEXT_EXTENSIONS = {
    ".adoc",
    ".cfg",
    ".conf",
    ".csv",
    ".env",
    ".ini",
    ".json",
    ".log",
    ".md",
    ".rst",
    ".text",
    ".toml",
    ".tsv",
    ".txt",
    ".yaml",
    ".yml",
}


def parse_entry(path: Path, branch_root: Path) -> tuple[str, str, int, str] | None:
    try:
        rel = path.relative_to(branch_root)
    except ValueError:
        return None
    if len(rel.parts) < 2:
        return None
    entry_rel = f"{rel.parts[0]}/{rel.parts[1]}"
    match = ENTRY_RE.match(entry_rel)
    if not match:
        return None
    return entry_rel, match.group("date"), int(match.group("sequence")), match.group("slug")


def has_any_file(path: Path) -> bool:
    return path.exists() and any(child.is_file() for child in path.rglob("*"))


def discover_entries(root: Path, docs_subdir: str, data_subdir: str) -> list[dict[str, object]]:
    docs_root = root / docs_subdir
    data_root = root / data_subdir
    entries: dict[str, dict[str, object]] = {}

    for branch, branch_root in (("docs", docs_root), ("data", data_root)):
        if not branch_root.exists():
            continue
        for date_dir in branch_root.iterdir():
            if not date_dir.is_dir():
                continue
            for entry_dir in date_dir.iterdir():
                if not entry_dir.is_dir():
                    continue
                parsed = parse_entry(entry_dir, branch_root)
                if not parsed:
                    continue
                entry_rel, date, sequence, slug = parsed
                entry = entries.setdefault(
                    entry_rel,
                    {
                        "entry_rel": entry_rel,
                        "date": date,
                        "sequence": sequence,
                        "slug": slug,
                        "docs_dir": str(docs_root / entry_rel),
                        "data_dir": str(data_root / entry_rel),
                        "docs_dir_exists": (docs_root / entry_rel).exists(),
                        "data_dir_exists": (data_root / entry_rel).exists(),
                        "has_docs": False,
                        "has_data": False,
                    },
                )
                entry[f"{branch}_dir_exists"] = entry_dir.exists()
                entry[f"has_{branch}"] = has_any_file(entry_dir)

    return sorted(entries.values(), key=lambda item: (str(item["date"]), int(item["sequence"])), reverse=True)


def list_entries(args: argparse.Namespace) -> list[dict[str, object]]:
    root = Path.home() / args.home_root_name
    entries = discover_entries(root, args.docs_subdir, args.data_subdir)

    if args.query:
        needle = args.query.lower()
        entries = [
            entry
            for entry in entries
            if needle in str(entry["entry_rel"]).lower() or needle in str(entry["slug"]).lower()
        ]

    return entries[: args.limit]


def iter_text_files(path: Path) -> list[Path]:
    if not path.exists():
        return []
    files: list[Path] = []
    for child in path.rglob("*"):
        if child.is_file() and child.suffix.lower() in TEXT_EXTENSIONS:
            files.append(child)
    return files


def grep_entries(args: argparse.Namespace) -> list[dict[str, object]]:
    root = Path.home() / args.home_root_name
    docs_root = root / args.docs_subdir
    entries = discover_entries(root, args.docs_subdir, args.data_subdir)
    pattern = args.pattern
    needle = pattern.lower()
    results: list[dict[str, object]] = []

    for entry in entries:
        docs_dir = Path(str(entry["docs_dir"]))
        for file_path in iter_text_files(docs_dir):
            try:
                text = file_path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue

            for line_no, line in enumerate(text.splitlines(), start=1):
                haystack = line if args.case_sensitive else line.lower()
                target = pattern if args.case_sensitive else needle
                if target in haystack:
                    result = dict(entry)
                    result.update(
                        {
                            "file": str(file_path),
                            "file_rel": str(file_path.relative_to(docs_root)),
                            "line": line_no,
                            "preview": line.strip()[:240],
                        }
                    )
                    results.append(result)
                    break
            if len(results) >= args.limit:
                return results

    return results


def emit(result: object, as_json: bool) -> None:
    if as_json:
        print(json.dumps(result, indent=2, sort_keys=True))
        return

    if not result:
        print("No matches.")
        return

    if isinstance(result, list):
        for item in result:
            line = str(item.get("entry_rel", item))
            if "file_rel" in item:
                line = f"{line} {item['file_rel']}:{item['line']} {item['preview']}"
            print(line)
        return

    print(result)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Search saved engram entries.")
    parser.add_argument("--home-root-name", default="__HOME_ROOT_NAME__")
    parser.add_argument("--docs-subdir", default="__DOCS_SUBDIR__")
    parser.add_argument("--data-subdir", default="__DATA_SUBDIR__")

    subparsers = parser.add_subparsers(dest="command", required=True)

    list_parser = subparsers.add_parser("list", help="List recent entries.")
    list_parser.add_argument("--query", help="Filter by entry path or slug.")
    list_parser.add_argument("--limit", type=int, default=20)
    list_parser.add_argument("--json", action="store_true")
    list_parser.set_defaults(handler=list_entries)

    grep_parser = subparsers.add_parser("grep", help="Search text files under docs.")
    grep_parser.add_argument("pattern", help="Plain text to search for.")
    grep_parser.add_argument("--case-sensitive", action="store_true")
    grep_parser.add_argument("--limit", type=int, default=20)
    grep_parser.add_argument("--json", action="store_true")
    grep_parser.set_defaults(handler=grep_entries)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    result = args.handler(args)
    emit(result, getattr(args, "json", False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
