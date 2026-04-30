---
name: archive
description: Safely archive a wiki page or raw source by moving it to the appropriate _archived/ folder. Flags all inbound wikilinks pointing to the archived page, adds a redirects_to field in frontmatter, and updates the index. Never hard-deletes. Use when a page is outdated, superseded, or no longer relevant.
invocation: user
allowed-tools: Read, Write, Glob
---

# /archive

## Usage

```
/archive <path>
/archive wiki/concepts/old-concept.md
/archive wiki/sources/superseded-paper.md
/archive raw/sources/old-article.md
```

## Arguments

| argument | required | description |
|---|---|---|
| `<path>` | yes | Path to a single wiki page or raw source file to archive |

## What It Does

1. Reads the file at `<path>` and displays its title, type, and inbound link count.
2. **Asks for explicit human confirmation** before proceeding.
3. On confirmation:

   **For `wiki/` files:**
   - Adds `archived: true` and `archived_date: <today>` to frontmatter.
   - Moves the file to the corresponding `wiki/_archived/` subdirectory.
   - Scans all `wiki/**/*.md` for wikilinks pointing to this page.
   - For each inbound link found, appends an inline comment on the same line:
     `[[archived-page]] <!-- archived <date> — update this link -->`
   - Removes the page row from `wiki/index.md` and adds it back with an `[archived]` tag.
   - Appends to `wiki/log.md`.

   **For `raw/` files:**
   - Moves the file to `raw/_archived/`.
   - Appends to `wiki/log.md`.
   - Does **not** touch `wiki/` — raw archiving does not automatically archive the corresponding wiki/sources/ page. Prompts the user to archive the wiki page separately if needed.

4. Prints a summary of what was moved and which links were flagged.

## Confirmation Prompt

```
About to archive: wiki/concepts/old-rl-policy-gradient.md
  type: concept
  inbound links: 3 pages will be flagged

Proceed? [y/N]
```

## Output

```
✓ archived: wiki/concepts/old-rl-policy-gradient.md
  → wiki/_archived/concepts/old-rl-policy-gradient.md

Flagged inbound links (3):
  wiki/concepts/ppo.md:22
  wiki/synthesis/rl-overview.md:8
  wiki/entities/john-schulman.md:15

Run /lint to verify no broken links remain.
```

## Guards

- Never hard-deletes any file.
- Refuses to archive `wiki/index.md`, `wiki/log.md`, `wiki/gaps/roadmap.md`, or any `.claude/` file.
- Only accepts one file at a time — no glob patterns. Archiving is an intentional, one-by-one action.
- If the destination path in `_archived/` already exists, appends a datestamp suffix rather than overwriting: `old-concept.2026-04-28.md`.

## Related Skills

- `/restore` — undo an archive operation
- `/lint` — run after archiving to verify no broken links remain
