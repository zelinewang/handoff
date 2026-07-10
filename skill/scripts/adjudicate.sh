#!/usr/bin/env bash
# adjudicate.sh — mechanize the brain's adjudication of a returned dispatch.
# Part of the handoff skill: re-runs the dispatch's own Verify block and
# emits an ADJUDICATION PACKET (per-command PASS/FAIL + git summary) so the
# brain can accept/rework from evidence without re-reading the implementation.
#
# Usage:
#   adjudicate.sh <dispatch-file.md> [--dry-run] [--workdir DIR]
#
#   --dry-run      print the numbered Verify command list and exit (runs nothing)
#   --workdir DIR  run commands here (default: the dispatch's `Workspace:` header,
#                  else the current directory)
#
# Exit: 0 = every Verify command passed; 1 = at least one failed;
#       2 = dispatch file missing or has no `## Verify` bash block.
#
# Safety: executes ONLY the commands the brain wrote into the dispatch's first
# `## Verify` fenced bash block. Nothing outside that block is ever evaluated.

set -euo pipefail

usage() { sed -n '2,19p' "$0"; exit 1; }

# ---- args ------------------------------------------------------------------
[ $# -ge 1 ] || usage
dispatch=""; dry_run=0; workdir_override=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --workdir) workdir_override="${2:?--workdir needs a value}"; shift 2 ;;
    -h|--help) usage ;;
    -*) echo "adjudicate: unknown arg: $1" >&2; usage ;;
    *) if [ -z "$dispatch" ]; then dispatch="$1"; shift
       else echo "adjudicate: unexpected arg: $1" >&2; usage; fi ;;
  esac
done
[ -n "$dispatch" ] || usage
[ -f "$dispatch" ] || { echo "adjudicate: dispatch file not found: $dispatch" >&2; exit 2; }

# ---- extract the first ```bash block under a `## Verify` heading ------------
# State machine: 0 seek `## Verify`, 1 seek ```bash fence (bounded by the
# section), 2 collect commands (skip blanks + pure-comment lines), 3 done.
extract_verify() {
  awk '
    BEGIN { state = 0 }
    {
      if (state == 0) {
        if ($0 ~ /^##[[:space:]]+Verify([[:space:]]|$)/) state = 1
      } else if (state == 1) {
        if ($0 ~ /^##[[:space:]]/) state = 3                                  # left section, no bash block
        else if ($0 ~ /^[[:space:]]*```[[:space:]]*bash[[:space:]]*$/) state = 2
      } else if (state == 2) {
        if ($0 ~ /^[[:space:]]*```/) state = 3                                 # closing fence
        else if ($0 ~ /^[[:space:]]*$/) { }                                    # skip blank
        else if ($0 ~ /^[[:space:]]*#/) { }                                    # skip pure comment
        else print
      }
    }
  ' "$1"
}

commands=()
while IFS= read -r line; do
  commands+=("$line")
done < <(extract_verify "$dispatch")

if [ "${#commands[@]}" -eq 0 ]; then
  echo "adjudicate: no runnable commands in a '## Verify' fenced bash block: $dispatch" >&2
  exit 2
fi

# ---- resolve workdir -------------------------------------------------------
workspace_hdr="$(sed -n 's/^>[[:space:]]*Workspace:[[:space:]]*//p' "$dispatch" | head -1 | sed 's/[[:space:]]*$//')"
if   [ -n "$workdir_override" ]; then workdir="$workdir_override"
elif [ -n "$workspace_hdr" ];    then workdir="$workspace_hdr"
else workdir="$PWD"; fi
case "$workdir" in "~"*) workdir="${HOME}${workdir#\~}" ;; esac
if [ ! -d "$workdir" ]; then
  echo "adjudicate: workdir not a directory, falling back to cwd: $workdir" >&2
  workdir="$PWD"
fi

# ---- dry-run ---------------------------------------------------------------
if [ "$dry_run" -eq 1 ]; then
  echo "======== VERIFY COMMANDS (dry-run) ========"
  echo "dispatch : $dispatch"
  echo "workdir  : $workdir"
  echo "commands : ${#commands[@]}"
  i=0
  for cmd in "${commands[@]}"; do i=$((i + 1)); printf '[%d] %s\n' "$i" "$cmd"; done
  echo "(dry-run: nothing executed)"
  exit 0
fi

# ---- execute ---------------------------------------------------------------
echo "======== ADJUDICATION PACKET ========"
echo "dispatch : $dispatch"
echo "workdir  : $workdir"
echo "commands : ${#commands[@]}"
echo ""
fail_count=0; i=0
for cmd in "${commands[@]}"; do
  i=$((i + 1))
  # Run each command in an isolated subshell cd'd to workdir, WITHOUT inheriting
  # errexit/pipefail so the exit code matches what a human running it would see.
  out="$( set +e +o pipefail; cd "$workdir" 2>/dev/null && eval "$cmd" 2>&1 )" && code=0 || code=$?
  if [ "$code" -eq 0 ]; then word="PASS"; else word="FAIL"; fail_count=$((fail_count + 1)); fi
  printf '[%d] %s (exit %d) : %s\n' "$i" "$word" "$code" "$cmd"
  if [ -n "$out" ]; then printf '%s\n' "$out" | tail -5 | sed 's/^/    | /'; else echo "    | (no output)"; fi
done
echo ""

# ---- git summary (only when workdir is inside a work tree) ------------------
if git -C "$workdir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  g_status="$(git -C "$workdir" status --short 2>/dev/null | head || true)"
  if git -C "$workdir" rev-parse HEAD >/dev/null 2>&1; then
    g_diff="$(git -C "$workdir" diff --stat HEAD 2>/dev/null | tail -3 || true)"
  else
    g_diff="(no commits yet)"
  fi
  echo "-- git summary ($workdir) --"
  echo "status (git status --short | head):"
  if [ -n "$g_status" ]; then printf '%s\n' "$g_status" | sed 's/^/    /'; else echo "    (clean)"; fi
  echo "diff (git diff --stat HEAD | tail -3):"
  if [ -n "$g_diff" ]; then printf '%s\n' "$g_diff" | sed 's/^/    /'; else echo "    (no changes)"; fi
  echo ""
fi

passed=$(( ${#commands[@]} - fail_count ))
echo "result: ${passed}/${#commands[@]} commands passed"
echo "verdict: accepted|rework — <reason>"
echo "====================================="

if [ "$fail_count" -eq 0 ]; then exit 0; else exit 1; fi
