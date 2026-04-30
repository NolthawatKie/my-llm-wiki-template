---
description: Cross-wiki compilation pass. Deduplicates entity pages, resolves merge conflicts between overlapping concept pages, strengthens cross-references, and ensures synthesis pages reflect the current state of the wiki. Run after batch ingestion of 3+ sources, or when the wiki feels fragmented. Requires deeper judgment than ingest-agent — uses sonnet.
model: claude-sonnet-4-6
allowed-tools: Read, Write, Glob
---

# compile-agent

## Role

Quality pass over the entire wiki. Finds and fixes structural issues that arise when many sources are ingested independently — duplicate entities, inconsistent concept definitions, missing cross-references, and synthesis pages that are out of date.

## Inputs

- `scope` — (optional) limit to a subdirectory, e.g. `wiki/entities/` or `wiki/concepts/`. Default: full wiki.
- `dry_run` — (optional, bool) report issues without writing any changes.

## Steps

### Phase 1 — Entity Deduplication

1. Glob all `wiki/entities/*.md`.
2. Identify near-duplicate pages (same person/tool/org/paper under different slugs or spellings).
3. For each duplicate group:
   - Choose the canonical page (most content, or most inbound links).
   - Merge content from duplicates into the canonical page.
   - Replace all wikilinks pointing to deprecated slugs with the canonical `[[slug]]`.
   - Archive deprecated pages via rename to `wiki/_archived/sources/<slug>.md` and append a `redirects_to` field in frontmatter.
4. Log each merge.

### Phase 2 — Concept Page Consistency

1. Glob all `wiki/concepts/*.md`.
2. For each concept page, check:
   - Does the `## Definition` section conflict with how the concept is described in other pages?
   - Are all related concepts listed in `## Related Concepts` actually present as pages?
   - Are all source citations under `## Sources` still valid (pages exist, not archived)?
3. Flag or fix each inconsistency. When fixing, note the change inline with an HTML comment: `<!-- compile-agent <date>: <reason> -->`.

### Phase 3 — Cross-Reference Strengthening

1. For every entity and concept page, scan all other wiki pages for mentions of its name that are **not** already wikilinks.
2. Convert bare mentions to `[[page-name]]` wikilinks (first occurrence per page only).
3. Identify important concepts mentioned across 3+ sources but lacking a dedicated concept page → add to `wiki/gaps/list.md`.

### Phase 4 — Synthesis Page Refresh

1. Glob all `wiki/synthesis/*.md`.
2. For each synthesis page, check the `source_files` frontmatter field.
3. If new source pages have been added to the wiki since `updated` date and they are relevant → append a `## New Evidence` section summarising what changed, and update the `updated` date.

### Phase 5 — Index Reconciliation

1. Read `wiki/index.md`.
2. Glob all `wiki/**/*.md` excluding `index.md`, `log.md`, `_archived/`.
3. Add missing rows; mark archived pages with a `[archived]` tag.
4. Sort rows by type, then alphabetically within type.

### Phase 6 — Log and Return

Append one entry per phase to `wiki/log.md`:
```
<YYYY-MM-DD HH:MM> | compile | phase:<1-5> files_affected:<n> | compile-agent
```

Return to caller:
```
{
  status: "ok",
  entities_merged: [...],
  concepts_fixed: [...],
  crossrefs_added: <n>,
  synthesis_refreshed: [...],
  gaps_added: [...],
  index_rows_added: <n>
}
```

## Constraints

- Never delete files — archive only.
- When merging entity pages, preserve all unique content from both sides.
- Do not alter `raw/` or `staging/` under any circumstances.
- If `dry_run` is set, return the same result object but write nothing.
- Changes to concept definitions must be conservative — prefer appending a `## Revision Note` section rather than overwriting the existing definition.
