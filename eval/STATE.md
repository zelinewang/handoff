# STATE: conductor-skill-v1

> Updated: 2026-07-09 ~13:40 UTC by fable-session-<session-id> | Phase: post-eval batch wave 04/05/06 in flight

## Goal

Validate conductor (brain/hands delegation skill: token tiering + spec-tracked
lossless handoff) via the pre-registered eval (EVAL_PROTOCOL.md), then package
it portable for team sharing; repo stays PRIVATE-first, public flip is a
user-only decision after eval passes.

## Now

**BATCH WAVE 04/05/06 IN FLIGHT** (first real batch-dispatch, 3 opus hands
parallel): 04 drift E3 defect fixes (hand-drift, worktree
repo-A-drift-remediate) · 05 adjudicate.sh helper
(hand-adjudicate, skill scripts/) · 06 portable repo content build
(hand-repo, ~/conductor-repo/, sanitization = hard gate). User gave repo
go-ahead 2026-07-09 (build PRIVATE; public flip stays user-only). Brain will:
adjudicate as evidence returns → re-rsync skill/ into repo → gh repo create
--private + push → README final pass. /sync apply still pending (user).

## Done

- [x] conductor skill v1 shipped: SKILL.md + templates/{DISPATCH,STATE}.md +
      references/routing.md + CLAUDE.md trigger row + async-queue channel ref
- [x] codex heterogeneous review: 10 findings triaged, 9 accepted + 1 partial,
      all fixes applied (critical: evidence must persist into dispatch file)
- [x] dispatch/01 routing.md — accepted (evidence in file)
- [x] dispatch/02 dispatch-gate hook prototype — accepted, 11/11 tests,
      UNREGISTERED by design (v2 pending friction review + live payload capture)
- [x] Protocol revisions mid-flight: read-only consultation exception;
      capability-first routing (Opus 4.8 default, model param REQUIRED,
      downshift Sonnet 5/GLM only at rework-risk≈0); parallel-mutation
      integration rule; stale-hands rule; commit ownership; status ownership
- [x] scripts/token-report.sh built + self-tested (arm S artifact)
- [x] E1 pair-1 measured → EVAL_RESULTS.md (naive metric FAIL direction,
      fixed-dispatch-cost lesson, pair-2 must be larger code-reading task)
- [x] E2 armed: E2-QUESTIONS.md + E2-ANSWERS-SEALED.md (judge only)

## Todo (roadmap order)

- [x] E2 blind relay (answer step): E2-RESPONSES.md written 2026-07-09
      09:44 UTC by session <session-id>, before any other work; SEALED file not
      read by subject
- [x] E2 judging: codex judge 9/10 PASS (Q5 PARTIAL by declared-leak
      discount, Q9 PARTIAL by ledger ambiguity — template fixed); full
      record in EVAL_RESULTS.md; user may re-judge against the sealed sheet
- [x] Eval pair 2 (E1): A2+B1 run S→C 2026-07-09 19:08–19:29 UTC; brain
      output −68.6% (v2 instrument) — PASS at scale; details EVAL_RESULTS.md
- [x] E3 blind judging pairs 1+2: PASS both (two per-pair codex judges
      after first both-pairs judge stalled; C ≥ S every dimension)
- [x] Eval report written → EVAL_REPORT.md (verdict: revised-protocol PASS;
      honesty notes: measurement erratum, system-total cost, small n)
- [ ] Build portable private repo (skill/ install.sh docs/ examples/ eval/),
      run pre-public-sweep, hand public-flip decision to user — cleared to
      start per PASS, held for user go-ahead (sequencing vs /sync apply)
- [ ] E3 follow-up fixes on feat/codex-drift-remediate (blind-judge finds:
      single-quote escaping in emitted commands, sed replacement-metachar
      escaping for $HOME, --json split validation) — post-eval, unpushed
- [ ] product-app product decision (user): binder denominator singles-only vs
      incl. sealed (one-line filter, see dispatch/03 adjudication) — before
      any feat/binder PR
- [ ] User: /sync apply (still pending for ~/.claude conductor changes,
      now incl. routing.md economics + failure modes, STATE template,
      token-report v2)

## Blockers / Problems

none

## Decisions Log (append-only)

- 2026-07-09 — Default channel Agent(model:opus); ≤5-line hands-on line; v1
  enforcement = skill flow (user-confirmed)
- 2026-07-09 — Read-only consultations exempt from DISPATCH file; conclusions
  must be ledgered
- 2026-07-09 — GLM/3rd-party = channel D via claude -p env override, unverified
- 2026-07-09 — Evidence must persist into dispatch file before status=returned
  (codex critical finding)
- 2026-07-09 — Capability-first routing (user directive): strongest hand
  first, rework cost > price delta; model param REQUIRED on every dispatch
- 2026-07-09 — Eval: repo deferred until eval passes (user); pair-1 ran C/S
  same-session with timestamp slicing; interrupts excluded by exact windows
- 2026-07-09 — Monitor sentinel lesson: watch-conditions must use strings
  absent from the watched file's initial content (false-trigger incident)
- 2026-07-09 — Stale-hands incident (E2 judge, channel B): backgrounded
  `codex exec "<arg prompt>"` hangs forever draining open non-TTY stdin;
  probe showed 14-min zero-CPU → killed, re-dispatched with `</dev/null`
  + `--skip-git-repo-check` (cwd not a repo). routing.md failure-modes
  updated; logged to cross-session memory. Meta-lesson: brain must consult its own
  routing.md Invoke shapes before dispatching (skip-flag was already at L81)
- 2026-07-09 — E2 = 9/10 PASS (codex judge). Protocol fix applied from judge
  NOTES: STATE template entry point now separates "First:" (entry action)
  from "Then:" (roadmap). Incidental post-lock unsealing via judge stdout
  echo ledgered in EVAL_RESULTS.md; routing.md warns: read -o final msg only
- 2026-07-09 — Pair-2 candidate sweeps (2× Explore(opus), read-only,
  conclusions ledgered per protocol): S-arm (repo-A) →
  (A1) secret-scan-unify: merge 4 divergent secret-regex sets into sourced
  lib + tests; read ~460L/4 files, artifact ~200-240L; real coverage gaps
  verified; lowest blast radius. (A2) codex-drift-remediate: --remediate/
  --json for codex-drift-check.sh; read ~550L, artifact ~180-230L; additive.
  (A3) sync-scan-lib: fix hooks' symlink+repo-only scan blindness; highest
  value BUT touches 2 of 3 self-heal files — branch-only safe. C-arm →
  (B1) product-app binder.ts: set-completion + cost-to-complete lib+vitest;
  read ~730L/6 files, artifact ~180-230L; committed round-12 feature,
  conflict-free off HEAD 5993d50 (27 dirty UI files must stay unstaged).
  (B2) product-app-2 deps.py: multi-node invalidation closure + waive-ledger
  integrity (catches real dead key cp2->cp5); read ~500L, artifact
  ~150-200L; pytest stdlib. (B3) product-app stats.ts condition ladder:
  smaller (~120-170L), display consumers dirty — weakest fit.
  Rejected: product-app cron (user-blocked OAuth), product-app-2 platform-buglist
  (targets other repos)
- 2026-07-09 — Pair-2 = user-selected A1+B1, then A1→A2 switch at prereg
  lock: A1's files (sync-secret-scan.sh, pre-public-sweep.sh) NOT on
  origin/main — live only in unmerged PR #25 + deployed copies. A2+B1 was
  the disclosed runner-up in the same user question. Lesson: scout reports
  read disk/live state; prereg MUST re-verify against the branch BASE.
  Side observation (separate follow-up, not this eval): repo-A
  main is behind the live system; stale PRs #25/#31/#32 hold deployed content
- 2026-07-09 (build session, post-eval) — Model tiering DECOUPLED from
  conductor into CLAUDE.md §Agent Spawn Model Tiering (unconditional, all
  spawn channels; Workflow agent() default inherits Fable = trap; fork always
  Fable). Ceremony CONDITIONALIZED: full DISPATCH protocol only at ≥200L
  artifact / ≥500L read / handoff-bound / multi-dispatch / parallel mutation;
  tactical spawns inline (git commit = trail)
- 2026-07-09 (user directive, tripled) — FLAGSHIP-FIRST supersedes downshift
  language: opus = FLOOR for execution/review/recon alike; sonnet/haiku
  near-retired (pure-glue only); ECC reviewers' sonnet pins overridden with
  model:"opus" at spawn (defense-line roles get flagship); Fable spawn needs
  stated reason
- 2026-07-09 — SKILL.md gains scale-estimation method (±30% of boundary →
  treat as above) + batch-dispatch section (write N dispatches in one
  sitting, one parallel wave, fixed costs ÷N); this wave (04/05/06) is its
  first live use

## Next Session Entry Point

First: read EVAL_REPORT.md (canonical verdict) + confirm with the user the
portable-repo build go-ahead and its sequencing vs the pending /sync apply
(repo packaging duplicates ~/.claude/skills/conductor content — sync first
avoids divergence).
Then: build the portable PRIVATE repo (skill/ install.sh docs/ examples/
eval/ with EVAL_REPORT.md + EVAL_RESULTS.md + dispatches as evidence), run
pre-public-sweep, and hand the public-flip decision to the user. Also on
deck: E3 follow-up fixes on feat/codex-drift-remediate (see Todo).
Directory: ~/conductor-eval/. Cross-session memory: durable lessons saved to
the cross-session memory system (skill notes, codex gotchas, transcript usage
row shapes).
