---
name: ingest
description: Ingest a source file from raw/ into the wiki. Creates a wiki/sources/ page, extracts entities, updates concept pages, and updates the index. Use after dropping a new file into raw/sources/ or raw/notes/. Supports single file or glob pattern for batch ingestion.
invocation: user
agent: ingest-agent
allowed-tools: Read, Write, Glob
---

# /ingest

## Usage

```
/ingest <path>
/ingest raw/sources/attention-is-all-you-need.md
/ingest raw/sources/*.pdf
/ingest raw/notes/my-rlhf-notes.md --force
```

## Arguments

| argument | required | description |
|---|---|---|
| `<path>` | yes | Path to a file inside `raw/` or a glob pattern |
| `--force` | no | Re-ingest even if a wiki/sources/ page already exists |

## What It Does

1. Resolves `<path>` — if a glob, expands to a list of files and processes each in sequence.
2. For each file, delegates to **ingest-agent** which:
   - Reads the source file
   - Writes `wiki/sources/<slug>.md` with summary, key points, and entity links
   - Creates or updates `wiki/entities/` pages for all extracted entities
   - Updates relevant `wiki/concepts/` pages with new citations
   - Appends a row to `wiki/index.md`
   - Appends an entry to `wiki/log.md`
3. After all files are processed, prints a summary of what was written.

## Output

```
✓ ingested: raw/sources/attention-is-all-you-need.md
  → wiki/sources/attention-is-all-you-need.md (new)
  → wiki/entities/transformer.md (updated)
  → wiki/entities/vaswani-ashish.md (new)
  → wiki/concepts/self-attention.md (updated)

1 file ingested · 1 source page · 2 entity pages · 1 concept page updated
```

## Guards

- Source path must be inside `raw/`. Paths outside `raw/` are rejected with an error.
- If the wiki/sources/ page already exists and `--force` is not set, skips with a `[skipped]` notice.
- If the source file is empty or unreadable, skips with an `[error]` notice and continues to the next file.
- Never modifies any file inside `raw/`.

## Related Skills

- `/promote` — move a personal note from staging/ into raw/notes/ before ingesting
- `/lint` — run after batch ingest to check for broken links or drift
- `/gap-check` — run after ingest to see how the new source closes knowledge gaps
