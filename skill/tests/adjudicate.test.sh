#!/usr/bin/env bash
# adjudicate.test.sh — pure-bash tests for adjudicate.sh (no bats).
# Fixtures are synthetic dispatch files written into a mktemp sandbox, so the
# suite is hermetic. NOTE: intentionally no `set -e` — assertions capture
# non-zero exits on purpose.
set -uo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/adjudicate.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0; total=0

eq() {  # eq <name> <expected> <actual>
  total=$((total + 1))
  if [ "$2" = "$3" ]; then printf 'PASS  %-34s (%s)\n' "$1" "$3"; pass=$((pass + 1))
  else printf 'FAIL  %-34s exp=%s got=%s\n' "$1" "$2" "$3"; fail=$((fail + 1)); fi
}
has() {  # has <name> <haystack> <needle>  — needle must be present
  total=$((total + 1))
  if printf '%s' "$2" | grep -qF -- "$3"; then printf 'PASS  %-34s (has: %s)\n' "$1" "$3"; pass=$((pass + 1))
  else printf 'FAIL  %-34s (missing: %s)\n' "$1" "$3"; fail=$((fail + 1)); fi
}
hasnt() {  # hasnt <name> <haystack> <needle>  — needle must be absent
  total=$((total + 1))
  if printf '%s' "$2" | grep -qF -- "$3"; then printf 'FAIL  %-34s (unexpected: %s)\n' "$1" "$3"; fail=$((fail + 1))
  else printf 'PASS  %-34s (absent: %s)\n' "$1" "$3"; pass=$((pass + 1)); fi
}

# mk <outfile> <workspace-value> ; Verify bash-body read from stdin
mk() {
  local out="$1" ws="$2"
  { echo "# DISPATCH: fixture"; echo
    [ -n "$ws" ] && echo "> Workspace: $ws"
    echo; echo "## Task"; echo "fixture"; echo
    echo "## Verify (run these)"; echo; echo '```bash'; cat; echo '```'; } > "$out"
}

# 1 — happy path: every command exits 0 → overall exit 0
mk "$TMP/d1.md" "$TMP" <<'EOF'
true
echo hello
EOF
o="$("$SCRIPT" "$TMP/d1.md" 2>&1)"; c=$?
eq   "happy-all-pass-exit0"        0 "$c"
has  "happy-packet-result"         "$o" "2/2 commands passed"
has  "happy-packet-verdict-line"   "$o" "verdict: accepted|rework"

# 2 — one command fails → overall exit 1, packet marks the FAIL
mk "$TMP/d2.md" "$TMP" <<'EOF'
true
false
EOF
o="$("$SCRIPT" "$TMP/d2.md" 2>&1)"; c=$?
eq   "one-fails-exit1"             1 "$c"
has  "one-fails-shows-FAIL"        "$o" "FAIL"
has  "one-fails-result-1of2"       "$o" "1/2 commands passed"

# 3 — dry-run lists commands and executes NOTHING (side effect must not happen)
mk "$TMP/d3.md" "$TMP" <<EOF
touch $TMP/sentinel_should_not_exist
EOF
o="$("$SCRIPT" "$TMP/d3.md" --dry-run 2>&1)"; c=$?
eq   "dry-run-exit0"               0 "$c"
has  "dry-run-lists-command"       "$o" "touch"
if [ -e "$TMP/sentinel_should_not_exist" ]; then s=EXISTS; else s=ABSENT; fi
eq   "dry-run-no-execution"        ABSENT "$s"

# 4 — missing dispatch file → exit 2
o="$("$SCRIPT" "$TMP/does_not_exist.md" 2>&1)"; c=$?
eq   "missing-file-exit2"          2 "$c"

# 5 — dispatch with no `## Verify` bash block → exit 2
{ echo "# DISPATCH: noverify"; echo; echo "## Task"; echo "nothing to verify"; } > "$TMP/d5.md"
o="$("$SCRIPT" "$TMP/d5.md" 2>&1)"; c=$?
eq   "no-verify-block-exit2"       2 "$c"

# 6 — workdir defaults to the `Workspace:` header (relative cmd resolves there)
mkdir -p "$TMP/wsA"; : > "$TMP/wsA/marker_A.txt"
mk "$TMP/d6.md" "$TMP/wsA" <<'EOF'
ls marker_A.txt
EOF
o="$("$SCRIPT" "$TMP/d6.md" 2>&1)"; c=$?
eq   "workdir-header-parsing-exit0" 0 "$c"
has  "workdir-header-in-packet"     "$o" "wsA"

# 7 — --workdir overrides the header
mkdir -p "$TMP/wsB"; : > "$TMP/wsB/marker_B.txt"
mk "$TMP/d7.md" "$TMP/wsA" <<'EOF'
ls marker_B.txt
EOF
o="$("$SCRIPT" "$TMP/d7.md" --workdir "$TMP/wsB" 2>&1)"; c=$?
eq   "workdir-override-exit0"       0 "$c"
has  "workdir-override-in-packet"   "$o" "wsB"

# 8 — comment + blank lines are skipped; only real commands are numbered
mk "$TMP/d8.md" "$TMP" <<'EOF'
# leading comment, not a command
true

   # indented comment
echo two
EOF
o="$("$SCRIPT" "$TMP/d8.md" --dry-run 2>&1)"; c=$?
eq   "filter-dry-run-exit0"        0 "$c"
has  "filter-has-1"                "$o" "[1]"
has  "filter-has-2"                "$o" "[2]"
hasnt "filter-drops-3rd"           "$o" "[3]"
has  "filter-count-2"              "$o" "commands : 2"

# 9 — git-repo workdir emits the git summary section
GREPO="$TMP/repo"; mkdir -p "$GREPO"
( cd "$GREPO" && git init -q && git config user.email t@t && git config user.name t \
  && echo one > f.txt && git add f.txt && git commit -qm init && echo two >> f.txt )
mk "$TMP/d9.md" "$GREPO" <<'EOF'
true
EOF
o="$("$SCRIPT" "$TMP/d9.md" 2>&1)"; c=$?
eq   "git-workdir-exit0"           0 "$c"
has  "git-summary-present"         "$o" "git summary"
has  "git-summary-status-dirty"    "$o" "f.txt"

echo "----------------------------------------"
echo "TOTAL: $total  PASS: $pass  FAIL: $fail"
[ "$fail" -eq 0 ]
