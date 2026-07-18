# Engram Repo

This repository builds and distributes a portable skill plus installer for Codex, Claude, and Cursor.

## Source Of Truth

`AGENTS.md` is the shared instruction file for this repo.

- Keep shared repo guidance here.
- Keep `CLAUDE.md`, `.cursorrules`, and `.cursor/rules/*.mdc` as thin bridges back to this file.
- Do not move skill behavior notes into those bridge files unless a harness requires a format that `AGENTS.md` cannot express.

## Objective

Maintain a rename-friendly skill that helps an agent save work into a predictable home-folder structure:

- Text and source-control-friendly artifacts: `~/engram/docs/YYYY-MM-DD/{nn}-{slug}`
- Large, binary, or dump-style artifacts: `~/engram/data/YYYY-MM-DD/{nn}-{slug}`

The user should only need to specify what to save, not where to save it.

## Repo Layout

- `template/skill/`: Portable skill source with placeholders.
- `config/defaults.env`: Centralized naming and path defaults.
- `scripts/render_skill.py`: Render the template into a concrete skill folder.
- `install.sh`: Global installer for Codex, Claude, and Cursor.

## Feature Completeness

- [x] Rename-friendly rendering from a generic skill template and centralized path/name configuration.
- [x] Portable `SKILL.md` with automatic-use trigger guidance for reports, notes, drafts, work samples, and saved-work search.
- [x] Chronological text record structure at `~/engram/docs/YYYY-MM-DD/{nn}-{slug}`.
- [x] Paired large/binary artifact structure at `~/engram/data/YYYY-MM-DD/{nn}-{slug}`, created only when data exists.
- [x] One active entry per interaction, including an explicit prompt to confirm a shift to a new work item.
- [x] Deterministic standard-library Python helper for entry creation, reuse, sequence allocation, and JSON path results.
- [x] Search helper for listing entries and searching supported text files in `docs`.
- [x] POSIX shell, PowerShell, and `cmd.exe` launchers for the bundled Python helpers.
- [x] Self-healing guidance for missing directories, non-executable POSIX launchers, shell-specific launchers, and missing Python. ⚠ The prompting still needs a no-Python fallback that creates the required paths directly when the harness can write files.
- [x] Global installer targets for Codex, Claude, and Cursor, with per-target selection and replacement confirmation. ⚠ The installer is Bash-only, so native Windows requires Git Bash or WSL.
- [x] Copy-based replacement install, preserving a standalone copy for each target harness. ⚠ Installing legacy `~/.codex/skills` alongside `~/.agents/skills` can create duplicate discovery in other harnesses and should be reconsidered.
- [x] Remote installer support through an explicit GitHub archive URL. ⚠ A standalone raw `install.sh` URL cannot yet satisfy the intended single-command bootstrap without `ENGRAM_REPO_ARCHIVE_URL` being supplied.
- [x] Root-level instruction bridges for Claude and Cursor, with `AGENTS.md` as the source of truth.
- [ ] Kiro support.
- [ ] ⚠ Portable absolute skill-directory resolution in the prompting. The current `scripts/...` commands resolve relative to the workspace, not the installed skill directory.
- [ ] ⚠ Search coverage for common source-control-friendly text extensions beyond the current allowlist.
- [ ] ⚠ Explicit persistence and home-directory approval guidance. A skill can guide invocation but cannot mechanically guarantee that an agent saves every matching response; the prompt should require a file artifact and request scoped permission for `~/engram` when the harness blocks home-directory writes.
- [ ] ⚠ End-to-end installation and invocation validation in current Codex, Claude Code, and Cursor releases.

## Working Rules

- Keep the portable skill itself free of harness-specific behavior except for optional metadata files such as `agents/openai.yaml`.
- Update the installer, template, and config together when changing names or paths.
- Favor deterministic helper scripts for folder creation and path selection over prose-only instructions.
- Validate a rendered skill, not just the template source, before considering changes complete.
