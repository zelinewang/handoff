# Changelog

## v0.2.0 — 2026-07-21

Kimi K3 channel + MoA-leader contest mode.

- Channel D rewritten from "third-party, unverified" to a live-verified Kimi
  K3 channel: frontend/vision/web-agentic PRIMARY, backend contest-capable;
  invoke mechanics (env override, detached runner, Monitor-style supervision),
  K3 rules of engagement (hard boundaries, one-long-run, no cross-model
  resume), 429 backoff-and-retry failure mode.
- New MoA-leader contest mode (v0.1): same spec to 2-3 heterogeneous hands,
  judge-owned black-box oracle built BEFORE dispatch, byte-symmetric briefs,
  adversarial re-verification (oracle rerun, RED-by-cherry-pick, true exit
  codes), pre-registered rubric; every contest doubles as a routing eval.
  Contest #1 evidence: K3 99 vs Opus 4.8 96 on a Go parser round-trip fix —
  winning PR https://github.com/zelinewang/claudemem/pull/10.
- New `templates/DISPATCH-K3.md` (hard-boundary brief tailored to K3's
  official limitations) with the explicit-gate-scope authoring rule.
- SKILL.md: routing tree gains the K3 line and the MoA-leader notch; ledger
  section gains the watchdog-channel-choice rule (supervisors with their own
  process for long detached runs; plain background loops for short waits).

## v0.1.0 — 2026-07-09

Initial release.

- Handoff protocol v1: DISPATCH = spec = record; STATE.md ledger;
  flagship-floor model tiering; ceremony conditional on the measured
  ~200-line-artifact / ~500-line-read break-even.
- Full pre-registered evaluation shipped in `eval/` (E1 scale-conditional
  including the small-task FAIL direction; E2 blind relay 9/10; E3 blind
  quality floor passed both pairs; measurement erratum documented).
- Tools: `scripts/token-report.sh` (per-model usage, per-message dedup,
  time-window slicing), `scripts/adjudicate.sh` (mechanized Verify-block
  execution + adjudication packet), `hooks/dispatch-gate.sh` (optional
  PreToolUse nudge/strict gate — PROTOTYPE, unregistered by default).
- Installer prints CLAUDE.md snippets; never edits settings.
