# CLAUDE.md

> Configuration for Claude Code — second brain vault
> Last updated: 2026-05-04

## Answer Behavior

- When the user asks any question, **always search the vault first** before answering from training knowledge.
- If the vault has relevant content, answer from vault and cite the wiki page.
- If the vault has no relevant content, answer from training knowledge and say so explicitly.

---

## Purpose

This vault is a **second brain for your knowledge based**,
based on Andrej Karpathy's concept: Obsidian is the IDE, LLM is the programmer, wiki is the codebase.

---

## Layer Rules

| layer      | owner | rule                                                       |
| ---------- | ----- | ---------------------------------------------------------- |
| `raw/`     | human | **immutable** — agent reads only, NEVER edits or deletes   |
| `staging/` | human | human writes, human reviews, human promotes via `/promote` |
| `wiki/`    | agent | agent writes and maintains, human reads                    |
| `output/`  | agent | agent writes on explicit request only                      |

---

## Source Ingestion Paths

| source type     | destination                     | method           |
| --------------- | ------------------------------- | ---------------- |
| Web Clipper     | `raw/sources/`                  | direct (trusted) |
| PDF / paper     | `raw/sources/`                  | manual drop      |
| Personal note   | `staging/inbox/` → `raw/notes/` | `/promote`       |
| Experiment data | `raw/data/`                     | manual           |
| Code / notebook | `raw/code/`                     | manual           |

---

## Forbidden Actions

- ❌ Never edit or delete any file inside `raw/` under any circumstances
- ❌ Never promote `staging/` → `raw/` without explicit human confirmation
- ❌ Never hard delete anything — always use `/archive`
- ❌ Never overwrite `wiki/memory/sessions/` entries older than 7 days without archiving first
- ❌ Never create a wiki page without a YAML frontmatter block

---

## Wiki Conventions

### Frontmatter (every page)

```yaml
---
title: <page title>
type: concept | entity | source | synthesis | answer
created: YYYY-MM-DD
updated: YYYY-MM-DD
source_files: []
tags: []
---
```

### Entity Types

- `person` — researcher, author, project owner
- `tool` — framework, library, platform
- `org` — company, lab, institution
- `paper` — research paper, technical report

### Concept Page Sections

```
## Definition
## Key Properties
## Related Concepts
## Sources
## Open Questions
```

### Wikilinks

Always use `[[page-name]]` — never use relative path markdown links inside the wiki.

---

## Index Format (`wiki/index.md`)

```markdown
| [[page-name]] | type | updated | source_count | tags |
```

- Update the index every time a wiki page is created or modified.
- Never delete rows from the index directly — use `/archive` and let the agent handle cleanup.

---

## Log Format (`wiki/log.md`)

```
YYYY-MM-DD HH:MM | action | files_affected | skill/agent
```

Example:

```
2026-04-28 14:32 | ingest | wiki/sources/attention-is-all-you-need.md, wiki/entities/transformer.md | ingest-agent
2026-04-28 15:10 | lint   | wiki/concepts/rlhf.md                                                  | lint-agent
```

---

## Available Skills

### User-invoked (called manually by typing a command)

| skill     | command            | description                                                  |
| --------- | ------------------ | ------------------------------------------------------------ |
| ingest    | `/ingest [file]`   | read source → create wiki pages → update index               |
| promote   | `/promote [file]`  | staging/reviewed/ → raw/notes/ (requires human confirmation) |
| lint      | `/lint`            | scan wiki for orphans, contradictions, stale content         |
| gap-check | `/gap-check`       | analyze knowledge gaps → update study-queue.md               |
| archive   | `/archive [file]`  | move to \_archived/, flag inbound links                      |
| restore   | `/restore [file]`  | move back from \_archived/                                   |
| add-gap   | `/add-gap [topic]` | add a new gap entry to gaps/list.md                          |

### Auto-invoked (called by Claude when triggered)

| skill                | trigger                     |
| -------------------- | --------------------------- |
| `summarize`          | during ingest               |
| `extract-entities`   | after summarize             |
| `update-index`       | on every write to wiki/\*\* |
| `score-access`       | at session end              |
| `write-answer-cache` | after Q&A synthesis         |

---

## Subagents

| agent           | model                       | purpose                                 |
| --------------- | --------------------------- | --------------------------------------- |
| `ingest-agent`  | `claude-haiku-4-5-20251001` | structured read+write, no deep judgment |
| `compile-agent` | `claude-sonnet-4-6`         | dedup entities, cross-ref quality       |
| `lint-agent`    | `claude-haiku-4-5-20251001` | pattern matching, file scan             |
| `gap-agent`     | `claude-sonnet-4-6`         | score + prioritize gaps                 |

> All agents run context-isolated — they return results only and never load `raw/` into the main context.

---

## Hooks

| hook            | trigger          | action                                             |
| --------------- | ---------------- | -------------------------------------------------- |
| `post-session`  | session end      | digest → sessions/, rebuild hot cache, evict stale |
| `on-write-wiki` | Write(`wiki/**`) | call `update-index` (excludes index.md, log.md)    |

---

## Context Loading Strategy

```
always in context:    .claude/CLAUDE.md
                      wiki/index.md
                      wiki/cache/hot/   (top-N condensed pages)

session start:        wiki/memory/sessions/latest.md

on-demand:            wiki/concepts/**, wiki/entities/**, wiki/synthesis/**
                      wiki/memory/answers/   (cache miss fallback)

never loaded:         raw/**   (only ingest-agent reads this, isolated)
```

---

## Session End Checklist

When a session is ending, follow these steps in order:

1. Write session digest → `wiki/memory/sessions/YYYY-MM-DD.md`
2. Update `wiki/memory/sessions/latest.md`
3. Cache valuable Q&As → `wiki/memory/answers/`
4. Run `score-access` → rebuild `wiki/cache/hot/`
5. Evict hot/ pages older than 14 days
6. Archive oldest sessions if count exceeds 30 files

---

## Vault Splitting Policy

| situation                                | split vault?                |
| ---------------------------------------- | --------------------------- |
| Multiple topics that can be cross-linked | No                          |
| Work / client / privacy concerns         | Yes                         |
| Personal + work mixed                    | Yes                         |
| Topics with zero overlap                 | Optional                    |
| Short-lived project                      | Yes, then archive the vault |
| Collaboration required                   | Yes                         |

---

## Quick Reference — Vault Structure

```
my-second-brain/
├── .claude/           config (CLAUDE.md, settings.json, agents/, skills/, hooks/)
├── staging/           personal notes inbox → reviewed
├── raw/               immutable sources (sources/, notes/, data/, code/)
├── wiki/              LLM-maintained knowledge base
│   ├── concepts/      concept pages
│   ├── entities/      person/tool/org/paper pages
│   ├── synthesis/     cross-source analyses
│   ├── sources/       1 page per raw file
│   ├── cache/hot/     top-N hot pages
│   ├── memory/        sessions/ + answers/
│   ├── gaps/          roadmap.md + list.md + study-queue.md
│   ├── index.md       master index
│   └── log.md         append-only activity log
└── output/            generated artifacts (slides, charts, reports)
```
