---
name: lint
description: Health-check the wiki for structural problems. Finds broken wikilinks, orphan pages, missing frontmatter, stale pages, index drift, and more. Delegates to lint-agent and prints a prioritised report. Run periodically or before a compile pass.
invocation: user
agent: lint-agent
allowed-tools: Read, Glob
---

# /lint

## Usage

```
/lint
/lint --scope wiki/concepts/
/lint --checks L01,L02,L07
/lint --scope wiki/entities/ --checks L01,L03
```

## Arguments

| argument | required | description |
|---|---|---|
| `--scope <dir>` | no | Limit scan to a subdirectory. Default: full wiki |
| `--checks <ids>` | no | Comma-separated check IDs to run. Default: all |

## Available Checks

| id | name | severity |
|---|---|---|
| L01 | Broken wikilinks | 🔴 Critical |
| L02 | Orphan pages | 🟡 Warning |
| L03 | Missing frontmatter fields | 🔴 Critical |
| L04 | Stale pages (> 60 days) | 🔵 Info |
| L05 | Long pages (> 800 words) | 🔵 Info |
| L06 | Empty sections | 🟡 Warning |
| L07 | Index drift | 🟡 Warning |
| L08 | Log continuity gaps | 🔵 Info |
| L09 | Archived link pollution | 🟡 Warning |
| L10 | Duplicate page titles | 🔴 Critical |

## What It Does

1. Delegates to **lint-agent** (read-only, haiku).
2. lint-agent scans the wiki and returns a structured report grouped by severity.
3. Prints the report in the terminal.
4. Does **not** fix anything — use `/compile` or manual edits for fixes.

## Output

```
## Lint Report — 2026-04-28 14:32
scope: wiki/

### 🔴 Critical (2)
- [L01] Broken wikilink: [[sparse-attention]] in wiki/concepts/rlhf.md:14
- [L03] Missing frontmatter field `type` in wiki/entities/yann-lecun.md

### 🟡 Warning (1)
- [L07] Index drift: wiki/entities/flash-attention.md not in index

### 🔵 Info (2)
- [L04] Stale page (87 days): wiki/concepts/rlhf.md
- [L05] Long page (1,240 words): wiki/synthesis/transformer-evolution.md

critical: 2 | warning: 1 | info: 2
recommended next action: fix critical issues, then run /compile
```

## Guards

- Read-only — lint never modifies any file.
- If `--scope` points to a directory that does not exist, returns an error immediately.

## When to Run

- After batch ingestion of 3+ sources
- Before running `/compile`
- Weekly as part of maintenance
- After `/archive` to verify no broken links remain

## Related Skills

- `/compile` (via compile-agent) — fixes structural issues lint finds
- `/gap-check` — run after lint to see knowledge coverage
