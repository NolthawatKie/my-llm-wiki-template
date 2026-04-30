---
trigger: session_end
description: Runs automatically when a Claude Code session ends. Produces a session digest, updates memory, rebuilds the hot cache, and performs housekeeping. Ensures no knowledge from the session is lost to chat history.
allowed-tools: Read, Write, Glob
---

# post-session hook

## Trigger

Fires once at **session end** — when the user closes the session or Claude Code detects the conversation is wrapping up.

---

## Steps

### Step 1 — Write Session Digest

Read the current session's conversation to extract:
- Topics discussed
- Sources ingested (if any)
- Questions asked and answers given
- Decisions made or conclusions reached
- Wiki pages created or updated
- Skills and agents invoked

Write a digest to `wiki/memory/sessions/YYYY-MM-DD.md`:

```markdown
---
title: Session YYYY-MM-DD
type: session
created: YYYY-MM-DD
updated: YYYY-MM-DD
source_files: []
tags: [session]
---

# Session YYYY-MM-DD

## Summary
<2–3 sentence overview of what happened this session>

## Topics Discussed
- <topic 1>
- <topic 2>

## Sources Ingested
- [[wiki/sources/slug]] — <one line description>

## Key Insights
- <insight worth remembering>

## Wiki Changes
- created: [[page-name]]
- updated: [[page-name]]

## Open Threads
- <something unresolved to pick up next session>

## Skills / Agents Used
- /ingest × <n>
- ingest-agent × <n>
```

If a file already exists for today's date, **append** a `## Session 2` section rather than overwriting.

---

### Step 2 — Update sessions/latest.md

Overwrite `wiki/memory/sessions/latest.md` with a copy of today's digest.
This file is always loaded at session start to give Claude context on recent activity.

---

### Step 3 — Cache Q&As to wiki/memory/answers/

Scan the session for Q&A exchanges that meet write-answer-cache criteria.
For each qualifying answer, call skill **write-answer-cache** with:
- `question` — user's original question
- `answer` — synthesised answer
- `source_pages` — wiki pages consulted
- `session_date` — today

---

### Step 4 — Rebuild wiki/cache/hot/

Call skill **score-access** with:
- `session_log` — path to today's session digest
- `hot_dir` — `wiki/cache/hot/`
- `top_n` — 15

score-access will promote new high-scoring pages, evict stale ones, and update `_manifest.md`.

---

### Step 5 — Evict Stale Hot Pages

After score-access completes, scan `wiki/cache/hot/` for any pages where `hot_updated` is older than 14 days. Delete those hot/ files. The original wiki pages are untouched.

---

### Step 6 — Archive Old Session Files

Count files in `wiki/memory/sessions/` (excluding `latest.md` and `archive/`).
If count exceeds 30:
- Move the oldest files (by filename date) to `wiki/memory/sessions/archive/` until count = 25.
- Never delete session files — archive only.

---

### Step 7 — Append Log Entry

Append a single summary entry to `wiki/log.md`:

```
YYYY-MM-DD HH:MM | session-end | sessions/YYYY-MM-DD.md, cache/hot/_manifest.md | post-session
```

---

## Failure Handling

Each step is independent. If any step fails:
- Log the failure inline in the session digest under `## Errors`.
- Continue to the next step — do not abort the entire hook.
- Never leave `wiki/memory/sessions/latest.md` empty. If writing the digest fails, copy the previous latest.md as a fallback.

---

## Constraints

- Never touches `raw/` or `staging/` or `.claude/`.
- Never hard-deletes any file — session archiving moves files, hot eviction deletes hot/ copies only.
- If the session was very short (< 3 exchanges), write a minimal digest and skip steps 3–5.
