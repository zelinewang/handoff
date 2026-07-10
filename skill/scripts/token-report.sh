#!/usr/bin/env bash
# token-report.sh — per-model token usage report for a Claude Code session.
# Part of the conductor skill: quantifies the brain-vs-hands token split that
# the delegation protocol exists to create.
#
# Usage:
#   token-report.sh <session-id | /path/to/transcript.jsonl> [--since ISO] [--until ISO]
#
# Output: one table per transcript (main session + each subagent), rows per
# model: msgs / input / cache_read / cache_write / output.
#
# Notes:
#   - Timestamps in transcripts are ISO-8601 UTC; same-format strings compare
#     lexically, so --since/--until filtering needs no date parsing. Use it to
#     slice eval arms (e.g. --since T0 --until T1).
#   - External CLIs (codex exec) do NOT appear in transcripts — codex prints
#     its own "tokens used" line on stdout; add it manually to comparisons.
#   - DEDUP (bugfix 2026-07-09): one API turn = one JSONL row PER CONTENT
#     BLOCK. Main-session rows repeat the turn's final usage verbatim;
#     SUBAGENT rows carry PROGRESSIVE usage snapshots (output grows per
#     block, last row = turn total). Summing raw rows inflates main totals
#     3-5x; first-row dedup would undercount subagents ~500x. Correct for
#     both: aggregate per .message.id taking the MAX of each usage field
#     (max == value for identical copies, == final for progressive).
#     msgs column = real turns.

set -euo pipefail

usage() { sed -n '2,16p' "$0"; exit 1; }

[ $# -ge 1 ] || usage
target="$1"; shift
since=""; until_ts=""
while [ $# -gt 0 ]; do
  case "$1" in
    --since) since="${2:?--since needs a value}"; shift 2 ;;
    --until) until_ts="${2:?--until needs a value}"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; usage ;;
  esac
done

# Resolve session id → transcript path (search all project dirs)
if [ -f "$target" ]; then
  transcript="$target"
else
  transcript="$(find "$HOME/.claude/projects" -maxdepth 2 -name "${target}.jsonl" -print -quit 2>/dev/null || true)"
  [ -n "$transcript" ] && [ -f "$transcript" ] || { echo "transcript not found for: $target" >&2; exit 2; }
fi

session_dir="${transcript%.jsonl}"

report_one() {
  local file="$1" label="$2"
  jq -r --arg since "$since" --arg until "$until_ts" '
    select(.type=="assistant" and .message.usage != null)
    | select($since == "" or .timestamp >= $since)
    | select($until == "" or .timestamp <= $until)
    | [ (.message.id // .timestamp),
        .message.model,
        .message.usage.input_tokens // 0,
        .message.usage.cache_read_input_tokens // 0,
        .message.usage.cache_creation_input_tokens // 0,
        .message.usage.output_tokens // 0 ]
    | @tsv' "$file" 2>/dev/null \
  | awk -F'\t' -v label="$label" '
      {
        id=$1; model_of[id]=$2
        if ($3+0 > inp_of[id]+0) inp_of[id]=$3
        if ($4+0 > cr_of[id]+0)  cr_of[id]=$4
        if ($5+0 > cw_of[id]+0)  cw_of[id]=$5
        if ($6+0 > out_of[id]+0) out_of[id]=$6
      }
      END {
        for (id in model_of) {
          m=model_of[id]
          n[m]++; inp[m]+=inp_of[id]; cr[m]+=cr_of[id]; cw[m]+=cw_of[id]; out[m]+=out_of[id]
        }
        if (length(n) == 0) { printf "%-28s (no assistant messages in window)\n", label; exit }
        printf "%-28s %-22s %6s %10s %12s %12s %10s\n", label, "model", "msgs", "input", "cache_read", "cache_write", "output"
        for (m in n)
          printf "%-28s %-22s %6d %10d %12d %12d %10d\n", "", m, n[m], inp[m], cr[m], cw[m], out[m]
      }'
}

echo "== token report: $(basename "$transcript") ${since:+since=$since }${until_ts:+until=$until_ts}=="
report_one "$transcript" "main"

if [ -d "$session_dir/subagents" ]; then
  for f in "$session_dir/subagents"/agent-*.jsonl; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .jsonl)"; name="${name#agent-}"
    report_one "$f" "sub:${name%-*}"
  done
fi

echo "-- external CLIs (codex etc.) self-report on their own stdout; not included --"
