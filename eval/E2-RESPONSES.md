# E2 Blind-Relay Responses

> Answered: 2026-07-09 09:44 UTC
> Subject session: <session-id> (fresh session, zero
> conversation history with session A / <session-id>)
> Model: Fable 5 (claude-fable-5) — SAME model class and SAME machine as
> session A, so no "portable bonus" claim is available for this run.
> Sources used: STATE.md, dispatch/01, dispatch/02, EVAL_PROTOCOL.md,
> EVAL_RESULTS.md, conductor SKILL.md (loaded via Skill tool).
> E2-ANSWERS-SEALED.md NOT read. eval-timestamps.txt NOT read (seen in `ls`
> only; not on the entry-point reading list).

## Contamination declaration (for judge integrity)

Answered before consulting the sealed sheet, but this machine auto-loads
memory at session start. What leaked into my context BEFORE answering:

1. the cross-session memory system's session-start hook surfaced a note title: "conductor eval
   pair-1: naive E1 FAIL-direction + fixed-dispatch-cost lesson; E2 blind
   relay armed at ~/conductor-eval" — overlaps the HEADLINE of Q5. All
   numbers/details in my Q5 answer are file-derived.
2. Auto-memory MEMORY.md index line for "conductor skill v1" — mentions
   "/sync apply 待跑" and "v2: hook闸" — overlaps fragments of Q4/Todo.
3. Previous-session summary auto-loaded in context covers the project-x
   work only (different project); inspected, no E2-relevant content.

Everything below is answered from the on-disk ledger, with the leak surface
declared above. The judge may discount Q5/Q4 accordingly.

---

## Q1 — End goal of this workspace (one sentence)

Validate the conductor skill (brain/hands token tiering + spec-tracked
lossless handoff) against the pre-registered eval protocol (E1/E2/E3 in
EVAL_PROTOCOL.md), then package it as a portable PRIVATE-first repo for team
sharing — where any public flip is a user-only decision made after the eval
passes. [STATE.md Goal]

## Q2 — Dispatches ACCEPTED so far (ids + products)

Both dispatches are accepted; nothing is pending/in-flight.

- **dispatch/01-routing-reference** → produced
  `~/.claude/skills/conductor/references/routing.md` (152 lines, 5 `##`
  sections): the channel operations manual for channels A (Agent-opus),
  B (codex exec), C (async agent queue, pointer-style to an internal tool's manual),
  D (third-party via `claude -p`, flagged UNVERIFIED), each with
  When / Invoke / Steer / Cost & limits + evidence-return notes. All codex
  flags verified against the live binary.
- **dispatch/02-dispatch-gate-hook** → produced
  `~/.claude/skills/conductor/hooks/dispatch-gate.sh` (88 lines) +
  `~/.claude/skills/conductor/tests/dispatch-gate.test.sh` (87 lines) —
  the v2 enforcement PROTOTYPE PreToolUse hook. 11/11 tests pass.

## Q3 — What dispatch/02 produced + test result

A PreToolUse hook prototype (`hooks/dispatch-gate.sh`) that inspects `Agent`
tool calls: it PASSES silently when the prompt references a dispatch file
(`dispatch/*.md` or `DISPATCH` keyword), declares a read-only consultation
(READ-ONLY marker / review-semantics prefix), or targets a read-only
subagent type (Explore/Plan/*reviewer*/*explorer*); otherwise it WARNS on
stderr by default (exit 0, never blocks) or BLOCKS (exit 2) under
`CONDUCTOR_STRICT=1`. Malformed stdin JSON → exit 0 silently. Plus a
pure-bash test script.

Test result: **11/11 PASS** on real execution (the 7 mandated cases —
dispatch-file-path, DISPATCH-keyword, bare-default-nudge, bare-strict-block,
read-only-marker, subagent-Explore, malformed-json — plus 4 extra:
non-Agent-tool, subagent-code-reviewer, review-starts-with,
read-only-under-strict). `bash -n` clean on both files; shellcheck not
installed on this machine.

## Q4 — Is the hook registered in settings.json? Why / why not?

**No — unregistered by design.** Verified in evidence:
`grep -c dispatch-gate ~/.claude/settings.json` → 0. It is a v2 enforcement
PROTOTYPE only; v1 enforcement is skill flow (user-confirmed decision).
Registration is deferred until (a) a friction review, and (b) one REAL
Agent-tool hook stdin payload is live-captured — the adjudication note
records that the stdin JSON shape was confirmed structurally from
an existing PreToolUse hook (personal config) + the Agent tool schema, not from a live Agent-hook
payload. The dispatch also explicitly forbade modifying any settings file.

## Q5 — E1 pair-1 verdict on the pre-registered primary metric + structural lesson

**Naive primary metric: FAIL direction.** Brain (Fable 5) net output tokens:
Arm C = 26,174 vs Arm S = 20,308 — brain output did NOT drop at all, so the
pre-registered PASS bar (≥40% reduction) is not met; the numbers move the
wrong way. A post-hoc size-normalization (C ≈150 tok/line vs S ≈226 → C ~34%
cheaper per artifact line) is recorded ONLY as a protocol-revision candidate,
explicitly NOT usable as a PASS under pre-registration.

**Structural lesson:** dispatch carries a FIXED brain cost (~4k to write the
DISPATCH + adjudication + status narration) that dominates at pair-1's task
scale (60–175 line artifacts). Conductor's savings thesis lives in LARGER
code-reading-heavy tasks where hands absorb the read-code/trial-and-error
tokens — so pair-2 must be a bigger, code-reading-heavy pair. Unpriced
benefits observed alongside: the brain stayed free during hand execution
(absorbed 2 user mid-turns + a protocol revision in parallel), and the hand
delivered a fuller test suite (11 tests vs 2) because pre-written acceptance
criteria forced completeness.

## Q6 — Token windows to EXCLUDE when recomputing pair-1, and why they exist

Two interrupt windows, excluded by exact transcript-derived timestamps:

- **int1 [08:59:07–08:59:43 UTC]** inside the Arm C window
  (T0 08:53:52 → T1 09:00:20): a user mid-turn interruption, 6,327 output
  tokens.
- **int2 [09:02:17–09:02:44 UTC]** inside the Arm S window
  (T1 → T2 09:03:23): protocol-revision work, 2,009 output tokens.

They exist because both arms ran in the SAME session (<session-id>), measured by
timestamp slicing of the session JSONL; user interruptions and mid-flight
protocol edits are not part of either arm's task cost, so they must be
subtracted from the arm windows to keep the comparison clean.

## Q7 — User's capability-first routing rule (added mid-flight)

Prefer the STRONGEST available hand first — Opus 4.8 default (1M-context
class) — because one rework round costs more than the model price delta.
Downshift (Sonnet 5 / GLM) ONLY when rework risk ≈ 0; when in doubt, opus.
Corollaries: the `model` param is REQUIRED on every dispatch (omitting it
silently inherits the lead model Fable = zero saving), and never use fork
(forks always inherit the parent model, so they can never downshift cost).

## Q8 — Current blockers

**None** (STATE.md Blockers/Problems: none). The only standing user-owned
item is `/sync apply` for the ~/.claude conductor changes — a Todo entry,
not a blocker for eval work.

## Q9 — The TWO next work items (per Todo / Entry Point)

1. **E2 blind relay** — the resuming session answers E2-QUESTIONS.md →
   writes E2-RESPONSES.md BEFORE any other work (this document fulfills it).
2. **Eval pair-2 (E1) pre-registration + run** — a larger,
   code-reading-heavy pair with arms crossed S/C (candidates:
   repo-A utility → arm S; product-app/product-app-2 backlog task →
   arm C); exact tasks must be pre-registered before starting.

(Third in line after those: E3 blind quality judging for pairs 1+2 via
provenance-stripped `codex exec` read-only review.)

## Q10 — When may the brain edit directly, and the read-only consultation exception

**Hands-on line:** the brain may directly edit only TRIVIAL changes —
≤5 lines (config value, typo, one-line fix) — where dispatch overhead
exceeds the work itself. Everything else requires a DISPATCH file; no
DISPATCH file → no dispatch.

**Read-only consultation exception:** dispatches that mutate NOTHING
(reviews, second opinions, investigation sweeps) may use an inline prompt
without a DISPATCH file — but their conclusions MUST be persisted into
STATE.md (or the relevant dispatch's Adjudication section). State-mutating
work always requires the file.
