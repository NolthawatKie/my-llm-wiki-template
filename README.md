# second-brain

A personal knowledge,
built on the LLM Wiki pattern by Andrej Karpathy.

> Obsidian is the IDE. The LLM is the programmer. The wiki is the codebase.

---

## How It Works

| layer      | who writes | who reads         | purpose                              |
| ---------- | ---------- | ----------------- | ------------------------------------ |
| `raw/`     | human      | agent (read-only) | immutable source of truth            |
| `staging/` | human      | human             | personal notes in progress           |
| `wiki/`    | agent      | human             | compiled, interlinked knowledge base |
| `output/`  | agent      | human             | generated artifacts on request       |

Sources go in. The LLM reads them, extracts what matters, and builds up a structured wiki of concepts, entities, and syntheses — with cross-references already in place. Nothing gets re-derived from scratch on every question. The wiki compounds.

---

## Quick Start

```bash
# 1. Clone and initialise
git clone https://github.com/NolthawatKie/my-llm-wiki-template.git
cd my-llm-wiki-template

# 2. Cut the connection to upstream (IMPORTANT!)
git remote remove origin
# Then create your own repo on GitHub and add it:
# git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
# git push -u origin main

# 3. Run install
bash install.sh

# 4. Open in Obsidian
# File → Open Vault → select the my-llm-wiki-template folder

# 5. Start Claude Code
claude

# 6. Drop a source and ingest it
# (copy an article to raw/sources/, or use Obsidian Web Clipper)
/ingest raw/sources/my-article.md
```

---

## Directory Structure

```
my-llm-wiki-template/
├── .claude/               Claude Code config
│   ├── CLAUDE.md          Vault rules and conventions
│   ├── settings.json      Model, permissions, context loading
│   ├── agents/            Subagent definitions (ingest, compile, lint, gap)
│   ├── skills/            Slash commands and auto-invoked skills
│   └── hooks/             Session-end and on-write triggers
│
├── staging/
│   ├── inbox/             Write personal notes here (freeform)
│   └── reviewed/          Notes ready to promote → raw/notes/
│
├── raw/                   Immutable — agent reads, never writes
│   ├── sources/           Web clips, PDFs, articles
│   ├── notes/             Promoted personal notes
│   ├── data/              Datasets, CSVs
│   ├── code/              Notebooks, scripts
│   └── _archived/
│
├── wiki/                  LLM-maintained knowledge base
│   ├── concepts/          One page per concept
│   ├── entities/          People, tools, orgs, papers
│   ├── synthesis/         Cross-source analyses
│   ├── sources/           One page per raw source
│   ├── cache/hot/         Top-N condensed pages (auto-managed)
│   ├── memory/
│   │   ├── sessions/      Session digests
│   │   └── answers/       Cached Q&A responses
│   ├── gaps/
│   │   ├── roadmap.md     ✱ Your learning roadmap — edit this
│   │   ├── list.md        Auto-scored gap list
│   │   └── study-queue.md Auto-generated study plan
│   ├── index.md           Master index (auto-maintained)
│   └── log.md             Append-only activity log
│
└── output/                Generated artifacts (slides, charts, reports)
```

---

## Workflows

### Add a web article

```
1. Use Obsidian Web Clipper → clips to raw/sources/
2. /ingest raw/sources/<article>.md
```

### Add a personal note

```
1. Write in staging/inbox/ (freeform)
2. Review in Obsidian
3. Move to staging/reviewed/
4. /promote staging/reviewed/<note>.md
5. /ingest raw/notes/<note>.md
```

### Weekly maintenance

```
/lint          → find structural issues
/gap-check     → update study queue
```

### Ask a question

```
Just ask Claude in the session.
Answers are cached to wiki/memory/answers/ automatically.
```

### Generate an artifact

```
"Write a summary of everything I know about RLHF as a markdown report"
"Create a comparison table of LoRA vs QLoRA vs full fine-tuning"
→ output/ folder
```

---

## Available Commands

| command            | description                                   |
| ------------------ | --------------------------------------------- |
| `/ingest [file]`   | Ingest a source into the wiki                 |
| `/promote [file]`  | Promote a staged note to raw/                 |
| `/lint`            | Health-check the wiki                         |
| `/gap-check`       | Analyse knowledge gaps and update study queue |
| `/archive [file]`  | Archive a wiki page or source                 |
| `/restore [file]`  | Restore an archived file                      |
| `/add-gap [topic]` | Manually flag a knowledge gap                 |

---

## Subagents

| agent         | model      | role                               |
| ------------- | ---------- | ---------------------------------- |
| ingest-agent  | haiku-4-5  | read source → write wiki pages     |
| compile-agent | sonnet-4-6 | dedup, cross-ref, consistency pass |
| lint-agent    | haiku-4-5  | structural health scan (read-only) |
| gap-agent     | sonnet-4-6 | score gaps, build study queue      |

---

## Tips

- **Obsidian Graph View** — best way to see what is connected and what is orphaned.
- **Obsidian Web Clipper** — browser extension that converts articles to markdown. Clips directly to `raw/sources/`.
- **Dataview plugin** — run queries over frontmatter. Works well with the `type`, `tags`, and `source_count` fields on every wiki page.
- **The wiki is a git repo** — you get full version history, branching, and the ability to revert any bad agent edit.
- **roadmap.md is yours** — edit it freely as your learning goals evolve. gap-agent reads it but never modifies it.

---

## References

- [Karpathy LLM Wiki concept](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Claude Code docs](https://docs.claude.ai/en/docs/claude-code)
- [Obsidian](https://obsidian.md)
