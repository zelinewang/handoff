# Conductor

**A token-tiered delegation protocol for agent harnesses.** The lead model (the
"brain") only designs, writes dispatch specs, and adjudicates evidence; cheaper
executors (the "hands") burn the execution tokens. Every dispatch is a spec file
on disk — the prompt you send *is* the permanent record — and a `STATE.md` ledger
makes any run resumable by a fresh session with no transcript.

Conductor is a **usage protocol over mechanisms your harness already has**
(subagent spawn + a per-spawn model override), not a framework you install and
import. It ships with the full pre-registered evaluation that produced its
design — including the experiment where dispatch *lost*. Read section 3 before
adopting: the honest answer is "it helps above a measured task-size threshold and
costs more below it."

Built and validated on Claude Code, portable to any harness with the two
primitives above (`docs/porting.md`).

---

## 1. The problem

Two failure modes show up the moment you use subagents for real work:

- **Flagship quota burns on execution.** Most harnesses default a subagent spawn
  to the *session's* lead model. If your interactive session runs a flagship
  model, every "go read these six files and implement X" spawn runs on the
  flagship too — you pay top-tier rates for file-reading and boilerplate that a
  strong non-lead model would do just as well. An *omitted* model parameter is
  the silent tax: it inherits the lead model and you never notice.

- **Ad-hoc orchestration leaves no audit trail.** When the plan, the sub-prompts,
  and the decisions live only in one conversation, the work dies with that
  session. A new session (or a teammate, or the same person tomorrow) can't pick
  it up without you re-explaining everything. There is no ledger, so there is no
  handoff.

## 2. What conductor is

One protocol, three guarantees:

1. **Dispatch = spec = record.** The prompt sent to a hand is a file on disk
   (`dispatch/NN-name.md`): Context (self-contained — the hand starts cold), Task,
   Constraints, pre-written Acceptance Criteria, Verify commands, and a mandated
   Evidence-return format. Writing the prompt and writing the record are the same
   act — zero extra documentation friction.

2. **A `STATE.md` ledger is the single source of truth.** Goal / Now / Done /
   Todo / Blockers / Decisions / Next-Session-Entry-Point. A fresh session
   resumes from `STATE.md` + the non-accepted `dispatch/*` files alone. No
   conversation transcript required.

3. **Flagship-floor model tiering.** Never spawn the lead model as a hand (that
   defeats the entire point); pick the *strongest* non-lead model that 100%
   covers the task's purpose — capability-first, because one rework round costs
   far more than the per-token price delta. The model parameter is **required**
   on every spawn.

And one discipline that keeps it from becoming ceremony theater:

- **Ceremony only above the measured break-even.** The full DISPATCH-file
  protocol is worth its fixed cost only when the task is big enough
  (~≥200-line artifact **or** ~≥500-line code-read), must survive a session
  handoff, or runs parallel hands. Below that, a plain inline spawn (still with
  an explicit model) is cheaper, and the git commit is the audit trail. Conductor
  is a ceremony you *enter when scale warrants* — see the evidence for exactly
  where that line sits.

The brain adjudicates on **returned evidence**, never by re-reading the hand's
work — it re-runs at least one Verify command (Iron Law: no evidence, no accept)
and, for high-risk diffs, dispatches a read-only reviewer over the full change.

## 3. Evidence

Conductor was **pre-registered** and evaluated before this repo existed. Thresholds
were locked in `eval/EVAL_PROTOCOL.md` *before any run*, so post-hoc
reinterpretation isn't possible. The full protocol, running log, and report are in
[`eval/`](eval/); two real dispatches are in
[`eval/worked-examples/`](eval/worked-examples/).

| Experiment | Pre-registered bar | Result |
|---|---|---|
| **E1** token economics — *small* task (≤175-line artifacts) | brain output −40% | **FAIL direction: +4.4%** — dispatch cost *more* (7,218 vs 6,915 brain-output tokens) |
| **E1** token economics — *large* task (219–330-line artifacts, 570–730-line reads) | brain output −40% | **PASS: −68.6%** (8,030 vs 25,612 brain-output tokens) |
| **E2** handoff losslessness — blind relay | ≥9/10 state answers + zero redone work + zero rescue | **PASS: 9/10**, zero redone accepted work, zero user rescue |
| **E3** output quality floor — blind, both pairs | dispatched ≤1 grade below solo on any dimension | **PASS: dispatched ≥ solo on every dimension**; the only concrete defects were in the *solo* artifacts |

**The break-even is the headline finding**, not a footnote. Dispatch carries a
fixed brain cost (~5–8k tokens to write the spec + adjudicate + update the
ledger). That cost is dead weight on small tasks and amortizes decisively on
large, code-reading-heavy ones. On these two data points the crossover sits near
**~200 lines of artifact / ~500 lines of code-read**. Below it, do the work
solo. Above it, dispatch.

### Honesty notes (read before quoting any number)

- **Total tokens go UP, by design.** The large-task run burned ~44k total tokens
  (8,030 lead-model + ~36k hand) versus ~25.6k for the solo baseline. Conductor's
  claim is **lead-model offload + brain availability during execution**, *not*
  total-token thrift. If your cost model is dominated by total tokens rather than
  by which model burns them, conductor is the wrong tool (see section 4). The
  blended-dollar verdict depends on your lead:hand price ratio — we recorded the
  break-even formula but make no dollar claim.

- **Small n (n=2 pairs). Do not extrapolate magnitudes.** Two pairs, one per scale point,
  same-session timestamp slicing, a cross-language large pair (bash vs
  TypeScript), and a read-burden asymmetry that mildly favored the thesis (all
  disclosed at pre-registration lock). The *direction* is consistent; treat
  "+4.4% small / −68.6% large" as "fixed-cost penalty on small tasks, multi-x
  saving on large ones", not as portable constants.

- **A measurement erratum — kept in, because it's a feature of the method.** The
  first instrument summed raw transcript rows; one API turn writes one row per
  content block, so it inflated lead-model totals 3–5× (and naive dedup would
  have *under*counted hands ~500×, since their rows are progressive snapshots).
  The corrected instrument aggregates per message id taking the max of each usage
  field. Both pairs were re-derived on the corrected tool; the small-task FAIL
  direction survived (its magnitude shrank from a misreported +29% to the true
  +4.4%). The blind quality judge — with no knowledge of the measurement work —
  independently re-discovered the exact same counting bug in the artifact under
  review. Convergent validation: two independent paths found the same defect.

## 4. When NOT to use conductor

- **Small tasks below the break-even.** A <200-line artifact that needs <500
  lines of reading is cheaper done solo (or with a ≤5-line direct edit). The
  eval measured dispatch *losing* by 4.4% here. Reach for a plain inline spawn
  only when you need the brain free for parallel work or you want the spec-first
  test rigor — not to save tokens.

- **Single-session throwaway work.** If nothing needs to survive the session and
  there's no handoff, the ledger earns nothing. Skip the ceremony.

- **Total-token-budget-sensitive users.** Conductor deliberately spends *more*
  total tokens to move burn off the lead model. If your constraint is total
  tokens (not lead-model tokens or wall-clock parallelism), this trade goes the
  wrong way for you.

## 5. Install & adapt

**Claude Code:**

```bash
git clone <this-repo> conductor && cd conductor
bash install.sh
```

`install.sh` copies `skill/` into `~/.claude/skills/conductor/` (backing up any
existing copy first) and prints two snippets for you to paste into your own
`CLAUDE.md` — a trigger row and a model-tiering section. It **never** edits your
`settings.json`; you stay in control of what your harness auto-loads. Re-running
it is safe (idempotent, with a timestamped backup each time).

**Any other harness:** conductor needs only two primitives — the ability to spawn
a subagent, and a per-spawn model override. See [`docs/porting.md`](docs/porting.md)
for how to map the four dispatch channels, the DISPATCH/STATE files, and the
model-tiering rule onto a non-Claude-Code harness.

### Repository layout

```
README.md          this file
LICENSE            MIT
install.sh         Claude Code installer (prints CLAUDE.md snippets; no settings.json edits)
skill/             the conductor skill (SKILL.md, templates/, references/, scripts/, hooks/, tests/)
eval/              the full pre-registered evaluation (protocol, report, running log, E2 relay files)
  worked-examples/ two real dispatch files, sanitized, as concrete samples
docs/porting.md    adapting conductor to non-Claude-Code harnesses
```

---

Copyright (c) 2026 Zane Wang. MIT licensed. The evaluation numbers above are real
and reproducible from `eval/`; they are the honest result of a pre-registered
test, FAIL directions included.
