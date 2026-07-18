# Engram Structure Reference

## Canonical Paths

- Text and source-control-friendly material:
  `~/__HOME_ROOT_NAME__/__DOCS_SUBDIR__/YYYY-MM-DD/{nn}-{slug}`
- Large, binary, or dump-style material:
  `~/__HOME_ROOT_NAME__/__DATA_SUBDIR__/YYYY-MM-DD/{nn}-{slug}`

Keep the same `{nn}-{slug}` on both sides when an interaction produces both docs and data.

A text-only record is normal. It should not have a matching `data` directory unless data artifacts exist.

## What Goes In Docs

Use `docs` for material that is reasonable to keep in source control, including:

- `report.md`
- `note.md`
- `summary.md`
- `email-draft.md`
- `slack-draft.md`
- copied text samples
- trimmed logs that are still readable as text
- configuration or code snippets

## What Goes In Data

Use `data` for large or binary artifacts, including:

- images
- video
- audio
- archives
- raw exports
- large logs
- database dumps
- generated artifacts that are too large or noisy for source control

Create the `data` entry only when one of these artifacts exists.

## Suggested Interaction Pattern

1. Create the entry once at the start of the work item.
2. Reuse that entry during follow-up requests on the same work item.
3. If the user drifts into a different work item, call it out and ask whether to open a new entry.

## Search Commands

Resolve the installed skill directory first, then use `<skill-dir>/scripts/engram-search list --json` for recent entries.
Use `<skill-dir>/scripts/engram-search grep "text" --json` for source-control-friendly text search.

## Example Slugs

- `weekly-status`
- `incident-summary`
- `launch-email-draft`
- `customer-call-notes`
- `api-sample-output`
