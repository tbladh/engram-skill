#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import shutil
from pathlib import Path


def load_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        key, sep, value = line.partition("=")
        if not sep:
            raise ValueError(f"Invalid config line: {raw_line}")
        values[key.strip()] = value.strip()
    return values


def apply_env_overrides(values: dict[str, str]) -> dict[str, str]:
    merged = dict(values)
    for key in list(merged):
        if key in os.environ and os.environ[key]:
            merged[key] = os.environ[key]
    return merged


def render_text(text: str, replacements: dict[str, str]) -> str:
    rendered = text
    for key, value in replacements.items():
        rendered = rendered.replace(key, value)
    return rendered


def main() -> int:
    parser = argparse.ArgumentParser(description="Render the engram skill template.")
    parser.add_argument("--repo-root", required=True, help="Repository root path")
    parser.add_argument("--output-dir", required=True, help="Directory to write the rendered skill into")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    output_dir = Path(args.output_dir).resolve()
    config = apply_env_overrides(load_env_file(repo_root / "config" / "defaults.env"))
    template_root = repo_root / "template" / "skill"
    rendered_root = output_dir / config["PRODUCT_NAME"]

    replacements = {
        "__PRODUCT_NAME__": config["PRODUCT_NAME"],
        "__PRODUCT_TITLE__": config["PRODUCT_TITLE"],
        "__HOME_ROOT_NAME__": config["HOME_ROOT_NAME"],
        "__DOCS_SUBDIR__": config["DOCS_SUBDIR"],
        "__DATA_SUBDIR__": config["DATA_SUBDIR"],
    }

    shutil.copytree(template_root, rendered_root, dirs_exist_ok=True)

    for path in rendered_root.rglob("*"):
        if not path.is_file():
            continue
        source_mode = path.stat().st_mode
        text = path.read_text(encoding="utf-8")
        rendered_text = render_text(text, replacements)
        if "__PRODUCT_" in rendered_text or "__HOME_ROOT_NAME__" in rendered_text:
            raise ValueError(f"Unresolved placeholder found in {path}")
        path.write_text(rendered_text, encoding="utf-8")
        os.chmod(path, source_mode)

    print(rendered_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
