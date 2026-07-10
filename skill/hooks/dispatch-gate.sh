#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# dispatch-gate.sh — PreToolUse:Agent hook (conductor v2 prototype)
#
# Purpose: nudge (default) or block (strict) `Agent` tool dispatches
# that mutate state without referencing a DISPATCH spec file. The
# conductor protocol (see ../SKILL.md) requires every state-mutating
# dispatch to be a file on disk; read-only consultations are exempt.
# v1 enforces this by skill flow only — this hook is the v2 automated
# enforcement layer.
#
# Registration snippet (add to ~/.claude/settings.json to enable):
#   {
#     "hooks": {
#       "PreToolUse": [
#         { "matcher": "Agent",
#           "hooks": [ { "type": "command",
#             "command": "$HOME/.claude/skills/conductor/hooks/dispatch-gate.sh" } ] }
#       ]
#     }
#   }
# (Hook command paths must be absolute or $HOME-based — see
#  ~/.claude/rules/ecc-common/hooks.md.)
#
# PROTOTYPE — not registered; enable deliberately after friction review (v2).
#
# Modes:
#   default            → non-matching dispatch prints ONE stderr nudge, exit 0
#   CONDUCTOR_STRICT=1 → non-matching dispatch exit 2 (Claude Code blocks call)
#
# Input: JSON on stdin from Claude Code PreToolUse hook, e.g.
#   {"tool_name":"Agent","tool_input":{"prompt":"...","subagent_type":"..."}}
# Exit: 0 = allow (stderr shown as info), 2 = block (per hook protocol).
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

input="$(cat)"

# ── Stdin parse (jq only; copy an existing PreToolUse hook's idiom: allow on
#    empty / parse failure — never break the tool chain on a parser error).
tool_name="$(jq -r '.tool_name // ""' 2>/dev/null <<<"$input")"

# Non-"Agent" or unparseable/malformed/empty JSON → allow silently.
[[ "$tool_name" != "Agent" ]] && exit 0

prompt="$(jq -r '.tool_input.prompt // ""' 2>/dev/null <<<"$input")"
subagent="$(jq -r '.tool_input.subagent_type // ""' 2>/dev/null <<<"$input")"

# ── PASS conditions — any one → silent allow (exit 0, no stderr) ─────

# 1. Prompt references a dispatch file, or contains the DISPATCH keyword
#    (both case-sensitive: DISPATCH is an uppercase marker, paths lowercase).
dispatch_re='dispatch/[A-Za-z0-9._-]+\.md'
if [[ "$prompt" =~ $dispatch_re ]] || [[ "$prompt" == *DISPATCH* ]]; then
    exit 0
fi

# 2/3. Read-only markers — case-insensitive from here on.
shopt -s nocasematch

# 2. Prompt declares a read-only consultation:
#    contains "read-only" (covers "read-only consult"), OR starts with
#    review semantics ("Review " / "Adversarially verify").
review_re='^[[:space:]]*(review |adversarially verify)'
if [[ "$prompt" == *read-only* ]] || [[ "$prompt" =~ $review_re ]]; then
    shopt -u nocasematch
    exit 0
fi

# 3. subagent_type is a read-only agent type: Explore, Plan, or any name
#    containing "reviewer" / "explorer" (e.g. code-reviewer, code-explorer).
if [[ "$subagent" == "Explore" || "$subagent" == "Plan" \
      || "$subagent" == *reviewer* || "$subagent" == *explorer* ]]; then
    shopt -u nocasematch
    exit 0
fi

shopt -u nocasematch

# ── No PASS matched → nudge (default) or block (strict) ──────────────
if [[ "${CONDUCTOR_STRICT:-0}" == "1" ]]; then
    echo "[dispatch-gate] BLOCKED (CONDUCTOR_STRICT=1): Agent dispatch has no dispatch/NN-name.md reference and no read-only marker — reference a DISPATCH file, add a READ-ONLY marker for consultations, or unset CONDUCTOR_STRICT (conductor SKILL.md)." >&2
    exit 2
fi

echo "[dispatch-gate] reminder: state-mutating Agent dispatches should reference a dispatch/NN-name.md spec file (conductor protocol); mark read-only consults READ-ONLY. Nudge only — set CONDUCTOR_STRICT=1 to enforce." >&2
exit 0
