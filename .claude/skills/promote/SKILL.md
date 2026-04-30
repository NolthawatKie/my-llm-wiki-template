---
name: promote
description: Promote a personal note from staging/reviewed/ into raw/notes/ so it can be ingested into the wiki. Requires human confirmation before moving. Use after you have reviewed a note in staging/inbox/ and are ready to treat it as a trusted source.
invocation: user
allowed-tools: Read, Write, Glob
---

# /promote

## Usage

```
/promote <path>
/promote staging/reviewed/my-rlhf-notes.md
/promote staging/reviewed/*.md
```

## Arguments

| argument | required | description |
|---|---|---|
| `<path>` | yes | Path to a file inside `staging/reviewed/` or a glob pattern |

## What It Does

1. Reads the file(s) at `<path>` and displays a preview (title, first 5 lines, word count).
2. **Asks for explicit human confirmation** before proceeding — lists every file that will be moved.
3. On confirmation:
   - Copies each file from `staging/reviewed/` → `raw/notes/`
   - Removes the original from `staging/reviewed/`
   - Appends an entry to `wiki/log.md`
4. Reminds the user to run `/ingest raw/notes/<filename>` to process into the wiki.

## Confirmation Prompt

```
About to promote 1 file to raw/notes/:
  staging/reviewed/my-rlhf-notes.md  (420 words)

Proceed? [y/N]
```

Promotion only proceeds on explicit `y` or `yes`. Any other response cancels.

## Output

```
✓ promoted: staging/reviewed/my-rlhf-notes.md → raw/notes/my-rlhf-notes.md

Next step: /ingest raw/notes/my-rlhf-notes.md
```

## Guards

- Source path must be inside `staging/reviewed/`. Files in `staging/inbox/` are rejected — review them first.
- Never promotes directly from `staging/inbox/` — the human review step is mandatory.
- Never writes to `raw/sources/` — personal notes go to `raw/notes/` only.
- If a file with the same name already exists in `raw/notes/`, prompts the user to confirm overwrite or cancel.

## Workflow Context

```
staging/inbox/   ← human writes free-form notes here
      ↓  (human reviews manually in Obsidian)
staging/reviewed/
      ↓  /promote  ← this skill
raw/notes/
      ↓  /ingest
wiki/sources/
```

## Related Skills

- `/ingest` — next step after promoting a note
- `/archive` — if you decide a staged note is no longer needed
