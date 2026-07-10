# DISPATCH: 01-routing-reference

> Status: accepted
> Channel: agent-opus
> Dispatched: 2026-07-09 | Spec: ~/.claude/skills/handoff/SKILL.md
> Workspace: ~/.claude/skills/handoff/

## Context

A new Claude Code skill `handoff` was just created at
`~/.claude/skills/handoff/`. It defines a brain/hands delegation
protocol: the lead model designs and writes DISPATCH spec files; cheaper
executors implement. Read these files first — they are the authoritative spec:

- `~/.claude/skills/handoff/SKILL.md` (the protocol; its Routing
  Tree section references `references/routing.md` — the file YOU are creating)
- `~/.claude/skills/handoff/templates/DISPATCH.md`
- `~/.claude/skills/handoff/templates/STATE.md`

Verified facts you must build on (already checked by the brain):

- `codex` CLI v0.139.0 installed. `codex exec [PROMPT]` runs non-interactive;
  supports stdin; `codex exec resume <id|--last> [PROMPT]` continues a session;
  `codex exec review` exists; `-c key=value` overrides config (e.g. model).
- An async agent queue (an internal dispatch tool) is available. Its operating
  rules live in the tool's own manual — reference that manual, do NOT duplicate
  its content. Known gaps (from project memory): the queue's agents currently
  run with 0 MCP servers; its managed repo checkout has a registration gap
  (fall back to `gh repo clone`).
- Claude Code `Agent` tool: `model` param accepts sonnet|opus|haiku|fable
  (opus → Opus 4.8). `subagent_type` selects agent definitions (e.g.
  `general-purpose`, ECC reviewers like `everything-claude-code:python-reviewer`).
  `isolation: "worktree"` gives a fresh git worktree. A running agent can be
  continued with the `SendMessage` tool (by agent name/ID). FORK subagents
  inherit the parent model — fork can NEVER downshift cost; only non-fork
  `Agent(model:"opus")` does.
- Third-party Anthropic-compatible providers (e.g. GLM) can run Claude Code
  headless via `claude -p "<prompt>"` with `ANTHROPIC_BASE_URL` +
  `ANTHROPIC_AUTH_TOKEN` env overrides. This is NOT configured/verified on
  this machine — document as an optional variant with an explicit
  "unverified — smoke-test before first use" warning.

## Task

Write `~/.claude/skills/handoff/references/routing.md` — the
channel operations manual referenced by SKILL.md. For EACH channel
(A: Agent(opus) subagent, B: codex exec, C: async agent queue, D: third-party via
claude -p), document exactly four aspects:

1. **When** — routing conditions (must match SKILL.md's Routing Tree, don't
   contradict it)
2. **Invoke** — copy-pasteable call shape (tool-call parameters for A;
   real shell commands for B/C/D)
3. **Steer** — how to do multi-turn correction/rework on that channel
   (A: SendMessage; B: `codex exec resume --last`; C: issue comment; D: n/a)
4. **Cost & limits** — token/latency characteristics, known gaps, failure modes

Also include a short "Evidence return" note per channel: how the DISPATCH
evidence format flows back (A: agent final message; B: codex stdout; C:
the queue's task output).

## Constraints

- English. Max ~200 lines. Match the terse, table-friendly style of SKILL.md.
- Every CLI claim MUST be verified against the live binary on this machine
  (`codex exec --help`, `codex exec resume --help`, and your queue tool's
  `--help`) — do not write flags from memory. If a flag can't be verified,
  don't document it.
- Check whether `codex exec` has a sandbox/approval flag and document the
  SAFE default invocation for read-only review vs write-capable execution.
- Do NOT modify any other file. Do NOT restructure SKILL.md.
- Channel C section: ≤15 lines, pointer-style (the real manual is
  the queue tool's own doc).

## Acceptance Criteria

- [ ] `references/routing.md` exists, ≤ ~200 lines, four channels A–D each
      with When / Invoke / Steer / Cost & limits + evidence-return note
- [ ] All codex flags/subcommands in the doc appear verbatim in `--help`
      output captured during this task (paste the decisive help lines as
      evidence)
- [ ] Channel C references the queue tool's own manual instead of duplicating it
- [ ] Channel D carries an explicit "unverified" warning
- [ ] No other file modified (`git status` not applicable — verify by listing
      only the one new file under references/)

## Verify (run these; paste real output)

```bash
ls -la ~/.claude/skills/handoff/references/
wc -l ~/.claude/skills/handoff/references/routing.md
grep -c "^## " ~/.claude/skills/handoff/references/routing.md
codex exec --help | grep -iE "sandbox|approval|full-auto" | head -10
```

## Evidence to Return

Your final message MUST contain exactly, in order:

1. Acceptance checklist with ✅/❌ per item (❌ requires one line why)
2. Verify command output — the decisive lines, verbatim
3. File created (path + line count) — no diff needed (new file)
4. Deviations & discoveries ("none" if empty)
5. Blockers ("none" if empty)

Do NOT return the full routing.md content — the brain adjudicates on evidence.

---

## Returned Evidence 1 (brain-recorded, 2026-07-09)

- Acceptance: 5/5 ✅ (152 lines; 5 `##` sections; codex flags verbatim-matched
  to live --help; Channel C pointer-style; Channel D UNVERIFIED-flagged; only
  references/routing.md written)
- Verify: `wc -l` → 152; `grep -c "^## "` → 5; codex --help decisive lines
  matched (-s/--sandbox, --dangerously-bypass-approvals-and-sandbox)
- Discoveries: (1) `codex exec --write` is NOT a literal flag → real form
  `-s workspace-write` (SKILL.md corrected by brain); (2) no --approval /
  --full-auto — sandbox mode is the sole safety control; (3) `resume` does not
  accept -s, inherits original session policy; (4) `review` has
  --uncommitted/--base/--commit as a no-dispatch diff-review path;
  (5) correctly attributed CLAUDE.md concurrent edit to brain, not itself
- Blockers: none

## Adjudication

- 2026-07-09 — verdict: ACCEPTED — brain independently re-ran structure grep +
  line count + codex flag cross-check against its own --help capture; all match.
  Discovery (1) applied to SKILL.md routing tree.
