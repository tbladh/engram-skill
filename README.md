# Engram

Engram makes agent memory portable across repos and harnesses without adding more decisions to every prompt. Ask Codex, Claude Code, Cursor, Kiro, Cline, or Windsurf to save a note, report, draft, sample, or side-task artifact, and Engram puts it into a predictable structure under your home folder. The benefit is less cognitive load: you specify what should be remembered, while the skill handles where it belongs.

It is designed for the small but valuable outputs that otherwise get scattered across chats, scratch files, and project folders. Chronological records make past work easier to find, compare, reuse, and carry between tools.

## Supported Harnesses

The installer supports global skill installs for Codex, Claude Code, Cursor, Kiro, Cline, and Windsurf. Kiro support uses its documented global skill directory at `~/.kiro/skills/`. The default broad install supports Windsurf through the Codex-compatible `~/.agents/skills/` install that Windsurf can discover. The native Windsurf path, `~/.codeium/windsurf/skills/`, is installed only when Windsurf is selected explicitly.

## Install

> [!WARNING]
> The quickstart installer is intentionally broad: it installs Engram into the default global skill directories for Codex, Claude Code, Cursor, Kiro, and Cline, even if some harnesses are not installed. When replacing an existing Engram install, it overwrites the entire `engram` skill directory for that harness. Any local changes inside those installed skill directories will be lost.

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Yes
```

Both commands install globally for the default broad harness set and replace existing installed skill folders by staging a fresh copy and swapping it into place, so removed files do not linger. Python 3 must be available on `PATH`.

### Explicit Harness Installs

Use these when you only want Engram installed for one harness.

**Codex**

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --codex --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Codex -Yes
```

**Claude Code**

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --claude --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Claude -Yes
```

**Cursor**

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --cursor --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Cursor -Yes
```

**Kiro**

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --kiro --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Kiro -Yes
```

**Cline**

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --cline --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Cline -Yes
```

**Windsurf Native Path**

macOS, Linux, Git Bash, or WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/tbladh/engram-skill/main/install.sh | bash -s -- --windsurf --yes
```

Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/tbladh/engram-skill/main/install.ps1))) -Windsurf -Yes
```

From a clone, run `bash install.sh --codex`, `bash install.sh --cline`, or another explicit flag. Native Windows supports the matching PowerShell switches such as `.\install.ps1 -Codex` and `.\install.ps1 -Cline`. Legacy Codex installation is opt-in with `--legacy-codex` or `-LegacyCodex`.

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

> [!TIP]
> Example slash prompt:
>
> `/engram Create a short markdown report summarizing the investigation we just completed.`
> `Also gather the relevant sample output, logs, and exported data files from the current context and save them with the report.`

## License

[MIT](LICENSE)
