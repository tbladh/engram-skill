---
name: __PRODUCT_NAME__
description: Save reports, notes, drafts, work samples, and output artifacts into a predictable home-folder structure without asking where they should go. Use when the user wants to save a report, short note, markdown summary, email draft, Slack draft, copied text artifact, related data dump, or search previous saved work. Default to `~/__HOME_ROOT_NAME__/__DOCS_SUBDIR__/YYYY-MM-DD/{nn}-{slug}` for text and source-control-friendly material, and `~/__HOME_ROOT_NAME__/__DATA_SUBDIR__/YYYY-MM-DD/{nn}-{slug}` for large or binary artifacts when present. Keep one active entry for the current interaction until the user explicitly shifts to a different work item.
---

# __PRODUCT_TITLE__

## Quick Start

1. Pick a concise slug for the current interaction.
2. Create the docs entry with the launcher for the current shell:

```bash
scripts/engram-paths create --slug "your-slug" --json
```

3. Save markdown and other source-control-friendly text under the returned `docs_dir`.
4. If the task has bulky artifacts, create the matching data directory with `scripts/engram-paths ensure --entry-rel "<entry_rel>" --with-data --json`, then save those files under the returned `data_dir`.
5. Reuse the same entry for the rest of the interaction unless the user clearly changes topic. If that happens, point it out and ask whether to shift to a new entry.

## Workflow

### Establish the entry

- Unless you are continuing an existing engram interaction, create a new entry.
- Keep the returned `entry_rel`, `docs_dir`, and potential `data_dir` in working memory and reuse them.
- If you already know the active `entry_rel`, ensure the entry exists before saving more content:

```bash
scripts/engram-paths ensure --entry-rel "YYYY-MM-DD/01-example" --json
```

### Keep text in docs and bulky artifacts in data

- Use `docs` for markdown reports, notes, summaries, drafts, copied code or config snippets, and any other material that is suitable for source control.
- Use `data` for raw exports, large logs, archives, images, video, audio, database dumps, or any other large or binary material.
- If the task produces both kinds of output, keep the same `entry_rel` under both trees.
- A docs entry does not need a matching data directory. Create the data directory only when there is data to put there.
- Do not ask the user where to put something unless they explicitly want to override the default structure.

### Keep one active entry per interaction

- Treat the first created entry as the active entry for the interaction.
- Save follow-up reports, notes, and samples into that same entry when they belong to the same work item.
- If the request appears to drift into a different work item, say so plainly and ask whether to continue in the current pair or create a new one.

Use language like:

> We have been saving this interaction under `~/__HOME_ROOT_NAME__/__DOCS_SUBDIR__/...`, with bulky artifacts under the matching `~/__HOME_ROOT_NAME__/__DATA_SUBDIR__/...` path only when needed. This looks like a different work item. Do you want to keep using the current entry or open a new one?

### Write files with deliberate names

- Prefer clear markdown filenames such as `report.md`, `note.md`, `summary.md`, `email-draft.md`, `slack-draft.md`, or `artifact-index.md`.
- If you copy multiple text artifacts into `docs`, use filenames that make their purpose obvious.
- If you save multiple bulky artifacts into `data`, keep them grouped by purpose and preserve useful original filenames when possible.

## Search Previous Work

- List recent entries with:

```bash
scripts/engram-search list --limit 20 --json
```

- Search markdown and text files under `docs` with:

```bash
scripts/engram-search grep "search text" --limit 20 --json
```

- Use search before creating a new entry when the user asks to find, revisit, continue, summarize, or reuse previous saved work.

## Self-Healing

- Prefer the extensionless launchers: `scripts/engram-paths` and `scripts/engram-search`.
- In PowerShell, use `scripts\engram-paths.ps1` or `scripts\engram-search.ps1` if extensionless scripts do not run.
- In `cmd.exe`, use `scripts\engram-paths.cmd` or `scripts\engram-search.cmd`.
- If a launcher is not executable on POSIX, run it with `sh`, for example `sh scripts/engram-paths create --slug "your-slug" --json`.
- If Python is missing or not on `PATH`, tell the user that Engram needs Python 3 from the operating system package manager or python.org. Do not silently abandon the save; once Python is available, rerun the launcher and continue.
- If `~/__HOME_ROOT_NAME__` or a child directory is missing, create it. Missing directories are normal, not an error.
- If a matching `data` entry is missing, treat that as a text-only record unless the current task needs bulky artifacts.

## References

- Read `references/structure.md` when you need examples, naming guidance, or a quick classification reminder.
