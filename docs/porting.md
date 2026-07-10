# Porting handoff to another harness

Handoff is a **protocol**, not a binary. Most of it — the DISPATCH file, the
`STATE.md` ledger, the model-tiering discipline, the adjudicate-on-evidence rule
— is plain Markdown and habit, so it moves to any harness unchanged. Only the
*channel mechanics* are Claude-Code-specific. This doc maps them.

## Requirements

Your harness needs exactly two primitives:

1. **Subagent spawn** — start a sub-task in a separate context that returns a
   result.
2. **Per-spawn model override** — choose which model that sub-task runs on,
   independently of your interactive session's model.

Without (2) there is no token tiering — every hand inherits your lead model and
the whole point evaporates. Everything else is optional polish.

## What ports unchanged

- `skill/templates/DISPATCH.md` and `skill/templates/STATE.md` — pure Markdown
  templates. Use as-is.
- `skill/SKILL.md` — the protocol: role contract, the 200-line/500-line
  break-even, adjudication, ledger recovery, anti-patterns. All harness-agnostic.
- `skill/scripts/adjudicate.sh` — re-runs a dispatch's own `## Verify` block and
  prints a PASS/FAIL packet. Pure bash + git; no Claude Code dependency.
- The **flagship-floor model-tiering rule** — "never spawn the lead model as a
  hand; pick the strongest non-lead model that covers the purpose; the model
  param is required on every spawn." A discipline, not a feature.

## What to remap

| Claude Code mechanism (in `skill/references/routing.md`) | Your equivalent |
|---|---|
| **Channel A** — `Agent(model:"opus")` subagent, steered via `SendMessage` | Your spawn-subagent call with an explicit model; your continue/reply-to-agent mechanism for rework |
| **Channel B** — `codex exec` (a heterogeneous external CLI agent) | Any second, independent CLI agent — ideally a *different model family* for genuine diversity on reviews and 3×-stuck reframes |
| **Channel C** — async agent queue | Your team's job/issue queue that assigns work to persistent background agents |
| **Channel D** — `claude -p` with a third-party endpoint | Any headless invocation of an external/third-party model; smoke-test tool-use + file-write before trusting it |
| **`skill/hooks/dispatch-gate.sh`** — a Claude Code `PreToolUse:Agent` hook | Optional. It nudges/blocks spawns that don't reference a DISPATCH file. If your harness has no pre-spawn hook, skip it — the protocol works by convention without it. |

## Claude-Code-isms in the skill text

The skill mentions a few Claude Code specifics as concrete examples — treat them
as illustrations and substitute your own:

- `CLAUDE.md` — the always-loaded instruction file. Map to your harness's system
  prompt / rules file (that's where the model-tiering rule and the skill trigger
  live).
- `/dev` P5/P7 — an example multi-phase workflow the protocol plugs into. Map to
  your own plan→execute loop: one plan task = one DISPATCH file.
- ECC reviewer agents (e.g. `python-reviewer`) — domain-matched review subagents.
  Map to whatever specialized reviewers your harness offers, or use a general
  agent with a review-focused prompt.
- `~/.claude/...` paths — Claude Code's config dir. Map to your harness's config
  location.

## Minimum viable adoption

1. Drop `DISPATCH.md` + `STATE.md` templates into your project.
2. Adopt the model-tiering rule in your system prompt / rules file.
3. For any task above the break-even (~≥200-line artifact or ~≥500-line read),
   write a DISPATCH file, spawn a hand on a non-lead model, and adjudicate on the
   returned evidence.
4. Keep `STATE.md` current at every adjudication — that is your handoff.

Everything else (the hook, the four-channel routing, the token-report script) is
optional and can be added as your needs grow.
