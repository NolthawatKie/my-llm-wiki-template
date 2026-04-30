---
name: add-gap
description: Manually add a knowledge gap to wiki/gaps/list.md. Use when you notice a topic missing from the wiki that is not covered by the roadmap, or when you want to flag something for study before the next /gap-check run.
invocation: user
allowed-tools: Read, Write
---

# /add-gap

## Usage

```
/add-gap <topic>
/add-gap "speculative decoding"
/add-gap "PagedAttention" --section "inference optimisation" --priority high
```

## Arguments

| argument | required | description |
|---|---|---|
| `<topic>` | yes | Name of the topic to add as a gap (use quotes if multi-word) |
| `--section <name>` | no | Roadmap section this gap belongs to. Default: `"uncategorised"` |
| `--priority <level>` | no | `high`, `medium`, or `low`. Default: `medium` |
| `--note <text>` | no | Short note explaining why this gap matters |

## What It Does

1. Reads `wiki/gaps/list.md` to check if the topic already exists (case-insensitive match).
   - If found, reports the existing entry and exits without duplicating.
2. Appends a new row to the gap table in `wiki/gaps/list.md`:
   ```
   | [[topic-slug]] | missing | — | <section> | <note> |
   ```
   - Score is left as `—` until the next `/gap-check` run assigns a real score.
3. Appends to `wiki/log.md`.
4. Prints confirmation.

## Output

```
✓ gap added: speculative-decoding
  → wiki/gaps/list.md (row appended)
  section: inference optimisation
  priority: high
  note: needed for understanding vLLM internals

Run /gap-check to score and add to study queue.
```

If the topic already exists:
```
⚠ gap already exists: speculative-decoding (score: 7.9, status: partial)
  No changes made.
```

## Slug Rules

Topic name is converted to a slug automatically:
- Lowercase
- Spaces → hyphens
- Special characters removed
- Example: `"PagedAttention"` → `paged-attention`

The slug is used as the wikilink target `[[paged-attention]]`. If a wiki page already exists at that slug, the gap row links to it and marks status as `partial` instead of `missing`.

## Guards

- Never writes to any file other than `wiki/gaps/list.md` and `wiki/log.md`.
- Never modifies `wiki/gaps/roadmap.md` or `wiki/gaps/study-queue.md` — those are managed by `/gap-check`.
- Rejects empty or whitespace-only topic names.

## When to Use

- You encounter a term while reading and want to flag it immediately
- A source mentions a technique not in the roadmap
- You want to queue something for study before the next weekly `/gap-check`

## Related Skills

- `/gap-check` — scores all gaps and rebuilds the study queue
- `/ingest` — after studying a gap topic, ingest your notes to close it
