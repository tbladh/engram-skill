# Engram

Engram makes agent memory portable across repos and harnesses without adding more decisions to every prompt. Ask Codex, Claude Code, or Cursor to save a note, report, draft, sample, or side-task artifact, and Engram puts it into a predictable structure under your home folder. The benefit is less cognitive load: you specify what should be remembered, while the skill handles where it belongs.

It is designed for the small but valuable outputs that otherwise get scattered across chats, scratch files, and project folders. Chronological records make past work easier to find, compare, reuse, and carry between tools.

## Install

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Yes
```

Both quickstart commands install globally for all three supported harnesses and replace existing installed skill folders by staging a fresh copy and swapping it into place, so removed files do not linger. Python 3 must be available on `PATH`.

To install from a clone and get prompted before replacement:

```bash
bash install.sh
```

PowerShell clone equivalent:

```powershell
.\install.ps1
```

Run `install.sh --codex`, `--claude`, or `--cursor` from a clone to install one target. Native Windows supports the matching `-Codex`, `-Claude`, and `-Cursor` PowerShell parameters. Legacy Codex installation is opt-in with `--legacy-codex` or `-LegacyCodex`.

## What It Saves

Text and source-control-friendly artifacts go to:

```text
~/engram/docs/YYYY-MM-DD/{nn}-{slug}
```

Large or binary artifacts go to the matching path only when needed:

```text
~/engram/data/YYYY-MM-DD/{nn}-{slug}
```

The skill keeps one active entry during an interaction. If the request changes to a different work item, it asks whether to start a new entry. A text-only entry deliberately has no matching `data` directory.

## Use

Ask your agent to save a report, note, email draft, Slack draft, work sample, or data export. You only specify what to save; Engram chooses the standard location. Ask it to search previous saved work when you need to revisit or reuse an earlier artifact.

## License

[MIT](LICENSE)
