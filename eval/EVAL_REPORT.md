# Conductor Skill — Pre-Registered Eval Report

> Completed 2026-07-09 (UTC). Protocol: EVAL_PROTOCOL.md (thresholds locked
> before any run). Raw logs: EVAL_RESULTS.md. Ledger: STATE.md. Dispatches:
> dispatch/01-03. Instrument: scripts/token-report.sh v2 (see erratum).

## What was tested

Conductor = brain/hands delegation protocol for Claude Code: the lead model
(Fable 5 "brain") designs, writes DISPATCH spec files, and adjudicates
evidence; cheaper executors (Opus 4.8 subagents, codex) implement. Two
claims: (1) token tiering shifts burn off the lead model; (2) the
DISPATCH+STATE ledger makes work losslessly resumable across sessions.

## Verdicts

| Experiment | Pre-registered bar | Result |
|---|---|---|
| E1 token economics (pair-1, small: 60–175L artifacts) | brain output −40% | **FAIL direction: +4.4%** (C 7,218 vs S 6,915 net, v2-corrected) |
| E1 token economics (pair-2, larger: 219–330L artifacts, 570–730L reads) | brain output −40% | **PASS: −68.6%** (C 8,030 vs S 25,612 net) |
| E2 handoff losslessness (blind relay) | ≥9/10 + zero redone work + zero rescue | **PASS: 9/10** (codex judge; 2× PARTIAL: one declared-leak discount, one ledger ambiguity → template fixed) |
| E3 quality floor (blind, both pairs) | C not >1 grade below S on any dimension | **PASS: C ≥ S on every dimension in both pairs** |

**Overall: revised-protocol PASS.** The token-tiering claim is
scale-conditional and now encoded in the protocol: dispatch fixed cost
(~5-8k brain tokens for spec + adjudication + ledger) amortizes at roughly
≥200-line artifacts / ≥500-line reads; below that, solo is cheaper. The
handoff claim passed outright. Quality did not degrade — the opposite, in
both pairs the only concrete defects (blind-judge-found) were in the SOLO
artifacts.

## Honesty notes (read before quoting numbers)

1. **Measurement erratum**: the pair-1 instrument (token-report v1) summed
   transcript rows; one API turn writes one row per content block, so v1
   inflated main-session totals 3-5× (and first-row dedup would undercount
   subagent totals ~500× — their rows are progressive snapshots). v2
   aggregates per message.id taking per-field MAX; both pairs re-derived on
   v2. Pair-1's FAIL direction survived correction; its magnitude shrank
   (was misreported +29%, truly +4.4%). The blind E3 judge independently
   re-discovered this exact bug in the v1 artifact — convergent validation.
2. **System-total tokens**: conductor burns MORE total tokens (pair-2:
   8,030 Fable + 35,936 Opus vs 25,612 Fable solo). The claim is lead-model
   relief + brain availability during execution, not total thrift. Blended
   $-cost breakeven ≈ Fable:Opus price ratio 2.04 (ratio not verified —
   formula recorded, no claim made).
3. **Small n**: 2 pairs, 1 per scale point, same-session timestamp slicing,
   cross-language pair-2 (bash vs TS), read-burden asymmetry favoring the
   thesis disclosed at prereg lock (570 vs 730L). Direction is consistent;
   magnitudes should not be quoted beyond "fixed cost small-task penalty,
   large-task multi-x saving".
4. **E2 contamination**: subject machine auto-loads memory; a cross-session
   memory note title leaked the Q5 headline pre-answer. Declared in the responses
   header; judge discounted Q5 to PARTIAL. Same-model same-machine → the
   portable bonus (different model/machine) remains untested.
5. **Unpriced benefits observed** (not in any metric): brain absorbed
   mid-arm user interrupts at ~1.5k tokens while the hand kept working;
   repo CLAUDE.md auto-injection (~10k input tokens) lands on the hand in
   arm C, on the brain in arm S; hands produced fuller test suites (11 vs 2
   in pair-1) — pre-written acceptance criteria force completeness.

## Protocol revisions shipped from findings

- STATE template: Next Session Entry Point must split "First:" (entry
  action) from "Then:" (roadmap) — E2 Q9 ambiguity came from the ledger.
- routing.md Channel A: dispatch economics note (scale break-even).
- routing.md Channel B: two failure modes (backgrounded `codex exec` with
  an arg prompt hangs draining open non-TTY stdin → `</dev/null`; raw
  stdout echoes tool outputs → poll only the `-o` final message, critical
  for blind/sealed workflows).
- token-report.sh v2: per-message.id MAX aggregation (see erratum).
- Prereg discipline: scout reports describe DISK/LIVE state — verify every
  load-bearing claim against the branch BASE before locking a task in
  (pair-2's A1 pick was infeasible on origin/main; caught at lock time,
  switched to the disclosed runner-up A2).
- Stale-hands calibration: local CPU is a weak liveness signal for
  API-bound codex; prefer output-file mtime / session-file writes, and
  narrower re-dispatches (per-pair judges at high effort succeeded where
  one both-pairs xhigh judge stalled).

## Recommended routing posture (post-eval)

- <200-line artifact & <500-line read: brain solo (or ≤5-line hands-on line).
- ≥200-line artifact or ≥500-line read or brain needed in parallel:
  dispatch per conductor protocol (Opus default, capability-first).
- Reviews/second opinions: read-only consultations (no DISPATCH file),
  conclusions ledgered; codex via routing.md invoke shapes VERBATIM.

## Eval artifacts inventory

- dispatch/01 (routing.md), 02 (dispatch-gate hook, 11/11), 03 (product-app
  binder, 235/235) — all accepted, evidence persisted in-file.
- Arm branches: `feat/codex-drift-remediate` (repo-A worktree,
  commit bdb8b21, 16/16 hermetic tests), `feat/binder` (product-app worktree,
  commit 4fbe22b). Both unpushed; E3 follow-up fixes pending on the drift
  branch (quoting/sed-escape/split-validation).
- E2-QUESTIONS/RESPONSES/ANSWERS-SEALED, E3 verdicts (scratchpad e3-blind/,
  perishable), token windows in EVAL_RESULTS.md.
