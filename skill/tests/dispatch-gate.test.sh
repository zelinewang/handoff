#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# dispatch-gate.test.sh — pure-bash assertions for dispatch-gate.sh
# No bats. Feeds crafted JSON on stdin, asserts exit code + whether
# any stderr was emitted. Exits non-zero if any case fails.
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/../hooks" && pwd)/dispatch-gate.sh"
pass=0; fail=0

# run_case NAME EXPECTED_EXIT EXPECT_STDERR(yes|no) ENV_KV JSON
# ENV_KV: "" for a clean env (CONDUCTOR_STRICT unset), or "CONDUCTOR_STRICT=1".
run_case() {
    local name="$1" exp_exit="$2" exp_err="$3" env_kv="$4" json="$5"
    local err_file rc has_err ok
    err_file="$(mktemp)"
    if [[ -n "$env_kv" ]]; then
        printf '%s' "$json" | env "$env_kv" bash "$HOOK" >/dev/null 2>"$err_file"
    else
        printf '%s' "$json" | env -u CONDUCTOR_STRICT bash "$HOOK" >/dev/null 2>"$err_file"
    fi
    rc=$?
    has_err="no"; [[ -s "$err_file" ]] && has_err="yes"
    ok=1
    [[ "$rc" == "$exp_exit" ]] || ok=0
    [[ "$has_err" == "$exp_err" ]] || ok=0
    if [[ $ok -eq 1 ]]; then
        printf 'PASS  %-40s exit=%s stderr=%s\n' "$name" "$rc" "$has_err"
        pass=$((pass+1))
    else
        printf 'FAIL  %-40s exit=%s(exp %s) stderr=%s(exp %s)\n' \
            "$name" "$rc" "$exp_exit" "$has_err" "$exp_err"
        [[ -s "$err_file" ]] && sed 's/^/      stderr> /' "$err_file"
        fail=$((fail+1))
    fi
    rm -f "$err_file"
}

# (1) prompt referencing a dispatch/NN-x.md path → allow, silent
run_case "dispatch-file-path" 0 no "" \
    '{"tool_name":"Agent","tool_input":{"prompt":"Execute dispatch/02-dispatch-gate-hook.md exactly.","subagent_type":"claude"}}'

# (2) prompt containing the DISPATCH keyword → allow, silent
run_case "DISPATCH-keyword" 0 no "" \
    '{"tool_name":"Agent","tool_input":{"prompt":"Follow the DISPATCH order attached.","subagent_type":"claude"}}'

# (3) bare state-mutating prompt, default mode → allow WITH nudge
run_case "bare-default-nudge" 0 yes "" \
    '{"tool_name":"Agent","tool_input":{"prompt":"Refactor the auth module and add tests.","subagent_type":"claude"}}'

# (4) bare prompt, CONDUCTOR_STRICT=1 → block WITH stderr
run_case "bare-strict-block" 2 yes "CONDUCTOR_STRICT=1" \
    '{"tool_name":"Agent","tool_input":{"prompt":"Refactor the auth module and add tests.","subagent_type":"claude"}}'

# (5) explicit READ-ONLY marker → allow, silent
run_case "read-only-marker" 0 no "" \
    '{"tool_name":"Agent","tool_input":{"prompt":"READ-ONLY: give a second opinion on the design.","subagent_type":"claude"}}'

# (6) subagent_type=Explore, bare prompt → allow, silent
run_case "subagent-Explore" 0 no "" \
    '{"tool_name":"Agent","tool_input":{"prompt":"Find where retries are configured.","subagent_type":"Explore"}}'

# (7) malformed JSON stdin → allow, no crash, silent
run_case "malformed-json" 0 no "" \
    'this is not json {{{'

# (8) tool_name != Agent → allow silently (defensive)
run_case "non-Agent-tool" 0 no "" \
    '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}'

# (9) reviewer subagent → allow, silent (read-only agent by name)
run_case "subagent-code-reviewer" 0 no "" \
    '{"tool_name":"Agent","tool_input":{"prompt":"Look over the changes.","subagent_type":"code-reviewer"}}'

# (10) "Review " starts-with semantics → allow, silent
run_case "review-starts-with" 0 no "" \
    '{"tool_name":"Agent","tool_input":{"prompt":"Review the diff for correctness bugs.","subagent_type":"claude"}}'

# (11) read-only PASS still wins under STRICT (strict never overrides a PASS)
run_case "read-only-under-strict" 0 no "CONDUCTOR_STRICT=1" \
    '{"tool_name":"Agent","tool_input":{"prompt":"READ-ONLY consult: assess the approach.","subagent_type":"claude"}}'

echo "─────────────────────────────────────────────"
echo "TOTAL: $((pass+fail))  PASS: $pass  FAIL: $fail"
[[ $fail -eq 0 ]]
