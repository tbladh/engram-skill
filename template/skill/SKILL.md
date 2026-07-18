---
name: __PRODUCT_NAME__
description: Save reports, notes, drafts, work samples, and output artifacts into a predictable home-folder structure without asking where they should go. Use when the user wants to save a report, short note, markdown summary, email draft, Slack draft, copied text artifact, related data dump, or search previous saved work. Default to `~/__HOME_ROOT_NAME__/__DOCS_SUBDIR__/YYYY-MM-DD/{nn}-{slug}` for text and source-control-friendly material, and `~/__HOME_ROOT_NAME__/__DATA_SUBDIR__/YYYY-MM-DD/{nn}-{slug}` for large or binary artifacts when present. Keep one active entry for the current interaction until the user explicitly shifts to a different work item.
---

# __PRODUCT_TITLE__

## Non-Negotiable Outcome

When Engram is active for a save request, write the requested artifact before replying. Do not leave a report, note, draft, or sample only in chat.

- Save source-control-friendly text under `~/__HOME_ROOT_NAME__/__DOCS_SUBDIR__`.
- Save large or binary artifacts under `~/__HOME_ROOT_NAME__/__DATA_SUBDIR__` only when they exist.
- If the harness asks for permission to write outside the workspace, request approval limited to `~/__HOME_ROOT_NAME__`. Do not ask the user where to save the artifact.

## Quick Start

1. Resolve the absolute directory containing this `SKILL.md` as `<skill-dir>`. This is the installed skill directory, not the current workspace. In Claude Code, `${CLAUDE_SKILL_DIR}` is available; in other harnesses, use this skill's listed file path.
2. Pick a concise slug for the current interaction.
3. Create the docs entry with the launcher for the current shell:

```bash
<skill-dir>/scripts/engram-paths create --slug "your-slug" --json
```

4. Save markdown and other source-control-friendly text under the returned `docs_dir`.
5. If the task has bulky artifacts, create the matching data directory with `<skill-dir>/scripts/engram-paths ensure --entry-rel "<entry_rel>" --with-data --json`, then save those files under the returned `data_dir`.
6. Reuse the same entry for the rest of the interaction unless the user clearly changes topic. If that happens, point it out and ask whether to shift to a new entry.

## Helper Output Contract

- `create` and `ensure` create `docs_dir` before returning. If the command exits successfully, save text directly into `docs_dir`.
- `docs_dir_exists` and `data_dir_exists` report whether those directories exist.
- `docs_has_files` and `data_has_files` report whether those directories contain files.
- Legacy fields `has_docs` and `has_data` mean the same thing as `docs_has_files` and `data_has_files`; they do not mean the directory is missing.
- `data_dir` may be returned even when `data_dir_exists` is false. Only create or use it when bulky artifacts exist or `--with-data` was requested.

## Workflow

### Establish the entry

- Unless you are continuing an existing Engram interaction, create a new entry.
- Keep the returned `entry_rel`, `docs_dir`, and potential `data_dir` in working memory and reuse them.
- If you already know the active `entry_rel`, ensure the entry exists before saving more content:

```bash
<skill-dir>/scripts/engram-paths ensure --entry-rel "YYYY-MM-DD/01-example" --json
```

### Keep text in docs and bulky artifacts in data

- Use `docs` for markdown reports, notes, summaries, drafts, copied code or config snippets, and any other material suitable for source control.
- Use `data` for raw exports, large logs, archives, images, video, audio, database dumps, or any other large or binary material.
- If the task produces both kinds of output, keep the same `entry_rel` under both trees.
- A docs entry does not need a matching data directory. Create the data directory only when there is data to put there.
- Do not ask the user where to put something unless they explicitly want to override the default structure.

### Keep one active entry per interaction

- Treat the first created entry as the active entry for the interaction.
- Save follow-up reports, notes, and samples into that same entry when they belong to the same work item.
- If the request appears to drift into a different work item, say so plainly and ask whether to continue in the current pair or create a new entry.

Use language like:

> We have been saving this interaction under `~/__HOME_ROOT_NAME__/__DOCS_SUBDIR__/...`, with bulky artifacts under the matching `~/__HOME_ROOT_NAME__/__DATA_SUBDIR__/...` path only when needed. This looks like a different work item. Do you want to keep using the current entry or open a new one?

### Write files with deliberate names

- Prefer clear markdown filenames such as `report.md`, `note.md`, `summary.md`, `email-draft.md`, `slack-draft.md`, or `artifact-index.md`.
- If you copy multiple text artifacts into `docs`, use filenames that make their purpose obvious.
- If you save multiple bulky artifacts into `data`, keep them grouped by purpose and preserve useful original filenames when possible.

## Search Previous Work

- List recent entries with:

```bash
<skill-dir>/scripts/engram-search list --limit 20 --json
```

- Search source-control-friendly text files under `docs` with:

```bash
<skill-dir>/scripts/engram-search grep "search text" --limit 20 --json
```

- Use search before creating a new entry when the user asks to find, revisit, continue, summarize, or reuse previous saved work.

## Self-Healing

- Prefer the extensionless launchers at `<skill-dir>/scripts/engram-paths` and `<skill-dir>/scripts/engram-search`.
- In PowerShell, use `<skill-dir>\\scripts\\engram-paths.ps1` or `<skill-dir>\\scripts\\engram-search.ps1` if extensionless scripts do not run.
- In `cmd.exe`, use `<skill-dir>\\scripts\\engram-paths.cmd` or `<skill-dir>\\scripts\\engram-search.cmd`.
- If a launcher is not executable on POSIX, run it with `sh`, for example `sh <skill-dir>/scripts/engram-paths create --slug "your-slug" --json`.
- If Python is unavailable but the harness can write files, do not abandon the save. Inspect the date directory, choose the next available `{nn}`, create the docs directory with native file tools, and save the artifact. Create the paired data directory only when needed.
- If neither the helper nor native file tools can write the artifact, ask for approval or explain the exact tooling block. Do not replace the saved artifact with chat-only output.
- If `~/__HOME_ROOT_NAME__` or a child directory is missing, create it. Missing directories are normal, not an error.
- If a matching `data` entry is missing, treat that as a text-only record unless the current task needs bulky artifacts.

## References

- Read `references/structure.md` when you need examples, naming guidance, or a quick classification reminder.
