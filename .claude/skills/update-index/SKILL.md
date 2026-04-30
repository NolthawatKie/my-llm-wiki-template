---
name: update-index
description: Auto-invoked by the on-write-wiki hook whenever a wiki page is created or modified (excluding index.md and log.md). Reads the changed page's frontmatter and upserts its row in wiki/index.md. Keeps the index in sync without requiring manual maintenance.
invocation: auto
allowed-tools: Read, Write
---

# update-index

## Trigger

Called automatically by the **on-write-wiki hook** on every `Write(wiki/**)` event,
excluding writes to `wiki/index.md` and `wiki/log.md` themselves.

## Input

- `changed_path` — path of the wiki page that was just written

## What It Does

1. Reads `changed_path` and extracts frontmatter fields: `title`, `type`, `updated`, `source_files`, `tags`, `archived`.
2. Reads `wiki/index.md`.
3. Finds the existing row for this page (matched by wikilink `[[slug]]`):
   - **Row exists** → replace it with updated values.
   - **Row does not exist** → append a new row in the correct type section.
4. Writes the updated `wiki/index.md`.

## Index Row Format

```markdown
| [[slug]] | type | updated | source_count | tags |
```

| field | source | notes |
|---|---|---|
| `[[slug]]` | filename without `.md` | wikilink format always |
| `type` | frontmatter `type` | concept / entity / source / synthesis / answer |
| `updated` | frontmatter `updated` | YYYY-MM-DD |
| `source_count` | `len(frontmatter.source_files)` | integer |
| `tags` | frontmatter `tags` joined | comma-separated, no `#` prefix |

Archived pages get an `[archived]` suffix on the type field: e.g. `concept [archived]`.

## Index Structure

`wiki/index.md` is organised into sections by type. Rows are inserted into the matching section. If a section does not exist yet, create it.

```markdown
# Wiki Index

## Concepts
| [[page]] | type | updated | source_count | tags |
|---|---|---|---|---|
...

## Entities
...

## Sources
...

## Synthesis
...

## Answers
...
```

## Rules

- Never reorders rows within a section — append new rows at the bottom of the section.
- Never deletes rows — archiving a page sets `type [archived]` but keeps the row.
- If `source_files` is missing or empty from frontmatter, `source_count` = 0.
- If `tags` is missing or empty, leave the tags cell blank.
- Must complete in a single Read + Write pair — do not make multiple writes to index.md.

## Constraints

- Only writes to `wiki/index.md`. No other files.
- Does not append to `wiki/log.md` — this skill runs on every wiki write and would flood the log. Logging is the caller's (ingest-agent / compile-agent) responsibility.
- If frontmatter is malformed or missing, skips the update and prints a warning to the terminal without crashing.
