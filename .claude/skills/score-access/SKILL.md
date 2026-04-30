---
name: score-access
description: Auto-invoked at session end by post-session hook. Scores all wiki pages by access frequency and recency during the session, then promotes the top-N highest-scoring pages into wiki/cache/hot/ as condensed summaries. Evicts hot/ pages older than 14 days. Keeps the always-in-context hot cache relevant and lean.
invocation: auto
allowed-tools: Read, Write, Glob
---

# score-access

## Trigger

Called automatically by the **post-session hook** (step 4) at the end of every session.

## Input

- `session_log` — path to the current session file `wiki/memory/sessions/YYYY-MM-DD.md`
- `hot_dir` — `wiki/cache/hot/` (read existing hot pages + write new ones)
- `top_n` — number of pages to keep in hot cache. Default: 15

## Scoring Formula

For each wiki page read during the session, compute an access score:

```
score = (access_count × 2) + recency_bonus + link_depth_bonus

recency_bonus:
  accessed in last 1 day  → +3
  accessed in last 7 days → +2
  accessed in last 30 days → +1
  older                   → +0

link_depth_bonus:
  page has 5+ inbound links → +2
  page has 2–4 inbound links → +1
  page has 0–1 inbound links → +0
```

Higher score = more likely to be useful in future sessions.

## What It Does

1. Reads `session_log` to extract the list of wiki pages accessed this session and their access counts.
2. Reads current `wiki/cache/hot/` to get the existing hot page list and their scores.
3. Merges session scores with existing hot scores (decayed: existing score × 0.8 + new score).
4. Ranks all scored pages. Takes the top-N.
5. For each page in the new top-N that is **not yet in hot/**:
   - Reads the full wiki page.
   - Writes a condensed version to `wiki/cache/hot/<slug>.md` — frontmatter preserved, body condensed to essential definition + key points only (max 200 words).
6. Evicts pages from `wiki/cache/hot/` that:
   - Are no longer in the top-N, **or**
   - Have an `updated` date older than 14 days in hot/
7. Writes a `wiki/cache/hot/_manifest.md` with the current hot page list and scores.

## Hot Page Format

Condensed pages in `wiki/cache/hot/` follow this template:

```markdown
---
title: <original title>
type: <original type>
hot_score: 8.4
hot_updated: <today>
source: wiki/<original-path>.md
---

# <title>

<definition or one-paragraph summary — max 200 words>

## Key Points
- <point 1>
- <point 2>
- <point 3>

[[original page → wiki/<path>.md]]
```

## Manifest Format

`wiki/cache/hot/_manifest.md`:

```markdown
---
updated: <today>
top_n: 15
---

| [[slug]] | score | hot_updated | source_page |
|---|---|---|---|
| [[transformer]] | 9.2 | 2026-04-28 | wiki/concepts/transformer.md |
...
```

## Constraints

- Only writes to `wiki/cache/hot/`. Never modifies original wiki pages.
- Condensed hot pages must link back to the original page — they are previews, not replacements.
- If a wiki page has been archived, remove it from hot/ immediately regardless of score.
- Does not append to `wiki/log.md` — post-session hook handles the log entry.
- Eviction is by deletion of the hot/ file only — the original wiki page is untouched.
