# Engram Repo

This repository builds and distributes a portable skill plus installer for Codex, Claude, Cursor, and Kiro.

## Source Of Truth

`AGENTS.md` is the shared instruction file for this repo.

- Keep shared repo guidance here.
- Keep `CLAUDE.md`, `.cursorrules`, and `.cursor/rules/*.mdc` as thin bridges back to this file. Kiro can consume `AGENTS.md` directly.
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
- `install.sh` and `install.ps1`: Global installers for Codex, Claude, Cursor, and Kiro.

## Feature Completeness

- [x] Rename-friendly rendering from a generic skill template and centralized path/name configuration.
- [x] Portable `SKILL.md` with automatic-use trigger guidance for reports, notes, drafts, work samples, and saved-work search.
- [x] Chronological text record structure at `~/engram/docs/YYYY-MM-DD/{nn}-{slug}`.
- [x] Paired large/binary artifact structure at `~/engram/data/YYYY-MM-DD/{nn}-{slug}`, created only when data exists.
- [x] One active entry per interaction, including an explicit prompt to confirm a shift to a new work item.
- [x] Deterministic standard-library Python helper for entry creation, reuse, sequence allocation, and JSON path results.
- [x] Search helper for listing entries and searching supported text files in `docs`.
- [x] POSIX shell, PowerShell, and `cmd.exe` launchers for the bundled Python helpers.
- [x] Self-healing guidance for missing directories, shell-specific launchers, unavailable Python, and unavailable write permissions.
- [x] Global Bash and PowerShell installers for Codex, Claude, Cursor, and Kiro, with per-target selection and replacement confirmation.
- [x] Staged copy-based replacement install that restores the previous version if activation fails. Legacy `~/.codex/skills` installation is opt-in.
- [x] Single-command remote bootstrap with configured GitHub archive URLs and explicit environment overrides.
- [x] Root-level instruction bridges for Claude and Cursor, with `AGENTS.md` as the source of truth.
- [x] Kiro global skill installation at `~/.kiro/skills/engram`, including Bash and PowerShell target selection.
- [x] Portable absolute skill-directory resolution in the prompting, including Claude Code's skill-directory variable.
- [x] Search coverage for UTF-8 text files in `docs`, regardless of extension, with binary and oversized-file safeguards.
- [x] Explicit persistence and scoped home-directory approval guidance.
- [ ] ⚠ End-to-end installation and invocation validation in current Codex, Claude Code, Cursor, and Kiro releases.

## Working Rules

- Keep the portable skill itself free of harness-specific behavior except for optional metadata files such as `agents/openai.yaml`.
- Update the installer, template, and config together when changing names or paths.
- Favor deterministic helper scripts for folder creation and path selection over prose-only instructions.
- Validate a rendered skill, not just the template source, before considering changes complete.
- Do not commit or push changes without explicit user approval for that specific commit or push.
