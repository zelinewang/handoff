---
name: conductor
description: Token-tiered delegation protocol — the lead model (the "brain") designs, writes dispatch specs, and adjudicates evidence; cheaper executors (subagents on a strong non-lead model, an external CLI agent, an async agent queue) burn the execution tokens. Every dispatch is a spec file on disk (DISPATCH = prompt = record) plus a STATE ledger, so any session can hand off or resume losslessly. Use when delegating implementation to subagents/CLI-agents/an async queue, when saving lead-model tokens, when work must survive session handoff, or as the execution layer for /dev P7 on STANDARD+ tasks.
---

# Conductor — Brain/Hands Delegation with Spec-Tracked Dispatch

One protocol, three guarantees:

1. **Token tiering** — the brain (lead model) only thinks, designs, and adjudicates;
   hands (cheaper/heterogeneous models) read code, write code, run tests, fix errors.
2. **Dispatch = spec** — the prompt sent to a hand IS a file on disk. Writing the
   prompt and writing the record are the same act. Zero extra documentation friction.
3. **Ledger continuity** — a STATE.md ledger makes goal/status/roadmap/blockers
   recoverable by ANY future session (or machine, or agent) without this conversation.

## Role Contract

| Actor | Does | Never does |
|-------|------|-----------|
| **Brain** (lead model, this session) | Investigate conclusions, design, write specs & DISPATCH files, route, adjudicate evidence, update ledger, decide | Read full code bodies during execution, write >5-line code changes, re-derive what evidence already shows |
| **Hands** (non-lead subagent / external CLI agent / async queue) | Read whole files, implement, run tests, fix build errors, produce evidence in the mandated format | Redefine scope, skip verify commands, return prose instead of evidence |

**Hands-on line**: the brain may directly edit only trivial changes (≤5 lines:
config value, typo, one-line fix) where dispatch overhead exceeds the work itself.

**When the DISPATCH ceremony applies** (measured boundary, eval 2026-07-09):
the full DISPATCH-file protocol is REQUIRED when ANY of: artifact ≥~200 lines
or code-reading ≥~500 lines; work must survive session handoff; part of a
multi-dispatch project (a STATE.md exists); parallel hands mutating files.
Below ALL of those, tactical spawns — including small state-mutating ones —
may use inline prompts: the native Agent tool stays fast and free-form, and
the audit trail is the git commit itself. Model Tiering (CLAUDE.md §Agent
Spawn Model Tiering) is UNCONDITIONAL either way: conductor is a ceremony
you enter when scale warrants; non-Fable spawning is a rule you never exit.

**Estimating scale** (30 seconds, before choosing): artifact lines ≈ files
touched × expected delta per file (or the plan task's own estimate);
code-reading lines ≈ `wc -l` of the files the hand must actually open,
rounded up. Within ±30% of a boundary → treat as ABOVE it (ceremony is
cheaper than a mis-sized solo).

**Batch dispatch (amortize the ceremony)**: when a project yields N
independent dispatchable units, write ALL dispatch files in one sitting and
spawn the hands in ONE parallel wave (each with explicit model; worktree
isolation only where they mutate the same repo). The brain's fixed costs —
context recall, templates, ledger update — amortize ÷N, which is how
mid-size tasks clear the 200/500 break-even. Adjudicate as evidence returns;
never barrier-wait unless units are interdependent.

**Read-only consultation exception**: dispatches that mutate nothing (reviews,
second opinions, investigation sweeps) may use an inline prompt without a
DISPATCH file — but their conclusions MUST land in STATE.md (or the relevant
dispatch's Adjudication section). State-mutating work always requires the file.

## Routing Tree

```
incoming work unit
├─ thinking / design / spec / adjudication ........ Brain does it (its actual job)
├─ ≤5-line trivial edit ........................... Brain edits directly
├─ small task (<~200 lines artifact AND <~500
│  lines code-reading) ............................ solo is cheaper (+4.4% if
│                                                    dispatched) — dispatch only for
│                                                    parallelism / test rigor. Above
│                                                    EITHER bound: dispatch wins big
│                                                    (−68.6% brain output, eval 2026-07-09)
├─ implementation with a clear spec ............... Agent(model:"opus")   ← DEFAULT
│    ├─ N independent tasks ....................... Agent(opus) × N in parallel
│    ├─ parallel file mutation .................... + isolation:"worktree"
│    └─ domain-matched ECC agent exists ........... + agentType (e.g. python-reviewer)
│                                                    + model:"opus" override (their
│                                                    sonnet pins are below the floor)
│  ⚠ model param is REQUIRED on every dispatch — omitted = inherits the lead
│    model (Fable) silently, zero saving. Never fork (forks always inherit).
│  ⚠ FLAGSHIP-FIRST (user directive): every hand gets the strongest sub-Fable
│    model that 100%-covers the purpose — opus for execution, review, AND
│    recon alike. sonnet/haiku near-retired (pure-glue only; prefer plain code
│    there). Reviewers/verifiers especially — defense-line roles get flagship
│    capability; a missed defect costs ~100× the per-token saving.
│    Hard ceiling unchanged: never spawn Fable without an explicit reason.
├─ independent second opinion / review ............ codex exec (read-only)
├─ brain's approach failed 3× / stuck ............. codex exec (heterogeneous reframe)
├─ large self-contained build-out ................. codex exec -s workspace-write (full hand-off via DISPATCH)
├─ >30 min / cross-repo / user leaving / cron ..... async agent queue (your team's dispatch system)
└─ third-party model (GLM etc.) — optional ........ claude -p + env override (references/routing.md)
```

Channel mechanics, exact commands, and model notes: `references/routing.md`.

> Why not fork? Fork subagents inherit the parent model — a Fable fork is still
> Fable. Only non-fork `Agent(model:"opus")` actually downshifts execution cost.

## Task Workspace (where files live)

| Situation | Workspace |
|-----------|-----------|
| Project has `openspec/` | `openspec/changes/<name>/` → existing proposal/design/tasks + add `dispatch/` + `STATE.md` |
| Git repo, no openspec | `docs/plans/<yyyy-mm-dd>-<name>/` → `plan.md` + `dispatch/` + `STATE.md` |
| No repo (ops/research) | scratchpad `dispatch/` + STATE.md — EPHEMERAL; the durable audit trail is a note in your cross-session memory system summarizing ledger + outcomes |

In repos: never invent a new top-level directory; `dispatch/` and `STATE.md`
live inside the workspace above and are committed with the work (they ARE the
audit trail). `Spec: inline` in a dispatch header is valid only for no-repo
scratchpad work — repo-backed dispatches point at a real plan/proposal file.

**Parallel mutation integration**: when N worktree hands mutate in parallel,
STATE.md must record base commit, each branch/worktree path, merge order, and
who resolves conflicts (default: brain dispatches an integration task). The
full verify suite runs once more AFTER integration — per-hand green is not
integration green.

## Dispatch Protocol

1. **Write the DISPATCH file** from `templates/DISPATCH.md`:
   Context (self-contained — the hand starts cold), Task, Constraints,
   Acceptance Criteria (pre-written, mechanically checkable), Verify commands,
   Evidence-return format. Acceptance criteria are written BEFORE execution —
   Begin from the End.
2. **Send it** — hands with filesystem access get the PATH only (they read the
   file); hands without file access get the content pasted ONCE, never
   duplicated elsewhere. One dispatch = one task = one file.
3. **Hand executes** and returns evidence in the mandated format. Evidence must
   be PERSISTED into the dispatch file (`## Returned Evidence <n>`): hands with
   write access append it themselves before returning; otherwise the brain
   records it verbatim on receipt. No persisted evidence → status stays
   `running`, never `returned`.
4. **Brain adjudicates** — see below.
5. **Update ledger** — DISPATCH header status + STATE.md, then commit (in repos).

**Status ownership** (state machine): brain sets `pending→running` at send;
`returned` is recorded when evidence is persisted (hand or brain); only the
brain sets `accepted` / `rework-<n>` / `abandoned`. Timestamp every transition.

**Commit ownership**: hands may commit only on their isolated task branch /
worktree (TDD per-task commits). The mainline/integration commit happens after
brain adjudication — by the brain or as an explicitly dispatched follow-up.
Unaccepted work never reaches the shared branch.

## Adjudication (brain-side, evidence-only)

- Judge against the acceptance checklist. Do NOT re-read the full implementation;
  read diff stat + verify output, spot-check the riskiest hunk at most.
- **Risk-tiered depth**: for high-risk changes (security/auth, data & migrations,
  public API, infra/deploy, cross-module) evidence alone is NOT enough — add a
  read-only review dispatch (ECC reviewer agent or `codex exec review`) over the
  full diff; the brain consumes its verdict, still not the raw diff.
- Self-reported ✅ is a claim, not proof: re-run at least one verify command
  (or confirm CI) before accepting. Iron Law applies — no evidence, no accept.
- Verdicts:
  - **accepted** → mark DISPATCH `status: accepted`, tick STATE.md Done, commit.
  - **rework** → append a `## Rework <n>` section to the SAME dispatch file
    (history preserved), continue via SendMessage (agents) / `resume --last`
    (codex) / issue comment (async queue).
  - **3× rework failed** → escalation, in order of preference: (a) write a
    narrower replacement dispatch, (b) switch channel (opus↔codex), (c) brain
    takes over as an explicitly logged emergency exception (scope + tests +
    evidence recorded in STATE.md Decisions — this suspends the hands-on line
    for that one task, never silently).

## Ledger & Recovery

`STATE.md` (from `templates/STATE.md`) is the single source of truth:
Goal / Now / Done / Todo / Blockers / Decisions / Next Session Entry Point.

- Brain updates it at every adjudication — never batch at session end.
- **Recovery**: a fresh session reads `STATE.md` + the full text of any
  non-accepted `dispatch/*` files (headers alone are not enough — context,
  criteria, and persisted evidence live in the body). That is the whole
  handoff — no transcript needed.
- **Stale hands**: if an in-flight dispatch exceeds its expected duration,
  probe the channel (TaskList / BashOutput / your queue's task-status command). Dead or
  hung → set `status: abandoned` (workspace details preserved in the file),
  log in STATE.md, then re-dispatch or switch channel. Never leave `running`
  status unprobed across a session boundary.
- Your cross-session memory system stores durable lessons, not task state.

## Brain Token Discipline

- Investigation: dispatch Explore/opus agents to sweep; brain consumes conclusions.
- Execution: brain's context receives only DISPATCH files (it wrote them) and
  evidence summaries — never full file bodies from hands.
- Do not restate dispatch content in conversation; reference the path.
- Parallelize hands whenever tasks are independent; brain stays idle-cheap while
  hands run.

## /dev Integration

When running inside `/dev` (STANDARD/DEEP): each P5 plan task maps to one
DISPATCH file; P7 EXECUTE routes through this tree instead of the brain
implementing; P8 verify-dev.sh and the 7 Rules stay authoritative. Conductor
replaces WHO executes, never WHICH gates apply. QUICK-tier /dev tasks skip
conductor (they are near the trivial line by definition).

## Anti-Patterns

| Anti-pattern | Why it breaks the system |
|---|---|
| Dispatching PROJECT-SCALE work (≥200L/≥500L-read, multi-dispatch, handoff-bound) from an ad-hoc prompt | Kills the audit trail where it matters — the record IS the prompt. Tactical sub-scale spawns are exempt (git commit = their trail) |
| ANY spawn without an explicit model param (any channel, ceremony or not) | Silently inherits Fable — defeats the entire token-tiering goal (CLAUDE.md §Agent Spawn Model Tiering) |
| Brain "just quickly" implementing a 50-line change | Token tiering collapses; also skips the spec |
| Accepting on the hand's ✅ without re-running a verify | Iron Law violation; hands over-report success |
| Rework by rewriting a NEW dispatch file | History lost; append Rework sections instead |
| STATE.md updated "later" | Later = never; ledger loses handoff value |
| Copying hand output wholesale into conversation | Burns the brain tokens the protocol exists to save |
