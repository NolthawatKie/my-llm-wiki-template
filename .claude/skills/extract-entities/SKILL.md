---
name: extract-entities
description: Auto-invoked after summarize during ingest. Scans source text and the summary block to identify all named entities — people, tools, organisations, and papers. Returns a structured entity list that ingest-agent uses to create or update wiki/entities/ pages and add wikilinks to the source page.
invocation: auto
allowed-tools: Read, Glob
---

# extract-entities

## Trigger

Called automatically by **ingest-agent** (step 4) immediately after `summarize` completes.

## Input

- `source_text` — full text of the source file
- `summary` — the summary block returned by `summarize`
- `existing_entities` — list of slugs currently in `wiki/entities/` (passed by caller via Glob)

## Output Schema

Returns a structured entity list:

```
entities:
  - name: "Ashish Vaswani"
    slug: ashish-vaswani
    type: person
    description: Co-author of Attention Is All You Need, researcher at Google Brain
    relation_to_source: lead author
    exists_in_wiki: false

  - name: "Transformer"
    slug: transformer
    type: tool
    description: Sequence-to-sequence architecture based entirely on attention mechanisms
    relation_to_source: primary subject
    exists_in_wiki: true

  - name: "Google Brain"
    slug: google-brain
    type: org
    description: AI research division of Google
    relation_to_source: author affiliation
    exists_in_wiki: false

  - name: "Attention Is All You Need"
    slug: attention-is-all-you-need
    type: paper
    description: Foundational 2017 paper introducing the Transformer architecture
    relation_to_source: this source
    exists_in_wiki: false
```

## Entity Type Definitions

| type | examples | when to extract |
|---|---|---|
| `person` | researchers, authors, engineers, founders | named individuals who created, used, or significantly influenced the topic |
| `tool` | frameworks, models, libraries, algorithms, architectures | named technical artefacts with their own identity |
| `org` | companies, labs, universities, research groups | named organisations playing a role in the source |
| `paper` | research papers, technical reports, books | named published works cited or discussed |

## Rules

- Extract only **named** entities — no generic terms like "neural network" or "dataset".
- `slug` — lowercase, hyphens only, no special characters. Must be stable across sources: "GPT-4" → `gpt-4`, "Yann LeCun" → `yann-lecun`.
- `exists_in_wiki` — set to `true` if slug matches an entry in `existing_entities`. Caller uses this to decide create vs update.
- `relation_to_source` — one short phrase: `lead author`, `primary subject`, `cited work`, `tool used`, `author affiliation`, `this source`.
- `description` — one sentence. Write as a standalone definition, not relative to this source.
- Do not extract the same entity twice. If two names refer to the same entity (e.g. "BERT" and "Bidirectional Encoder Representations from Transformers"), use the canonical name and note the alias in the description.
- Minimum extraction threshold: entity must appear at least twice in the source OR be central to its argument. Avoid noise from passing mentions.

## Constraints

- Read-only — never writes any file.
- Does not create wiki pages — that is ingest-agent's responsibility using this output.
- Caps output at 20 entities per source. If more are found, prioritise by centrality to the source's main argument.
