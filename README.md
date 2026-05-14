# Praxis

[English](./README.md) · [中文](./README.zh-CN.md)

Nine skills for Claude Code that turn raw model capability into precision.

Each skill sets a clear **goal**, names **hard constraints**, defines an **output contract**, and (when relevant) archives a reusable artifact. The process is left to the model.

## Philosophy

Models are already strong at output. Without structure, that strength becomes generic, imprecise work. Praxis adds structure — but not by scripting steps. It does so by making the *what* and the *what-not* extremely clear, then trusting the model with the *how*.

Three design choices follow:

- **Skills stay small.** A SKILL.md is 30–90 lines. The constraints are rigid; the execution is left open.
- **Cross-skill rules are extracted.** Common pressure-resistance and anti-patterns live in `rules/anti-patterns.md`, not duplicated in every skill.
- **Artifacts persist.** Five skills (`think` / `plan` / `read` / `design-ui` / `learn`) archive to `docs/praxis/<skill>/<slug>.md` so downstream skills and humans can consume them across sessions.

## When to use Praxis (vs Waza vs Superpowers)

| | [superpowers](https://github.com/obra/superpowers) | [waza](https://github.com/tw93/Waza) | Praxis |
|---|---|---|---|
| Stance | Complete methodology, mandatory workflow | Engineering habits, codified | Constraints + judgment |
| Skills | ~14, large, with scripts/agents | 8, medium (100–200 lines) | 9, small (30–90 lines) |
| Activation | Auto-triggered, mandatory | Manual transitions between skills | Manual triggers |
| Persistence | File output | No archiving | Archives to `docs/praxis/` |
| Platforms | Claude Code, Codex, Gemini, Cursor, Copilot, OpenCode, Factory | Claude Code, Codex, Claude Desktop | Claude Code only |
| Best for | Teams needing strict process, TDD-by-default, junior devs being onboarded | Solo or small-team engineers wanting habit codification + project-aware review | Senior devs who trust the model and want sharp boundaries, not checklists |

**Pick Praxis if** you find yourself fighting against frameworks that prescribe steps, but you still want consistency on *what counts as done*. Praxis tells the model where the red lines are and gets out of the way.

**Pick waza if** you want engineering habits codified — `/check` reads project context from README/manifest/CI, `/hunt` runs `git bisect` automatically, modes for triage and release follow-through are baked in.

**Pick superpowers if** you want the model to step back, ask what you're really trying to do, then proceed through brainstorming → plan → TDD → review on autopilot. Strongest fit for teams that need every contributor following the same flow.

The three are not mutually exclusive. Praxis takes specific designs from waza (RESOLVER routing, anti-patterns, Gotchas tables, project-context extraction, sign-off templates, `references/` subdirectories) and keeps superpowers' philosophy of "process over guessing" in mind for tasks where Praxis is intentionally lighter.

## The 9 skills

| Skill | What it produces | Archive |
|---|---|---|
| `think` | Verifiable goal + named constraints + exposed assumptions + Implementation Handoff | `docs/praxis/think/` |
| `plan` | Ordered task sequence with independent acceptance per task | `docs/praxis/plan/` |
| `write-code` | Minimum runnable code that satisfies the goal — nothing speculative | (code itself) |
| `review` | Verdict (PASS / NEEDS CHANGES / FAIL) with evidence + structured Sign-off | (no archive) |
| `debug` | Named root cause + minimal fix + regression test | (fix in code) |
| `design-ui` | Committed aesthetic + states + tokens, ready for write-code | `docs/praxis/design-ui/` |
| `read` | High-density notes preserving original terms, numbers, citations | `docs/praxis/read/` |
| `write-prose` | Chinese / English text with author voice, AI patterns stripped | (user decides) |
| `learn` | Produced artifact (article / tutorial / demo) anchoring understanding | `docs/praxis/learn/` |

`think` carries two sub-modes — Lightweight (for "how to fix it") and Evaluation (for Kill / Keep / Pivot value judgments) — so it doesn't run a full design loop on small problems.

## Skill relationships

```
think → plan → write-code / debug / design-ui / write-prose / learn
                ↑___________________ review _________________↓
                                    read (independent, feeds learn / write-prose)
```

- `think` runs before any work where the goal isn't already verifiable.
- `plan` runs after `think` when the work needs ordered steps; `plan` consumes the `think` artifact.
- `design-ui` and `learn` consume `think` and `read` artifacts respectively.
- `review` validates downstream artifacts using project context (README, manifests, CI, `AGENTS.md`).

See `skills/RESOLVER.md` for the full routing table and 10 disambiguation rules.

## Project structure

```
.
├── README.md
├── rules/
│   └── anti-patterns.md         # 8 cross-skill anti-patterns (pressure resistance, scope creep, fabricated verification, etc.)
├── scripts/
│   └── verify-skills.sh         # Form-compliance check (frontmatter, sections, RESOLVER consistency, references integrity)
├── skills/
│   ├── RESOLVER.md              # Workflow routing + 10 disambiguation rules
│   ├── <skill>/
│   │   ├── SKILL.md             # Frontmatter + 5 required sections + Gotchas
│   │   └── references/          # Detailed material extracted from SKILL.md (when present)
└── docs/
    └── praxis/                  # Archive output from think / plan / read / design-ui / learn
```

## Skill anatomy

Every SKILL.md follows the same shape:

```
---
name: <slug>
description: <one line for model triggering, 60–300 chars>
---

## When to invoke         When this skill applies
## Inputs required        What must exist before starting
## Goal                   The state to reach (not the actions)
## Hard constraints       3–7 rigid red lines (must / must not)
## Output contract        Verifiable deliverables
## Artifact               (5 skills) Where the output is archived
## Gotchas                Real-failure rules in "What happened | Rule" form
```

Cross-skill rules (pressure resistance, hallucinated paths, fabricated verification, etc.) live in `rules/anti-patterns.md` — SKILL.md does not duplicate them.

## Verification

```bash
bash scripts/verify-skills.sh
```

Six checks: anti-patterns + RESOLVER existence, SKILL.md structure, description length (60–300 chars), Artifact path correctness, RESOLVER references all skills, `references/` link integrity.

## Install

```bash
# Marketplace install (when wired up)
/plugin install praxis

# Until then, clone locally as a plugin
git clone https://github.com/HEternally/Praxis.git ~/.claude/plugins/praxis
```

Or use as a plugin directory directly:

```bash
claude --plugin-dir /path/to/praxis
```

## Acknowledgments

Praxis adopts several patterns from [Waza](https://github.com/tw93/Waza) by [@tw93](https://github.com/tw93): the central RESOLVER routing table, anti-patterns as a separate file, Gotchas tables that codify real failures, project-context extraction in review, structured sign-off templates, and `references/` subdirectories for detail extraction. Waza's own philosophy ("each rule the author writes becomes a ceiling") shaped Praxis's decision to keep SKILL.md minimal and trust the model.

Where Praxis diverges from Waza: smaller SKILL.md size, explicit `plan` and `write-code` as separate skills, archiving to `docs/praxis/`, adversarial test matrix for SKILL design verification.

Where Praxis diverges from [Superpowers](https://github.com/obra/superpowers): no mandatory workflow, no auto-triggering, no TDD prescription. The model decides how, Praxis decides what's out of bounds.

## Status

v0.2 — all 9 skills present in their full shape. Cross-skill rules extracted to `rules/`. Routing centralized in `RESOLVER.md`. Five archiving skills wired up. Verify script in place. Pending: real-world test pass on the 9 high-risk adversarial cases in `docs/superpowers/tests/2026-05-14-skills-validation.md`.

## License

MIT
