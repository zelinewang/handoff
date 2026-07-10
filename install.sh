#!/usr/bin/env bash
# install.sh — install the handoff skill into a Claude Code setup.
#
# What it does:
#   1. Copies skill/ -> ~/.claude/skills/handoff/ (backs up any existing dir).
#   2. Prints two CLAUDE.md snippets for you to paste in (a trigger row + a
#      model-tiering section). It does NOT edit CLAUDE.md or settings.json —
#      you stay in control of what your harness auto-loads.
#
# Usage:
#   bash install.sh [--dry-run] [--dest DIR]
#     --dry-run   show what would happen; change nothing
#     --dest DIR  install target (default: ~/.claude/skills/handoff)
#
# Idempotent: safe to re-run — each run backs up an existing install to
# <dest>.bak.<timestamp> before copying fresh, so nothing is silently lost.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/skill"
DEST="${HOME}/.claude/skills/handoff"
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1; shift ;;
    --dest) DEST="${2:?--dest needs a value}"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) printf 'install: unknown arg: %s\n' "$1" >&2; exit 2 ;;
  esac
done

say() { printf '%s\n' "$*"; }

if [ ! -d "$SRC" ]; then
  printf 'install: skill source not found: %s\n' "$SRC" >&2
  exit 1
fi

say "handoff installer"
say "  source : $SRC"
say "  target : $DEST"
[ "$DRY" -eq 1 ] && say "  mode   : DRY-RUN (nothing will change)"
say ""

# Back up an existing install, then copy fresh (keeps re-runs safe + idempotent).
if [ -e "$DEST" ]; then
  BACKUP="${DEST}.bak.$(date +%Y%m%d-%H%M%S)"
  if [ "$DRY" -eq 1 ]; then
    say "would back up existing install: $DEST -> $BACKUP"
  else
    mv "$DEST" "$BACKUP"
    say "backed up existing install: $BACKUP"
  fi
fi

if [ "$DRY" -eq 1 ]; then
  say "would copy: $SRC -> $DEST"
else
  mkdir -p "$(dirname "$DEST")"
  cp -R "$SRC" "$DEST"
  say "installed: $DEST"
fi

say ""
say "----------------------------------------------------------------------"
say "NEXT (manual — this installer does not edit CLAUDE.md or settings.json):"
say "Paste these two snippets into your CLAUDE.md so the skill triggers and"
say "the model-tiering rule applies to every spawn."
say "----------------------------------------------------------------------"
say ""
say "[1] Skill trigger row — add to your MCP/skill auto-selection table:"
say ""
cat <<'SNIPPET'
| Delegating implementation / saving lead-model tokens / spec-tracked dispatch / cross-session handoff | handoff skill | Brain writes a DISPATCH spec file -> routes to a subagent on a strong non-lead model (default) / an external CLI agent / an async agent queue; STATE.md ledger = handoff source of truth |
SNIPPET
say ""
say "[2] Model-tiering rule — add as a section:"
say ""
cat <<'SNIPPET'
### Agent Spawn Model Tiering
Goal: cut LEAD-model usage, not total tokens. Every subagent spawn MUST set an
explicit model — an omitted model silently inherits the lead model = zero saving.
- Pick the STRONGEST non-lead model that 100%-covers the task's purpose
  (capability-first: one rework round costs more than any per-token saving).
- NEVER spawn the lead model as a hand (that defeats the offload goal).
- NEVER use a fork to save cost — forks always inherit the parent model.
SNIPPET
say ""
say "Done. See docs/porting.md to adapt handoff to a non-Claude-Code harness."
