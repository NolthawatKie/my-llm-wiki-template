---
name: summarize
description: Auto-invoked during ingest to produce a structured summary of a source file. Extracts title, one-sentence description, key points, and preservable quotes. Outputs a summary block that ingest-agent embeds into the wiki/sources/ page. Also callable manually by the user to preview a source before ingesting.
invocation: auto
allowed-tools: Read
---

# summarize

## Trigger

Called automatically by **ingest-agent** (step 3) after reading a source file.
Can also be called manually: `/summarize raw/sources/<file>` to preview before ingesting.

## Input

- `source_path` — path to a file inside `raw/`
- `source_text` — full text content already read by the caller (avoids double-read)

If `source_text` is provided, use it directly. Otherwise read `source_path`.

## Output Schema

Returns a structured summary block — not a prose narrative:

```
title: <title from frontmatter or inferred from content>
description: <one sentence — what this source is and why it matters>

key_points:
  - <point 1>
  - <point 2>
  - <point 3>
  ... (max 7)

quotes:
  - "<quote 1>" (< 15 words)
  - "<quote 2>" (< 15 words)
  - "<quote 3>" (< 15 words)
  ... (max 3)

source_type: article | paper | note | data | code
estimated_reading_time: <n> min
```

## Rules

- `key_points` — each point is one sentence, self-contained, no wikilinks yet. Focus on what is novel, actionable, or contradicts existing knowledge. Maximum 7 bullets.
- `quotes` — direct quotes worth preserving verbatim. Each must be under 15 words. Maximum 3. Prefer quotes that capture a precise definition or a strong claim.
- `description` — written as: "[Source type] by [author if known] covering [topic]. [One sentence on why it matters or what it argues]."
- Never fabricate content not present in the source.
- If the source is code or data (not prose), set `key_points` to describe what the code/data does and its structure. Omit `quotes`.

## Constraints

- Read-only — never writes any file.
- Does not produce wikilinks — entity linking is handled by `extract-entities` in the next step.
- Keeps output under 300 words total.
