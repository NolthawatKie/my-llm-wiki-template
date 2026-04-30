---
name: gap-check
description: Analyse the wiki against the AI/LLM Engineer roadmap to find knowledge gaps. Scores each gap by importance, dependency, and proximity. Rewrites wiki/gaps/list.md and wiki/gaps/study-queue.md with a prioritised learning plan. Run weekly or after batch ingestion.
invocation: user
agent: gap-agent
allowed-tools: Read, Write, Glob
---

# /gap-check

## Usage

```
/gap-check
/gap-check --focus transformers
/gap-check --focus rlhf --queue 5
```

## Arguments

| argument | required | description |
|---|---|---|
| `--focus <topic>` | no | Constrain analysis to a roadmap section. Default: full roadmap |
| `--queue <n>` | no | Number of items to write into study-queue.md. Default: 10 |

## What It Does

1. Delegates to **gap-agent** (sonnet) which:
   - Reads `wiki/gaps/roadmap.md` and `wiki/gaps/list.md`
   - Reads `wiki/index.md` to map current coverage
   - Reads `wiki/memory/sessions/latest.md` to factor in recent study
   - Scores each uncovered or shallow topic across 3 dimensions (importance 40%, dependency 35%, proximity 25%)
   - Overwrites `wiki/gaps/list.md` with the full scored gap table
   - Overwrites `wiki/gaps/study-queue.md` with the top-N actionable items and suggested sources
   - Appends to `wiki/log.md`
2. Prints a summary of gaps found and the top 3 items now in the queue.

## Output

```
## Gap Check — 2026-04-28 14:45

Coverage: 23/61 roadmap topics (38%)
  covered:  23  ████████░░░░░░░░░░░░░░░░
  partial:   8
  missing:  30

Gaps closed since last run: 2 (Flash Attention, LoRA)

Top 3 in study queue:
  1. RLHF · score: 8.7 · prerequisite for alignment track
  2. KV Cache · score: 8.1 · prerequisite for inference optimisation
  3. Mixture of Experts · score: 7.4 · adjacent to transformer architecture

→ wiki/gaps/list.md updated (38 gaps)
→ wiki/gaps/study-queue.md updated (10 items)
```

## Guards

- Only writes to `wiki/gaps/list.md`, `wiki/gaps/study-queue.md`, and `wiki/log.md`.
- Never modifies `wiki/gaps/roadmap.md` — that file is human-owned.
- If `--focus` is set to a topic not present in the roadmap, returns an error with available section names.

## When to Run

- Weekly as part of maintenance workflow
- After ingesting a batch of new sources
- When deciding what to study next

## Related Skills

- `/add-gap` — manually add a gap outside the roadmap
- `/ingest` — after studying a topic, ingest your notes to close the gap
- `/lint` — run before gap-check to ensure index is accurate
