# DISPATCH: <nn>-<kebab-title>

> Status: pending | running | returned | accepted | rework-<n> | abandoned
> Channel: agent-opus | agent-opus-worktree | codex | codex-write | async-queue | <other>
> Dispatched: <yyyy-mm-dd hh:mm> | Spec: <path to proposal/design/plan; "inline" only for no-repo scratchpad work>
> Workspace: <absolute repo/worktree path the hand must work in>

<!-- Status ownership: brain sets pending→running at send; returned only when
     evidence is persisted below; accepted/rework/abandoned are brain-only. -->

<!-- This file IS the prompt sent to the executor, verbatim (or by path).
     It is committed as the permanent record of what was asked and why.
     Fill every section; write "none" rather than deleting a section. -->

## Context

<Self-contained background. The hand starts COLD — assume zero conversation
context. Cover: what the project is, where this task sits in the larger change,
exact file paths involved, current verified state (facts you checked, not
guesses), and what prior dispatched tasks already produced.>

## Task

<One task, clearly bounded, completable in a single run. If you are tempted to
write "and also…", split into another dispatch.>

## Constraints

- <What must NOT change: public APIs, directories out of scope, no new deps…>
- <Existing patterns to follow — point at concrete file:line exemplars>
- <Style/testing requirements: TDD required? match repo idiom?>

## Acceptance Criteria

<!-- Written BEFORE execution. Each item mechanically checkable —
     a command output or a directly observable fact, never "code is clean".
     Every gate names its EXACT scope (files/package/tree): a tree-wide gate
     over a repo with pre-existing debt ("gofmt -l . empty") forks into
     letter-vs-spirit readings — MoA contest #1 lesson, 2026-07-20. -->

- [ ] <criterion 1>
- [ ] <criterion 2>

## Verify (run these; paste real output)

<!-- LITERAL, runnable commands ONLY — no <placeholders>. This block is
     machine-executed by scripts/adjudicate.sh at adjudication; a placeholder
     breaks tooling. If the exact command must be discovered by the hand,
     write a discovery command here (e.g. `ls tests/`) and require the final
     command in Returned Evidence. -->

```bash
<exact commands the hand must run — test suite, build, lint, live probe>
```

## Evidence to Return

Your final message MUST contain exactly, in order:

1. Acceptance checklist with ✅/❌ per item (❌ requires one line why)
2. Verify command output — the decisive lines, verbatim (not "tests pass")
3. `git diff --stat` (if code changed) + commit hash(es) if you committed
4. Deviations & discoveries — anything done differently from this dispatch,
   anything learned that affects other tasks ("none" if empty)
5. Blockers — what stopped you, what you need ("none" if empty)

Do NOT return full file contents or long logs; the brain adjudicates on
evidence, not on re-reading your work.

**Persist before returning**: if you have write access to THIS dispatch file,
append your evidence under `## Returned Evidence <n>` below before sending your
final message (the file, not the conversation, is the durable record). If you
cannot write it, the brain will record your returned evidence verbatim.

---

<!-- Filled per round-trip (hand-appended or brain-recorded): -->

## Returned Evidence <n>

<verbatim evidence block, per the format above>

## Adjudication

- <yyyy-mm-dd hh:mm> — verdict: accepted | rework — <one-line reason;
  which verify command the brain re-ran and its result>

## Rework <n> (only if verdict was rework)

<What was wrong, what to change. Same acceptance criteria unless restated here.>
