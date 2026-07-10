# Handoff Eval Protocol v1 (pre-registered 2026-07-09)

Purpose: falsifiably test whether handoff achieves its two goals before
sharing/open-sourcing. Thresholds are PRE-REGISTERED (written before any run;
self-serving reinterpretation after the fact is not allowed).

Measurement pipeline: VERIFIED 2026-07-09 — per-model token usage parses
cleanly from `~/.claude/projects/<proj>/<session>.jsonl` (main) +
`<session>/subagents/agent-*.jsonl` (hands); codex self-reports total.
Baseline sample (handoff-build session itself): brain fable-5 out=213k,
hand opus-4.8 out=20.6k, codex 52k. NOT evidence either way — doc-type task,
execution share too small. Eval MUST use code-implementation tasks.

## E1 — Token economics (goal 1: shift burn off the lead model)

Design: paired real backlog tasks (30–60 min scale), 2–3 pairs, arms crossed
per pair to cancel difficulty bias (pair1: C/S, pair2: S/C, pair3 coin-flip).
- Arm C (handoff): brain designs + dispatches + adjudicates; Agent(opus)
  implements. Normal protocol, no special effort.
- Arm S (solo): brain implements everything itself (status-quo way).

Metrics (from JSONL, per arm):
- PRIMARY: brain output tokens; brain cache_write tokens
- SECONDARY: blended cost (per-model price-weighted), wall-clock, rework count

Pre-registered thresholds:
- PASS: brain output tokens ↓ ≥40% vs solo AND quality holds (E3)
- FAIL: ↓ <20% OR quality drops → revise protocol, re-run; do NOT ship claims
- 20–40%: marginal — decide on blended cost + user judgment

## E2 — Handoff losslessness (goal 2: spec-tracked continuity)

Design: blind relay.
1. Session A runs a handoff task to ~50% (≥1 dispatch accepted, ≥1
   pending/in-flight). A writes a SEALED ground-truth sheet (10 Q&A on goal /
   done / in-flight / blockers / next) — stored where B cannot see it.
2. Kill session A. Fresh session B (zero history; bonus points: different
   model or machine) gets ONE line: "Resume from <STATE.md path>".
3. B answers the 10 questions FIRST, then resumes to completion.

Pre-registered thresholds:
- PASS: ≥9/10 state answers correct; zero redone accepted work; zero user
  interventions during resume.
- Portable bonus: B on Opus (not Fable) still passes → protocol is
  model-agnostic, strengthens the sharing story.
- Judge: user or codex, scoring against the sealed sheet.

## E3 — Output quality floor (guardrail for both)

Blind judging: for each pair, both outputs (C and S) go to `codex exec review`
without provenance labels. Dimensions: correctness / completeness / idiom.
- PASS: C not more than one grade below S on any dimension; C first-pass
  acceptance needs ≤1 more rework than S.

## Task candidates (real backlog, need user selection)

1. handoff v2 hook-gate prototype (PreToolUse script; self-contained,
   testable — also produces the v2 feature)
2. eval token-report tool itself (jq/bash script turning JSONL into the E1
   table — meta but real, immediately reusable)
3. a repo-A small utility improvement
4. an independent small task from product-app / product-app-2 backlog

## Anti-bias measures

- Thresholds pre-registered (this file, committed before first run)
- Arms crossed per pair; no same-task-twice (learning contamination)
- Blind quality judge (codex, no provenance)
- Token numbers computed by script from JSONL, never self-estimated
- Failures reported verbatim in eval report — a FAIL verdict is a valid,
  publishable outcome (protocol revision material), not an embarrassment

## Sequencing

E-phase (this) → revise protocol per findings → THEN portable repo
(private-first, a pre-publication content sweep, user-only public flip). Eval artifacts +
report ship inside the repo's eval/ directory as evidence.
