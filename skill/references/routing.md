# Handoff Channel Operations

Channel mechanics for the Routing Tree in `SKILL.md`. Each channel documents
**When / Invoke / Steer / Cost & limits / Evidence return**. The CLI flags below
were verified against the live binaries the reference implementation used,
2026-07-09 (`codex` CLI 0.139.0) — flags not present in `--help` are not
documented. Channel C (async agent queue) is written generically because the
reference implementation used an internal tool; substitute your own. Channel D
(Kimi K3) was live-verified 2026-07-19/20, including a head-to-head contest win
on a real backend fix (see §MoA-leader mode).

## Channels at a glance

| Ch | Executor | Model | Best for | Steer via |
|----|----------|-------|----------|-----------|
| A | `Agent` subagent | Opus 4.8 | default implementation w/ a clear spec | `SendMessage` |
| B | `codex exec` | GPT-5.5 | independent review; 3×-stuck reframe; large build-out | `codex exec resume` |
| C | async agent queue | your workers | >30 min / cross-repo / user away / cron | comment on the work item |
| D | `claude -p` + env override | Kimi K3 (other Anthropic-compatible models slot in the same way) | frontend/vision/web-agentic PRIMARY; backend contest-capable | n/a (stateless; re-dispatch fresh) |

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

## Channel D — Kimi K3 via claude -p env override  (VERIFIED 2026-07-19/20)

> Any Anthropic-compatible third-party model slots in through the same env
> override; this section documents Kimi K3 concretely because it is the one the
> reference implementation verified end-to-end (vision, tool-use, long detached
> runs, and a contest win on a real backend fix — see §MoA-leader mode).

**When** — K3 is the PRIMARY hand for frontend implementation, vision/UI review,
and web-agentic work (it ranks #1 on WebDev Arena for frontend, above the
frontier leads). Backend is NOT off-limits: under a hard-boundary spec, K3 beat
an Opus 4.8 hand 99-96 in the first head-to-head contest (a Go parser
round-trip fix, both submissions gate-clean — the margin was mechanism depth,
test coverage, and TDD craft; the winning PR is public:
https://github.com/zelinewang/claudemem/pull/10).

**Invoke** (shell, env override — endpoint per Moonshot's official
Claude Code guide; key via env var only, never inline):
```bash
ANTHROPIC_BASE_URL="https://api.moonshot.ai/anthropic" \
ANTHROPIC_AUTH_TOKEN="$KIMI_API_KEY" \
ANTHROPIC_DEFAULT_OPUS_MODEL="kimi-k3[1m]" \
  claude -p --model "kimi-k3[1m]" "$(cat dispatch/NN-task.md)"
```
For anything longer than a few minutes, wrap the launch in a **detached runner**
(nohup + disown into a state dir holding `prompt.txt` / `log` / `pid` / `exit`)
so the run survives parent-process cleanup, and watch it with a monitor that
checks BOTH the exit file AND pid liveness — silence must be distinguishable
from a crash. Field observation (×2, 2026-07-20): plain background-shell
watchdogs get reaped on long waits; a supervisor with its own process survives.
Slim the subprocess for `-p` runs (`--strict-mcp-config`) — a dispatch dragging
a dozen MCP servers is the thing that gets batch-killed.

**Steer** — n/a between runs: K3 is *preserved-thinking sensitive* — one LONG
continuous run beats many short relays (thinking history dies across cold
starts), and it must never resume another model's partial work. Rework = a
fresh self-contained dispatch that cites the prior returned evidence.

**Rules of engagement (K3-specific, from its official limitations)**:
- Every dispatch carries HARD boundaries — scope fence, forbidden paths,
  conservative-option rule for ambiguity. K3 over-improvises without them;
  under them the observed behavior is excellent (honest no-ops, evidence-backed
  pushback, declared skips) across all verified orders.
- Vision: have K3 self-review its own screenshots in-loop; cross-validate
  visual verdicts with a second model (e.g. a Gemini image check) before
  accepting them.
- Video: the K3 API path is frames-only, NO audio — keep a full-modal model in
  the loop for anything where audio matters.

**Cost & limits** — billed by Moonshot, fully off the Anthropic quota (genuine
capacity relief + real model diversity). Stateless per invocation. Failure
mode: API 429 "engine overloaded" can kill a long run with zero output — back
off ~30 min and re-dispatch the SAME spec (observed: the retry delivered the
full task); after repeated 429s, downgrade to Channel A and record the switch.

**Evidence return** — final message to stdout (or the detached runner's `log`);
evidence file discipline per the DISPATCH template applies unchanged. A
K3-tailored template ships in `templates/DISPATCH-K3.md`.

## MoA-leader mode  (heterogeneous contest; v0.1, hardened 2026-07-20)

One brief → 2-3 heterogeneous hands implement independently → the brain judges
and ships the winner. Unifies supervisor-worker, cross-model review, and
leader-workers in one cycle — pure orchestration over channels A/B/D, no new
infra.

**When to fire** (a notch in the routing tree, NOT the default): wide design
space (architecture options, API shape, UX direction); high-stakes or
hard-to-reverse decisions needing independent derivations; capability
calibration (every contest doubles as a routing eval). NOT for deterministic
execution — single hand + review is cheaper and equal there.

**Protocol**:
0. BEFORE fan-out the judge builds an INDEPENDENT black-box oracle (isolated
   env, golden fixture, mechanical PASS/FAIL) and records the baseline failure
   signature. This is what makes every hand's self-report verifiable. Also:
   pre-register the scoring rubric in the brief, and scope every MUST gate
   explicitly (files/package/tree — an ambiguous tree-wide gate over a repo
   with pre-existing debt forks into letter-vs-spirit readings).
1. ONE brief, identical for all hands (verify byte symmetry modulo
   paths/branches with `diff`); each hand gets its own worktree.
2. Fan out in parallel (channel A + channel D is the proven pair). More voices
   than the brain can adjudicate = verification theater.
3. Adversarially re-verify every claim: judge-rerun the oracle on each hand's
   build; verify test-first by cherry-picking each hand's new test files alone
   onto the clean base (they must fail there); re-run gates capturing true
   exit codes; arbitrate inter-hand factual disagreements with the judge's own
   probes.
4. Score per the pre-registered rubric; winner ships through the normal PR
   flow; graft any superior isolated ideas from the runner-up with
   attribution; log the datapoint (scores + decisive axes) to the contest
   ledger. Routing weights move on TREND, never on n=1.

**Contest #1** (2026-07-20, the run that hardened v0 → v0.1): K3 99 vs
Opus 4.8 96 on a Go CLI parser round-trip defect — both hands gate-clean and
oracle-perfect; the decisive axes were mechanism depth, ∖n-preserving
round-trip semantics, end-to-end + backward-compat test coverage, visible
RED→fix commit history, and forensic accuracy (its corpus counts reproduced
exactly by the judge's independent probes). Winning PR (public):
https://github.com/zelinewang/claudemem/pull/10

---

Safety invariant (all channels): the brain adjudicates on returned **evidence**,
never by re-reading the hand's work. Use read-only scope (`-s read-only`, review
agents) for anything that only needs a verdict; grant write scope only for
build-outs.
