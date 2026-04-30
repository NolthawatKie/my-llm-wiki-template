---
name: restore
description: Restore a previously archived wiki page or raw source back to its original location. Removes the archived frontmatter fields, cleans up flagged inbound link comments, and updates the index. Use to undo an /archive operation.
invocation: user
allowed-tools: Read, Write, Glob
---

# /restore

## Usage

```
/restore <path>
/restore wiki/_archived/concepts/old-concept.md
/restore raw/_archived/old-article.md
```

## Arguments

| argument | required | description |
|---|---|---|
| `<path>` | yes | Path to a file inside `wiki/_archived/` or `raw/_archived/` |

## What It Does

1. Reads the archived file and displays its original location, archived date, and title.
2. **Asks for explicit human confirmation** before proceeding.
3. On confirmation:

   **For `wiki/_archived/` files:**
   - Removes `archived: true` and `archived_date` from frontmatter.
   - Moves the file back to its original `wiki/` location (inferred from the `_archived/` subdirectory path).
   - Scans all `wiki/**/*.md` for the inline archive comments added during `/archive`:
     `[[page-name]] <!-- archived <date> — update this link -->`
   - Removes the `<!-- archived ... -->` comment suffix from each flagged line, restoring the plain wikilink.
   - Updates `wiki/index.md`: removes the `[archived]` tag and restores the normal row.
   - Appends to `wiki/log.md`.

   **For `raw/_archived/` files:**
   - Moves the file back to `raw/sources/` or `raw/notes/` based on the subdirectory it was archived from.
   - Appends to `wiki/log.md`.

4. Prints a summary of what was moved and which link comments were cleaned up.

## Confirmation Prompt

```
About to restore: wiki/_archived/concepts/old-rl-policy-gradient.md
  original location: wiki/concepts/old-rl-policy-gradient.md
  archived: 2026-03-15
  inbound link comments to clean: 3

Proceed? [y/N]
```

## Output

```
✓ restored: wiki/_archived/concepts/old-rl-policy-gradient.md
  → wiki/concepts/old-rl-policy-gradient.md

Cleaned inbound link comments (3):
  wiki/concepts/ppo.md:22
  wiki/synthesis/rl-overview.md:8
  wiki/entities/john-schulman.md:15

Index updated. Run /lint to verify.
```

## Guards

- Source path must be inside `wiki/_archived/` or `raw/_archived/`. Files elsewhere are rejected.
- If the restore destination already exists (a newer page was created at the same path after archiving), halts and asks the user to resolve the conflict manually.
- Only accepts one file at a time.
- Does not re-ingest the file automatically — if the restored raw file needs wiki pages rebuilt, run `/ingest` manually.

## Related Skills

- `/archive` — the operation this skill undoes
- `/lint` — run after restoring to verify link integrity
- `/ingest` — if you need to rebuild wiki pages for a restored raw source
