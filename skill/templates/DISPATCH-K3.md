# DISPATCH-K3 template — brain → Kimi K3 executor (frontend/vision primary; backend contest-proven)

> Distilled from the first live-validated K3 dispatches (2026-07-19/20) plus
> Moonshot's official K3 limitations. K3 is #1 on WebDev Arena for frontend
> implementation (above the frontier lead models) — but it over-improvises and
> is thinking-history sensitive, so the brief must fence it harder than a
> default-channel hand.
> Backend is NOT off-limits: in the first head-to-head contest (a Go parser
> fix, identical specs) K3 beat an Opus 4.8 hand 99-96 — under a hard-boundary
> brief it delivered deeper mechanism analysis, wider test coverage, and
> cleaner TDD history (winning PR:
> https://github.com/zelinewang/claudemem/pull/10; protocol in
> references/routing.md §MoA-leader).
>
> Delivery: launch through your detached runner (routing.md ch. D — nohup +
> disown, state dir with prompt/log/pid/exit), ONE long run — never split one
> task into short -p relays; thinking history dies across cold starts. Watch
> with a supervisor that owns its own process (e.g. Claude Code's Monitor
> tool) on the exit file AND pid liveness — plain background-shell watchdogs
> get reaped on long waits (field observation ×2, 2026-07-20).

# DISPATCH <ID> — <one-line task name>

Status: running · Sent: <date> · Channel: Kimi K3 (claude -p env override) · Spec: this file

## WHY (read first)
<Business context. Why this matters, what was rejected before, where the bar
is. K3 performs to the bar you articulate — set it explicitly.>

## CONCRETE TASK / DEFECT LIST
<Numbered, verifiable items. Each one must be checkable by evidence — "fix X
so that Y is observably true". Vague items invite improvisation.>

## DIRECTION
<Lettered design/implementation direction (A., B., C…). Opinionated guidance;
K3 follows strong direction well. Name reference implementations if any.>

## HARD CONSTRAINTS  ← K3-critical (official limitation: over-improvisation)
- Scope fence: <exactly which files/dirs are in scope>
- FORBIDDEN (git diff must not touch): <files/paths — auth, contracts, infra>
- <Data/contract invariants that must survive>
- Never push the default branch. Work in <worktree>, branch <branch>. Push
  branch, open PR (or commit-only for contest mode).
- On genuinely ambiguous product decisions: do NOT improvise beyond this brief
  — write the open question into Returned Evidence and take the most
  conservative option that satisfies the brief.

## ACCEPTANCE (walk EVERY box)
<!-- Authoring rule (contest #1 lesson): every gate names its EXACT scope —
     files / package / tree. A tree-wide gate over a repo with pre-existing
     debt ("gofmt -l . empty") forks into letter-vs-spirit readings and
     inflates one hand's diff. Scope every gate explicitly. -->
- [ ] <build/render check with exact command>
- [ ] <screenshots regenerated + K3 SELF-REVIEWS them with vision, iterates>
      (keep dispatch subprocesses slim — strict MCP config; use plain shell +
      npx playwright for capture)
- [ ] typecheck + lint + tests green (never weaken an assertion)
- [ ] <docs/traceability updated>
- [ ] No secrets, no forbidden files in diff

## EVIDENCE (contract)
Append `## Returned Evidence <ID>` to THIS file with: what changed (before →
after), each task/defect item's fix + which artifact proves it, test numbers,
PR number, open questions, honest self-verdict. Final message = same content.

---
Brain-side verification loop after DONE (routing.md channel D has the full
protocol): read the diff + screenshots YOURSELF → second-model image check on
visual claims → independent review channel for code → rework via a NEW
self-contained dispatch (reference prior evidence; K3 never resumes another
model's — or its own cold — partial thinking).
