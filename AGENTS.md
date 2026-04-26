# Agent Guidance

This repository contains local Codex agent configuration, reusable skills, and private skills.

## Scope

- Put repository-wide rules in this file.
- Put task-specific workflows in each skill's `SKILL.md`.
- Do not duplicate the same instructions in both places unless the overlap is intentional and short.

## Skills in This Repo

- Public or reusable repo-local skills live under `.agents/skills/`.
- Private local-only skills may live under `.agents/.private/`.
- If a skill is heavy, specialized, or only appropriate for some tasks, keep the workflow inside the skill instead of promoting it to this file.

## Hermes Boundary

- `hermes` is for unfamiliar repositories, non-trivial code changes, CI-failure investigation, or tasks that need project-state notes before implementation.
- Do not use `hermes` for read-only questions, trivial one-file edits, or simple command execution.
- `hermes` may create `.hermes-prj-states/` for repository state notes and temporary artifacts.

## Editing Guidance

- When editing a skill, keep `SKILL.md` focused on trigger conditions, workflow, and stop conditions.
- Put reusable note templates or detailed examples under the skill's `references/`.
- Put deterministic setup helpers under the skill's `scripts/`.

## Repository Hygiene

- Treat `.hermes-prj-states/` as generated working notes unless a task explicitly requires committing them.
- Prefer small, reviewable changes to skill definitions and metadata.
