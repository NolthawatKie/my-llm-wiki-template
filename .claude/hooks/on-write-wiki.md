---
trigger: Write(wiki/**)
exclude: wiki/index.md, wiki/log.md, wiki/cache/hot/**, wiki/memory/**
description: Fires after every write to the wiki/ directory. Calls update-index to keep wiki/index.md in sync with the page that was just written. Lightweight and fast — runs on every wiki write without human intervention.
allowed-tools: Read, Write
---

# on-write-wiki hook

## Trigger

Fires after **any write** to `wiki/**` except:
- `wiki/index.md` — would cause infinite loop
- `wiki/log.md` — append-only, not indexed by content
- `wiki/cache/hot/**` — hot cache is not indexed individually
- `wiki/memory/**` — session and answer files are indexed via post-session, not on-write

---

## Steps

### Step 1 — Call update-index

Invoke skill **update-index** with:
- `changed_path` — the path of the file that was just written

update-index will:
- Read the page's frontmatter
- Upsert the corresponding row in `wiki/index.md`
- Handle both new pages (append row) and updated pages (replace row)

---

### Step 2 — Verify Frontmatter (fast check)

Before calling update-index, do a quick frontmatter check on the written file:

- Required fields present: `title`, `type`, `created`, `updated`, `source_files`, `tags`
- `type` is one of: `concept`, `entity`, `source`, `synthesis`, `answer`, `gap-list`, `study-queue`, `session`

If any required field is **missing**:
- Print a warning to the terminal: `⚠ [on-write-wiki] missing frontmatter field '<field>' in <path>`
- Still call update-index — do not block the write.
- Do **not** modify the written file.

---

## Execution Contract

- Must complete in < 1 second perceived latency — this hook runs on every wiki write.
- If update-index fails for any reason, print the error and exit silently. Do not retry or cascade.
- Never writes any file other than `wiki/index.md` (via update-index).
- Never appends to `wiki/log.md` — would create a log entry for every single wiki write, flooding the log.

---

## Example

```
user runs: /ingest raw/sources/attention-is-all-you-need.md

ingest-agent writes: wiki/sources/attention-is-all-you-need.md
  → on-write-wiki fires
  → update-index upserts row in wiki/index.md

ingest-agent writes: wiki/entities/transformer.md
  → on-write-wiki fires
  → update-index upserts row in wiki/index.md

ingest-agent writes: wiki/entities/ashish-vaswani.md
  → on-write-wiki fires
  → update-index upserts row in wiki/index.md

ingest-agent writes: wiki/index.md   ← excluded, hook does NOT fire
ingest-agent writes: wiki/log.md     ← excluded, hook does NOT fire
```

Result: index stays perfectly in sync after every ingest with zero manual work.
