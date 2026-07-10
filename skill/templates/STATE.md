# STATE: <change-name>

> Updated: <yyyy-mm-dd hh:mm> by <session/machine hint> | Phase: <e.g. /dev P7, task 3/6>

<!-- The single source of truth for handoff. ANY fresh session (or another
     machine/agent) must be able to resume from this file + dispatch/ headers
     alone — no conversation transcript required.
     Update at EVERY adjudication, never "later". Keep each section current,
     not append-only (Decisions Log is the only append-only section). -->

## Goal

<One sentence: the end state + how we'll know it's done (success criterion).>

## Now

<One line: what is in flight right now, and on which channel.
 e.g. "dispatch/03 running on agent-opus (worktree ../repo-task3); brain idle">

## Done

- [x] <nn>-<task> — evidence: dispatch/<nn> accepted, commit <hash>

## Todo (roadmap order)

- [ ] <nn>-<task> — <one-line scope; blocked-by if any>

## Blockers / Problems

<Live obstacles needing decision or external input. "none" if empty.>

## Decisions Log (append-only)

- <yyyy-mm-dd> — <decision> — <why> <(supersedes which earlier decision, if any)>

## Next Session Entry Point

<Imperative, one or two lines. Label the ENTRY action ("First: ...") separately
 from what follows ("Then: ...") — a resuming session must not mistake its own
 entry step for a roadmap item (E2 eval lesson, 2026-07-09).
 e.g. "First: re-run pytest tests/test_x.py, adjudicate dispatch/04 (returned).
 Then: dispatch 05 per Todo.">
