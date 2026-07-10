# DISPATCH: 02-dispatch-gate-hook

> Status: accepted
> Channel: agent-opus
> Dispatched: 2026-07-09 08:54 UTC | Spec: ~/.claude/skills/conductor/SKILL.md (v2 backlog item)
> Workspace: ~/.claude/skills/conductor/

## Context

The `conductor` skill (read ~/.claude/skills/conductor/SKILL.md
first) mandates: state-mutating dispatches require a DISPATCH file; read-only
consultations are exempt. v1 enforces this by skill flow only. This task
builds the v2 enforcement PROTOTYPE: a Claude Code PreToolUse hook that
nudges (default) or blocks (strict mode) `Agent` tool calls that don't
reference a dispatch file.

Verified facts:
- Claude Code PreToolUse hooks receive JSON on stdin: fields include
  `session_id`, `transcript_path`, `tool_name`, `tool_input` (the tool's
  parameters object). For the `Agent` tool, `tool_input.prompt` is the
  dispatched prompt text and `tool_input.subagent_type` names the agent type.
  CONFIRM this shape by reading an existing working hook on this machine,
  e.g. ~/.claude/hooks/pre-contribute-gate.sh (registered under
  PreToolUse matcher=Bash in ~/.claude/settings.json) — copy its stdin-parsing
  idiom rather than inventing one.
- Hook exit codes: 0 = allow (stderr shown as info), 2 = block the tool call.
- Hook path rules: registered commands must use absolute or $HOME paths
  (see ~/.claude/rules/ecc-common/hooks.md) — but THIS TASK DOES NOT REGISTER
  the hook. Prototype only.
- This machine has jq available.

## Task

Create `~/.claude/skills/conductor/hooks/dispatch-gate.sh` (the
skill directory keeps conductor assets self-contained for future packaging)
plus a pure-bash test script
`~/.claude/skills/conductor/tests/dispatch-gate.test.sh`.

Hook behavior (PreToolUse, intended matcher: Agent):
1. Parse stdin JSON. If `tool_name` != "Agent" → exit 0 silently (defensive;
   matcher should already scope it).
2. PASS silently when ANY of:
   - `tool_input.prompt` references a dispatch file: matches regex
     `dispatch/[A-Za-z0-9._-]+\.md` or contains `DISPATCH`
   - `tool_input.prompt` declares read-only consultation: contains
     `READ-ONLY` / `read-only consult` / starts with review semantics
     (`Review `, `Adversarially verify`) — case-insensitive matching
   - `tool_input.subagent_type` is a read-only agent type: `Explore`, `Plan`,
     or any name containing `reviewer` / `explorer`
3. Otherwise:
   - default: warn — print ONE concise stderr line reminding about the
     conductor dispatch protocol, exit 0 (never blocks by default)
   - `CONDUCTOR_STRICT=1` in env: exit 2 (block) with a one-line stderr
     explaining why + how to comply (reference a dispatch file, or set the
     read-only marker, or unset CONDUCTOR_STRICT)
4. Malformed/empty stdin JSON → exit 0 silently (never break the tool chain
   on parser failure).

Header comment in the hook must include: purpose, registration snippet
(settings.json PreToolUse matcher "Agent", $HOME-based command path), and
"PROTOTYPE — not registered; enable deliberately after friction review (v2)".

## Constraints

- Bash + jq only; no new dependencies. Follow the stdin-parsing idiom of the
  existing hook you inspected.
- Do NOT modify ~/.claude/settings.json or any settings file. Do NOT register
  the hook anywhere.
- Do NOT modify SKILL.md, templates, references, or any other existing file.
- Test script: pure bash assertions (no bats), feeding crafted JSON via
  stdin to the hook, asserting exit codes and stderr presence/absence.
- Keep the hook ≤120 lines, test ≤120 lines.

## Acceptance Criteria

- [ ] Both files exist and are executable (`chmod +x`)
- [ ] `bash -n` passes on both; if shellcheck is installed, no errors
      (warnings acceptable, note them)
- [ ] Test script covers ≥7 cases and ALL pass on real execution:
      (1) prompt with dispatch/NN-x.md path → exit 0, no stderr
      (2) prompt with DISPATCH keyword → exit 0, no stderr
      (3) bare prompt, default mode → exit 0, WITH stderr warn line
      (4) bare prompt, CONDUCTOR_STRICT=1 → exit 2, WITH stderr
      (5) read-only marker prompt → exit 0, no stderr
      (6) subagent_type=Explore bare prompt → exit 0, no stderr
      (7) malformed JSON stdin → exit 0, no crash
- [ ] tool_name != "Agent" input → exit 0 silently (covered in tests or
      demonstrated)
- [ ] settings.json untouched (verify: grep -c dispatch-gate
      ~/.claude/settings.json returns 0)

## Verify (run these; paste real output)

```bash
ls -la ~/.claude/skills/conductor/hooks/ ~/.claude/skills/conductor/tests/
bash -n ~/.claude/skills/conductor/hooks/dispatch-gate.sh && echo SYNTAX-OK
bash ~/.claude/skills/conductor/tests/dispatch-gate.test.sh
grep -c dispatch-gate ~/.claude/settings.json || echo "0 (not registered — correct)"
```

## Evidence to Return

Your final message MUST contain exactly, in order:
1. Acceptance checklist with ✅/❌ per item (❌ needs one line why)
2. Verify output decisive lines verbatim (esp. full test run tally)
3. Files created (paths + line counts)
4. Deviations & discoveries — esp. the ACTUAL stdin JSON shape you confirmed
   from the existing hook ("none" if empty)
5. Blockers ("none" if empty)

Also: append your evidence to THIS file under `## Returned Evidence 1` before
returning (you have write access to it).

---

## Returned Evidence 1

Returned: 2026-07-09 by Agent(opus) hand.

### 1. Acceptance checklist

- ✅ Both files exist and are executable (`chmod +x`) — `hooks/dispatch-gate.sh`
  and `tests/dispatch-gate.test.sh` both `-rwxr-xr-x`.
- ✅ `bash -n` passes on both (HOOK-SYNTAX-OK / TEST-SYNTAX-OK). shellcheck
  NOT installed on this machine (`which shellcheck` → not found), so the
  "if installed" clause is vacuous; no errors to report.
- ✅ Test script covers 11 cases (≥7 required), ALL pass on real execution.
  The 7 mandated cases map to: (1) dispatch-file-path, (2) DISPATCH-keyword,
  (3) bare-default-nudge, (4) bare-strict-block, (5) read-only-marker,
  (6) subagent-Explore, (7) malformed-json. Plus 4 extra: non-Agent-tool,
  subagent-code-reviewer, review-starts-with, read-only-under-strict.
- ✅ tool_name != "Agent" → exit 0 silently — covered by case (8) non-Agent-tool.
- ✅ settings.json untouched — `grep -c dispatch-gate ~/.claude/settings.json` → 0.

### 2. Verify output (decisive lines, verbatim)

```
HOOK-SYNTAX-OK
TEST-SYNTAX-OK
PASS  dispatch-file-path                       exit=0 stderr=no
PASS  DISPATCH-keyword                         exit=0 stderr=no
PASS  bare-default-nudge                       exit=0 stderr=yes
PASS  bare-strict-block                        exit=2 stderr=yes
PASS  read-only-marker                         exit=0 stderr=no
PASS  subagent-Explore                         exit=0 stderr=no
PASS  malformed-json                           exit=0 stderr=no
PASS  non-Agent-tool                           exit=0 stderr=no
PASS  subagent-code-reviewer                   exit=0 stderr=no
PASS  review-starts-with                       exit=0 stderr=no
PASS  read-only-under-strict                   exit=0 stderr=no
TOTAL: 11  PASS: 11  FAIL: 0
grep -c dispatch-gate ~/.claude/settings.json → 0
```

### 3. Files created

- `~/.claude/skills/conductor/hooks/dispatch-gate.sh` — 88 lines
- `~/.claude/skills/conductor/tests/dispatch-gate.test.sh` — 87 lines

### 4. Deviations & discoveries

- **Confirmed stdin JSON shape**: `pre-contribute-gate.sh` (header lines 31-33
  + extraction line 53) confirms `tool_input` is the tool's params object,
  read via `input="$(cat)"` then `jq -r '.tool_input.<field> // "" ' 2>/dev/null`,
  allowing on empty/parse failure. Top-level `tool_name` distinguishes tools.
  For `Agent`, the params `prompt` and `subagent_type` are the Agent tool's own
  schema parameter names — so `tool_input.prompt` / `tool_input.subagent_type`.
  No live Agent-tool hook payload existed on this machine to capture directly;
  shape is confirmed structurally from the working Bash hook + Agent tool schema.
- **jq-only, not python3-first**: the inspected hook tries python3 first then
  jq. Dispatch mandated "Bash + jq only", so I used the jq branch idiom only
  (jq present at /usr/bin/jq). Used `jq <<<"$input"` (herestring) instead of
  `echo "$input" | jq` — same idiom, avoids `echo` backslash/`-e` mangling of
  multi-line prompt JSON. Allow-on-parse-failure behavior preserved.
- **Matching uses bash `[[ =~ ]]` / `==` with `shopt -s nocasematch`** (no extra
  deps) rather than piping to grep: dispatch-file regex + `DISPATCH` keyword are
  case-sensitive (checked before nocasematch); read-only + subagent checks are
  case-insensitive. "Starts with review semantics" uses `^`-anchored bash regex
  (`review_re='^[[:space:]]*(review |adversarially verify)'`), which in bash
  anchors to the whole-string start (not per-line), matching the "starts with"
  intent precisely.
- **Strict never overrides a PASS**: added case (11) proving CONDUCTOR_STRICT=1
  still exits 0 when a read-only marker is present — block only fires when NO
  pass condition matched.

### 5. Blockers

none

---

## Adjudication

- 2026-07-09 09:05 UTC — verdict: ACCEPTED — brain independently re-ran the
  full test suite (11/11 PASS) and the settings.json check (0 hits). Evidence
  self-persisted by hand per protocol. Note for v2 activation: stdin shape was
  structurally confirmed, not live-captured — capture one real Agent-tool hook
  payload before registering the hook.
