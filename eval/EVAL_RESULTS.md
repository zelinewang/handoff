# Handoff Eval Results (running log)

## MEASUREMENT ERRATUM (2026-07-09 ~19:40 UTC) — applies to ALL numbers above/below

token-report.sh v1 (the pair-1 instrument) summed raw transcript rows. Two
row-shape facts make that wrong, discovered while measuring pair-2:
1. One API turn = one JSONL row PER CONTENT BLOCK. Main-session rows repeat
   the turn's final usage verbatim → v1 OVERCOUNTED main sessions 3-5×
   (factor = blocks/turn, varies with turn shape — NOT a constant scale).
2. Subagent rows carry PROGRESSIVE usage snapshots (output grows per block)
   → naive first-row dedup would UNDERCOUNT hands ~500×.
Fix (v2, calibrated against independent jq aggregations): per .message.id
take the MAX of each usage field; msgs = real turns. Pair-1 numbers in the
original section below are v1-scale; corrected v2 numbers:

| pair-1 (v2 corrected) | Arm C | Arm S |
|---|---|---|
| brain gross → net (minus interrupts) | 10,365 → **7,218** (int1=3,147) | 7,932 → **6,915** (int2=1,017) |
| hand (Opus 4.8) | 24,842 | 0 |

Pair-1 verdict UNCHANGED in direction (naive FAIL: C 4.4% above S — was
misreported as 29% above on the v1 scale); the fixed-dispatch-cost lesson
stands and sharpens: at 60-175-line scale, dispatch overhead ≈ the entire
solo cost. Original v1 section preserved below for the record.

## Pair 2 — RESULTS (2026-07-09, session <session-id>, token-report v2)

Tasks per prereg (A2+B1 after disclosed A1 infeasibility switch):
- Arm S (solo): script-c.sh --remediate/--json + 16-case hermetic
  test suite → commit <sha> (<branch-a> worktree),
  +154/-16 script + 176L test = 330 insertions, 16/16 pass, 0 rework.
- Arm C (handoff): product-app src/lib/feature-b.ts + feature-b.test.ts →
  commit <sha> (<branch-b> worktree off <sha>), 219 insertions,
  full suite 235/235 (10 new feature-b cases), typecheck+lint clean, 0 rework,
  accepted first pass (dispatch/03).

Windows (UTC): T0 19:08:48 → T1 19:15:02 (S, no interrupts) → T2 19:29:21
(C, minus int3 [19:17:03–19:17:12] = 1,482 out — user re-sent the resume
one-liner mid-arm; ack'd inline).

| metric (output tokens, v2) | Arm C | Arm S |
|---|---|---|
| brain (Fable 5) net | **8,030** (9,512 − int3) | **25,612** |
| brain cache_write net | 7,590 | 62,011 |
| hand (Opus 4.8) | 35,936 (22 turns) | 0 |
| artifact insertions | 219 | 330 |
| brain tok/artifact-line | 36.7 | 77.6 |
| wall clock | ~14.3 min (brain idle ~12) | ~6.2 min (brain saturated) |
| rework | 0 | 0 |

### Verdict vs pre-registered E1 primary

**Brain output: −68.6% (8,030 vs 25,612) → clears the ≥40% PASS bar**,
pending the E3 quality floor (below). Secondary metrics same direction:
cache_write −87.8%, brain tok/line −52.7%.

System-total note (honesty): C burns MORE total tokens (8,030 Fable +
35,936 Opus = 43,966) than S (25,612 Fable). The thesis handoff sells is
LEAD-model relief + brain availability, not total-token thrift; blended
$-cost verdict depends on the Fable:Opus price ratio (breakeven ≈ 2.04:1;
ratio not verified today — recorded as formula, not claim).

Cross-pair structural finding (the pre-registered hypothesis, now on a
calibrated instrument): dispatch fixed cost dominates at ≤200-line scale
(pair-1: C 4.4% ABOVE S) and amortizes decisively at ~2× scale with heavy
code-reading (pair-2: 68.6% BELOW). The protocol's economic break-even on
these two data points sits somewhere between the two task sizes; n=1 per
scale — direction consistent, magnitudes not yet generalizable.

Observed unpriced benefits, same direction as pair-1: brain absorbed a
mid-arm user interrupt at trivial cost (1.5k) while the hand kept working;
opening the S-arm repo auto-injected its ~10k-token CLAUDE.md into the
brain's context (input-side) — in arm C that injection lands on the hand.

Confounds carried: same-session slicing; cross-language pair (bash vs TS);
read-burden asymmetry disclosed at lock (~570 vs ~730L, favors-thesis
direction); scout intel symmetric.

## Pair 1 — 2026-07-09 (session <session-id>, measured by token-report.sh **v1 — numbers superseded by the ERRATUM above; direction valid, magnitudes inflated**)

Tasks (both bash-script + tests class):
- Arm C (handoff): dispatch-gate hook prototype → hooks/dispatch-gate.sh
  (88 L) + tests (87 L), 11/11 tests pass, 0 rework, dispatch/02 accepted
- Arm S (solo): token-report.sh (~90 L), 2 self-tests pass, 0 rework

Windows (UTC, interrupts excluded): C = T0 08:53:52 → T1 09:00:20 minus
int1 [08:59:07–08:59:43] (user mid-turn, 6,327 out). S = T1 → T2 09:03:23
minus int2 [09:02:17–09:02:44] (protocol revision, 2,009 out).

| metric (output tokens) | Arm C | Arm S |
|---|---|---|
| brain (Fable 5) net | **26,174** | **20,308** |
| hand (Opus 4.8) | 24,913 | 0 |
| artifact size | 175 lines + 11 tests | ~90 lines + 2 self-tests |
| wall clock | ~6.5 min (brain idle most of it) | ~3 min (brain fully occupied) |
| rework rounds | 0 | 0 |

### Verdict vs pre-registered E1 threshold (honest read)

- **Naive primary metric: FAIL direction.** C-brain 26.2k > S-brain 20.3k —
  brain output did NOT drop; the ≥40% reduction bar is not met on raw numbers.
- Size-normalized (post-hoc, NOT usable as PASS per pre-registration): C ≈150
  tok/line vs S ≈226 tok/line → C 34% cheaper per line of artifact. Recorded
  as protocol-revision candidate (E1 needs a size-normalization rule or
  stricter size-matched pairs), not as a result.
- **Structural finding (the real lesson): dispatch has a fixed brain cost**
  (~write dispatch ~4k + adjudication + status narration) that dominates at
  this task scale (60–175 line artifacts). Handoff's savings thesis lives in
  LARGER tasks where hands absorb read-code/trial-and-error tokens. Pair-2
  should use a bigger, code-reading-heavy task to test the thesis where it
  actually claims value.
- Unpriced benefits observed (not in E1 metric): brain was free during hand
  execution (absorbed 2 user mid-turns + a protocol revision in parallel);
  hand delivered a FULLER test suite than solo (11 tests vs 2 — pre-written
  acceptance criteria forced completeness: spec-first quality spillover).
- Confounds: same-session measurement; heavy cache context penalizes both
  arms' input/cache numbers → compared output tokens only. Interrupt
  exclusion by timestamp is exact (transcript-derived).

E3 (blind quality judging) for pair 1: deferred to next session, batched with
pair 2 (codex read-only, provenance-stripped).

## Pair 2 — PRE-REGISTRATION (locked 2026-07-09 ~10:12 UTC, before any arm work)

User selected pairing A1+B1 (AskUserQuestion, 3 pairings + defer offered).
**Verified-infeasibility switch A1→A2, disclosed here at lock time**: live
verification against origin/main showed A1's surface is NOT on the base —
`global/scripts/script-a.sh` and `global/scripts/script-b.sh`
exist only in unmerged branches (PR <n>, 2026-05-01) + deployed ~/.claude
copies. The scout's "repo refactor" premise read live/disk copies, not the
main baseline. A2+B1 was the disclosed runner-up in the same user question
(described as tightest artifact match); switched autonomously per
cheapest-reversible heuristic. Side observation ledgered: repo-A
main is BEHIND the live system (three stale open PRs hold deployed
content) — separate follow-up, NOT part of this eval task.

- **Arm S (solo — brain implements, status-quo way)**: maintenance-tool
  remediate task in ~/repo-A. Add `--remediate` (dry-run: exact copy commands to
  fix each drifted file, respecting LOCAL_STATE_ALLOWLIST semantics) +
  `--json` (machine-readable report) to `global/scripts/script-c.sh`
  (240L on main, currently zero flag parsing); create
  `global/scripts/test-script-c.sh` (hermetic temp-dir fixture: fabricate
  repo SSOT + drifted ~/.codex, assert exit codes + remediation output; may
  add env-var path overrides to the script as a sub-task). Must NOT break the
  no-arg stderr contract that script-e.sh L105-123 and /sync status grep.
  READ baseline: script-c.sh 240L + script-d.sh 307L +
  script-e.sh caller region (~570L total, verified on origin/main).
  Est. artifact ~180-230L. Branch <branch-a> off origin/main
  in a fresh worktree (parallel-work detection: checkout is on
  an unrelated feature branch with uncommitted changes → worktree MANDATORY).
- **Arm C (handoff — Agent(model:"opus") implements)**: product-app
  feature-b. Set-completion + cost-to-complete module + vitest per
  an internal product proposal doc (a committed feature). CREATE src/lib/feature-b.ts +
  src/lib/feature-b.test.ts. READ: collections.ts 205L + collection.ts 130L +
  sets.ts 86L + types.ts 183L + catalog.ts 30L + stats.ts 100L (~730L/6
  files). Est. artifact ~180-230L. Worktree branch <branch-b> off HEAD
  <sha> (verified); the dirty in-flight UI files stay untouched.
  Full protocol: DISPATCH file dispatch/03, evidence persisted, adjudication
  with independent verify re-run.

Order: **S first, then C** (arms crossed vs pair-1's C/S). Boundaries:
T0 = arm-S work begins (incl. its worktree setup + reading); T1 = arm-S
done / arm-C begins (dispatch writing + adjudication INSIDE the C window —
protocol cost is priced in, that is the honest test); T2 = arm-C accepted.
Interrupt/exclusion windows logged live as they occur.

Metrics & thresholds: unchanged from EVAL_PROTOCOL.md E1 (primary: brain
output tokens, PASS ≥40% drop C vs S; measured by
~/.claude/skills/handoff/scripts/token-report.sh timestamp slicing of THIS
session, output tokens only per pair-1 cache-confound precedent). Secondary
recorded: tok/line, wall-clock, rework count, hand tokens.

Known asymmetries disclosed at lock: (1) C-task read burden heavier (~730 vs
~570L) — direction favors the handoff thesis; guarded by E3 quality floor
+ tok/line secondary. (2) Cross-language pair (bash/jq+python-toml vs
TS/vitest) — accepted; pair-1 was same-class, crossing classes across pairs
adds external validity. (3) Both arms start from equivalent scout intel
(the two Explore sweeps), symmetric by design. (4) Same-session measurement
confound carried over from pair-1 (heavy cache context; output-tokens-only
comparison).

## E2 blind relay — 2026-07-09: **9/10 PASS** (bar ≥9)

Subject: fresh session <session-id> (Fable 5, zero conversation history; SAME
model class + machine as session A → no portable-bonus claim). Resumed from
one line ("Resume from ~/handoff-eval/STATE.md"), read ledger files only,
locked E2-RESPONSES.md 09:44 UTC BEFORE any other work; sealed file untouched
pre-lock. Contamination surface self-declared in the responses header
(a cross-session-memory startup note title leaked the Q5 headline).

Judge: codex exec gpt-5.5, read-only sandbox, session <session-id> (44.5k tokens),
scored against the sealed sheet.

Scores: 8× CORRECT; Q5 PARTIAL (facts fully matched but discounted per the
declared memory leak — the declaration mechanism worked as designed);
Q9 PARTIAL (subject counted the E2 answer step itself among the "next two
items"; sealed intent was pair-2 + E3). Zero redone accepted work; zero user
rescue interventions during the resume. All three pre-registered PASS
conditions met.

Judge NOTES → protocol improvement applied: STATE template's Next Session
Entry Point now mandates separating the ENTRY action ("First:") from the
roadmap ("Then:") — the Q9 ambiguity came from the ledger, not the subject.

Channel-B incidents during judging (ledgered for the eval report; all three
share one meta-lesson — the brain must use routing.md Invoke shapes verbatim):
1. Backgrounded `codex exec "<arg prompt>"` hung 14 min draining open non-TTY
   stdin → killed (stale-hands probe: zero CPU), re-dispatched `</dev/null`.
   routing.md failure-modes updated.
2. cwd outside a git repo → exit 1 without `--skip-git-repo-check` (flag was
   ALREADY documented at routing.md L81; brain hadn't consulted its own manual).
3. Post-lock unsealing: brain polled the judge's raw stdout mid-run; codex
   stdout echoes tool outputs (full file reads), so the sealed sheet entered
   brain context ~10:01 UTC — AFTER the 09:44 lock, E2 integrity unaffected.
   routing.md Evidence-return now warns: read only the `-o` final message.

## E3 blind quality judging — 2026-07-09: **PASS both pairs**

Setup: 4 provenance-stripped artifacts (pair-1: reconstructed-original
token-report.sh vs dispatch-gate hook+test; pair-2: both commits as
patches), randomized A/B per pair (mapping withheld from judge), graded by
codex (gpt-5.5, read-only) on correctness/completeness/idiom. First judge
(both pairs, xhigh) stalled ~16 min → stale-hands kill; re-dispatched as
two narrower per-pair judges at high effort (both returned in ~5 min).

| dimension | p1 S (tokenreport) | p1 C (hookgate) | p2 S (maint-tool) | p2 C (feature-b) |
|---|---|---|---|---|
| correctness | C | B | B | A |
| completeness | B | B | A- | A- |
| idiom | B | B | B | A- |

Rule "C not >1 grade below S on any dimension": PASS both pairs — in fact
C ≥ S on EVERY dimension in both pairs, and each pair's only concrete
defects live in the SOLO artifact. First-pass acceptance: C needed ≤1 more
rework than S — both pairs 0 vs 0. ✓

Convergent validation: the blind judge independently re-discovered the
pair-1 S artifact's row-dedup counting bug (the same bug behind today's
MEASUREMENT ERRATUM) plus non-POSIX awk `length(arr)` and unstable output
order. Judge's pair-2 S defects (unescaped single-quotes in emitted
commands; unescaped sed replacement metacharacters for $HOME; `--json`
record split without validation) are real minor issues → logged as
follow-ups in STATE.md (post-eval fixes; artifacts judged as committed).
Small-n caveat: two pairs, but the pattern matches pair-1's "spec-first
quality spillover" observation — pre-written acceptance criteria produced
the cleaner artifacts.

## CONSOLIDATED VERDICT (2026-07-09) — see EVAL_REPORT.md
