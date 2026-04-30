---
name: write-answer-cache
description: Auto-invoked after a Q&A synthesis response. Evaluates whether the answer is worth caching, and if so writes it to wiki/memory/answers/ as a reusable digest page. Future sessions check this cache before re-synthesising. Prevents valuable answers from disappearing into chat history.
invocation: auto
allowed-tools: Read, Write, Glob
---

# write-answer-cache

## Trigger

Called automatically after Claude synthesises an answer to a user question,
when the answer meets the caching threshold (see Caching Criteria below).

## Input

- `question` — the user's original question (verbatim)
- `answer` — the synthesised answer text
- `source_pages` — list of wiki pages consulted to produce the answer
- `session_date` — today's date

## Caching Criteria

Cache the answer **only if** it meets at least one of:

| criterion | rationale |
|---|---|
| Answer required 3+ wiki pages to synthesise | high synthesis effort, likely to be asked again |
| Answer contains a comparison table or structured analysis | structured output worth preserving |
| Answer resolves a contradiction between sources | rare and valuable |
| User explicitly asks to save the answer | always cache on request |
| Question matches a gap in `wiki/gaps/list.md` | closing a gap = persistent value |

Do **not** cache:
- Simple factual lookups answered from a single page
- Answers that just quote one source
- Navigation questions ("where is the page on X")
- Conversational exchanges

## What It Does

1. Evaluates the answer against caching criteria. If none are met, exits silently.
2. Generates a slug from the question:
   - Lowercase, hyphens, first 6 meaningful words.
   - Example: "How does KV cache reduce memory?" → `how-does-kv-cache-reduce-memory`
3. Checks if `wiki/memory/answers/<slug>.md` already exists:
   - If yes → appends a `## Updated Answer (<date>)` section rather than overwriting.
   - If no → creates a new page.
4. Writes the answer page to `wiki/memory/answers/<slug>.md`.
5. Adds a row to `wiki/index.md` under the `## Answers` section.

## Answer Page Format

```markdown
---
title: <question as title>
type: answer
created: <session_date>
updated: <session_date>
source_files: [<source_pages>]
tags: []
---

# <question>

<synthesised answer — preserved verbatim>

## Sources Consulted
- [[source-page-1]]
- [[source-page-2]]
- [[source-page-3]]

## Related Questions
<!-- add manually or via future sessions -->
```

## Cache Hit Behaviour

At the start of a Q&A, Claude checks `wiki/memory/answers/` for a matching slug before synthesising:

1. Glob `wiki/memory/answers/*.md` for slugs similar to the current question.
2. If a match is found, read it and present the cached answer with a note:
   `[cached answer from <date> — verify if sources have been updated since]`
3. If the user confirms the cached answer is sufficient, do not re-synthesise.
4. If sources have been updated since the cached answer's `updated` date, re-synthesise and update the cache page.

## Constraints

- Only writes to `wiki/memory/answers/` and `wiki/index.md`.
- Never modifies the original wiki pages referenced in `source_files`.
- Answer text is preserved verbatim — do not summarise or truncate.
- If the answer page already exists and the new answer is substantially the same (> 80% overlap), skip the update to avoid noise.
- Does not append to `wiki/log.md` — post-session hook consolidates answer caching into the session digest log entry.
