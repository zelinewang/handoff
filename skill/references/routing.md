# Handoff Channel Operations

Channel mechanics for the Routing Tree in `SKILL.md`. Each channel documents
**When / Invoke / Steer / Cost & limits / Evidence return**. The CLI flags below
were verified against the live binaries the reference implementation used,
2026-07-09 (`codex` CLI 0.139.0) — flags not present in `--help` are not
documented. Channel C (async agent queue) is written generically because the
reference implementation used an internal tool; substitute your own.

## Channels at a glance

| Ch | Executor | Model | Best for | Steer via |
|----|----------|-------|----------|-----------|
| A | `Agent` subagent | Opus 4.8 | default implementation w/ a clear spec | `SendMessage` |
| B | `codex exec` | GPT-5.5 | independent review; 3×-stuck reframe; large build-out | `codex exec resume` |
| C | async agent queue | your workers | >30 min / cross-repo / user away / cron | comment on the work item |
| D | `claude -p` + env | third-party (GLM…) | optional heterogeneous overflow | n/a (stateless) |

## Channel A — Agent(opus) subagent  ← DEFAULT

**When** — implementation with a clear spec (the default hand). N independent
specs → N `Agent(opus)` calls in ONE message (parallel). Parallel file mutation →
add `isolation:"worktree"`. A domain-matched ECC reviewer exists → set
`subagent_type` to it (e.g. `everything-claude-code:python-reviewer`).

**Invoke** (tool call, not shell):
```
Agent(
  subagent_type: "general-purpose",  # or an ECC reviewer for domain-matched review
  model: "opus",                      # REQUIRED — omit and it inherits Fable (zero saving)
  name: "hand-03",                    # makes it addressable for SendMessage steering
  description: "execute dispatch 03",
  prompt: "Read and execute /abs/.../dispatch/03-*.md exactly. Return evidence per its format.",
  isolation: "worktree"               # only when writing files in parallel with other hands
)
```
Fire N in a single message for parallelism. `prompt` = the DISPATCH file (a path
for file-access hands, or inline content).

**Steer** — continue the SAME agent (context intact) via `SendMessage` with
`to:` its name/ID and the rework note. Must spawn with `name:` or it can't be
addressed. A new `Agent(...)` call instead starts a cold hand (except a fork,
which also re-inherits Fable — never use fork to save cost).

**Cost & limits** — Opus 4.8 tokens (below the Fable brain); ~0 s startup;
shared filesystem. Non-fork `model:"opus"` is the ONLY way to downshift. The hand
starts COLD (no conversation history) → the DISPATCH must be self-contained.
Failure mode: returns prose instead of evidence → enforce the Evidence-to-Return block.
Economics (eval-calibrated 2026-07-09, n=2 pairs): dispatch fixed cost ≈5-8k
brain output tokens (spec + adjudication + ledger); it amortizes at roughly
≥200-line artifacts / ≥500-line reads (pair-2: −68.6% brain output; pair-1 at
≤175L: +4.4% vs solo). Below that scale solo is cheaper — dispatch anyway only
when the brain must stay free for parallel work.

**Evidence return** — the agent's final message is delivered to the brain as the
tool result. No file plumbing needed.

## Channel B — codex exec (GPT-5.5)

**When** — independent second opinion / review (read-only); the brain's own
approach failed 3× / stuck (heterogeneous reframe — a different model family is
real diversity); large self-contained build-out (write-capable, full hand-off via
DISPATCH). SKILL.md's shorthand `codex exec --write` is not a literal flag → it
means `-s workspace-write` (see below).

**Invoke** (shell). Prompt via arg or stdin (`-`); stdin is cleaner for a whole
DISPATCH:
```bash
# read-only review — the safe default; the model cannot write
codex exec -s read-only - < dispatch/NN-task.md

# diff-scoped review (built-in subcommand) — no dispatch file needed
codex exec review --uncommitted            # staged + unstaged + untracked
codex exec review --base origin/dev         # vs a base branch
codex exec review --commit <SHA>            # one commit's changes

# write-capable build-out — writes confined to the working dir
codex exec -s workspace-write -C /abs/repo - < dispatch/NN-task.md

# capture the final message to a file for the ledger
codex exec -s read-only -o /tmp/NN.out - < dispatch/NN-task.md
```
Sandbox modes (verified): `read-only | workspace-write | danger-full-access`.
`codex exec` has NO `--approval`/`--full-auto` flag — the sandbox mode IS the
safety control, so pass it explicitly rather than trust an unstated default.
**Never** use `--dangerously-bypass-approvals-and-sandbox` (skips sandboxing
entirely). Outside a git repo, add `--skip-git-repo-check`; `--add-dir <DIR>`
grants extra writable dirs.

**Steer** — resume the prior session with a correction:
```bash
codex exec resume --last "Rework 1: <what to change>"
codex exec resume <SESSION_ID> - < dispatch/NN-rework.md   # explicit session/thread
```
`resume` does not re-take `-s` (not in its `--help`) — it continues the original
session's policy.

**Cost & limits** — GPT-5.5 tokens, independent of the Anthropic quota (genuine
overflow relief + model diversity). Fresh process per top-level `exec` (no shared
memory with the brain; a session is only reachable again via `resume`). `-C/--cd`
sets the root. Failure mode: too-narrow sandbox silently blocks writes → use
`workspace-write` for build-outs, `read-only` for reviews. Failure mode: codex
always drains non-TTY stdin BEFORE running an arg prompt — backgrounded
`codex exec "<prompt>"` with an open stdin pipe hangs forever at "Reading
additional input from stdin..." → append `</dev/null` whenever the prompt is
an arg and stdin isn't the dispatch (observed 2026-07-09: 14-min zero-CPU hang).

**Evidence return** — codex prints the evidence to **stdout**; capture with
`-o <FILE>` or `--json` (JSONL events) and adjudicate on that. Warning: raw
stdout ECHOES tool outputs (full file reads) — polling it mid-run feeds the
brain everything the hand read, defeating both token tiering and any
blind/sealed-material isolation. Read only the `-o` final message.

## Channel C — async agent queue  (generic example, not a manual)

> The reference implementation used an internal async-dispatch tool. The
> mechanics below are written generically so any equivalent queue — a job/issue
> system that assigns work to persistent background agents on separate
> infrastructure — can slot in. Substitute your own tool's commands.

**When** — >30 min, cross-repo, user leaving, or recurring/cron work: anything
that should outlive this session and run off your interactive machine.

**Invoke / Steer / Evidence** — the generic recipe: create a work item (issue /
job) whose description IS the DISPATCH file → assign it to a persistent agent →
steer by commenting on the item → read the agent's task output (machine-readable
if the tool offers it) for evidence.

**Cost & limits** — whatever model/quota your queue's workers run on; persistent
and typically multi-machine (that is the reason to reach for it). Gaps are
tool-specific: before handing off a real DISPATCH, verify your queue's
MCP/tool availability and its repo-checkout/isolation model, and fall back to a
plain `git clone` if a managed checkout is unavailable.

## Channel D — third-party via claude -p  (OPTIONAL · UNVERIFIED)

> **UNVERIFIED on this machine — smoke-test before first real use.** No
> third-party endpoint/token is configured here; treat every claim below as
> unconfirmed until a live `claude -p` round-trip succeeds.

**When** — optional overflow to an Anthropic-compatible third-party model (e.g.
GLM) when channels A/B/C are saturated. Never the default.

**Invoke** (shell, env override):
```bash
# smoke-test FIRST:
#   ANTHROPIC_BASE_URL=… ANTHROPIC_AUTH_TOKEN=… claude -p "reply OK"
ANTHROPIC_BASE_URL="https://<provider>/anthropic" \
ANTHROPIC_AUTH_TOKEN="<token>" \
  claude -p "$(cat dispatch/NN-task.md)"
```

**Steer** — n/a. `claude -p` is stateless per invocation; for rework re-dispatch a
fresh prompt, or fall back to Channel A/B (which have real multi-turn steering).

**Cost & limits** — billed by the third-party provider, off the Anthropic quota.
Compatibility, tool support, and sandbox behavior are provider-dependent and
unproven here — verify tool-use and file-write behavior in the smoke test before
trusting it with a real DISPATCH.

**Evidence return** — `claude -p` prints the final message to stdout; capture and
adjudicate as with Channel B.

---

Safety invariant (all channels): the brain adjudicates on returned **evidence**,
never by re-reading the hand's work. Use read-only scope (`-s read-only`, review
agents) for anything that only needs a verdict; grant write scope only for
build-outs.
