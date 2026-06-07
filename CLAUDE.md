# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of agent skills (slash commands and behaviors) loaded by Claude Code and other coding agents. There is no build step, no compiled output, and no test suite — the "source" is the Markdown in each skill's `SKILL.md` plus its bundled resource files. Changes are validated by reading them, not by running them. This is a fork of `mattpocock/skills`; upstream is kept as a reference and may be pulled from.

## Repository layout & bucket rules

Skills live in bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to the maintainer's own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

These rules are load-bearing — three files must stay in sync whenever a skill is added, moved between buckets, or removed:

- Every skill in `engineering/`, `productivity/`, or `misc/` **must** have a reference in the top-level `README.md` (skill name linked to its `SKILL.md`) and an entry in `.claude-plugin/plugin.json`. Skills in `personal/`, `in-progress/`, and `deprecated/` **must not** appear in either.
- Each bucket folder has its own `README.md` listing every skill in that bucket with a one-line description, skill name linked to its `SKILL.md`.

So promoting a skill from `in-progress/` to `engineering/` means: move the folder, add it to the top-level `README.md`, add it to `.claude-plugin/plugin.json`, and add it to the bucket `README.md`. Deprecating one means removing it from all three.

## Anatomy of a skill

A skill is a directory containing a `SKILL.md` and optional bundled resource files (e.g. `tests.md`, `mocking.md`, `domain.md`, issue-tracker templates). `SKILL.md` starts with YAML frontmatter:

```yaml
---
name: tdd
description: <when this skill should fire — written as triggering conditions, not just a summary>
disable-model-invocation: true   # optional; present on setup-* skills that must be run explicitly
---
```

The `description` is what the agent matches against to decide whether to invoke the skill, so it is phrased as concrete trigger conditions ("Use when the user…"). `SKILL.md` bodies use **progressive disclosure**: the main file stays short and links out to bundled resource files for detail rather than inlining everything.

## The engineering skills are a connected system

The engineering skills are not independent — they share a per-repo configuration layer that `setup-matt-pocock-skills` scaffolds. Understanding this dependency is the key to the architecture:

- **`setup-matt-pocock-skills`** is run once per *target* repo (not this one). It writes an `## Agent skills` block into that repo's `CLAUDE.md`/`AGENTS.md` and creates `docs/agents/` files capturing three decisions: the **issue tracker** (GitHub / GitLab / local markdown / other), the **triage label vocabulary** (five canonical roles: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), and the **domain doc layout** (single- vs multi-context).
- The consumer skills (`to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, `zoom-out`) read that configuration to know which CLI to call (`gh`, `glab`, or a file convention) and which labels exist. The seed templates they rely on (`issue-tracker-github.md`, `issue-tracker-gitlab.md`, `issue-tracker-local.md`, `triage-labels.md`, `domain.md`) live inside the `setup-matt-pocock-skills/` folder.

A second cross-cutting concept is the **shared language**: `CONTEXT.md` is a glossary of the project's domain terms (with an "_Avoid_" list of discouraged synonyms), and `docs/adr/` holds architectural decision records. `grill-with-docs` builds and maintains these; `improve-codebase-architecture` and `diagnose` read them. When editing skills that touch domain docs, preserve the glossary framing — `CONTEXT.md` is terminology, not implementation notes.

When changing one engineering skill, check whether it reads or writes config produced by `setup-matt-pocock-skills` or the `docs/agents/` / `CONTEXT.md` / `docs/adr/` contracts, and keep those contracts consistent across the skills that share them.

## Scripts

- `scripts/link-skills.sh` — symlinks every active `SKILL.md`'s parent dir into `~/.claude/skills/` so the local Claude CLI can use them. Skips `deprecated/` and `node_modules/`, and refuses to run if `~/.claude/skills` is itself a symlink into this repo.
- `scripts/list-skills.sh` — lists every `SKILL.md` path in the repo.

## Conventions

- The skill named `setup-matt-pocock-skills` and the README title ("Matt Pocock Skills", "Skills For Real Engineers") carry the upstream branding; treat renaming as a deliberate, repo-wide change rather than an incidental edit.
- Prose style across skills is terse and imperative, organized as numbered process steps. Match it when adding or editing a skill.
