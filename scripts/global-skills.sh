#!/usr/bin/env bash
set -euo pipefail

# Links the curated GLOBAL skill set into ~/.claude/skills, so they are
# available to the Claude CLI in every directory.
#
# These are the zero-config, domain-agnostic skills that are useful anywhere
# (including ad-hoc dirs with no project). Config-bound skills (the ones that
# read docs/agents/, CONTEXT.md, or docs/adr/) are deliberately NOT global —
# install those per-repo with local-coding.sh instead.

SKILLS=(
  grill-me        # resolve ambiguity in any plan
  diagnose        # disciplined debugging loop
  handoff         # compact a session for the next agent
  write-a-skill   # scaffold new skills from anywhere
  caveman         # compressed communication mode
)

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.claude/skills"

# If ~/.claude/skills is a symlink that resolves into this repo, we'd end up
# writing the per-skill symlinks back into the repo's own skills/ tree. Detect
# and bail out instead of polluting the working copy.
if [ -L "$DEST" ]; then
  resolved="$(readlink -f "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

for name in "${SKILLS[@]}"; do
  src="$(find "$REPO/skills" -type d -name "$name" -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print -quit)"
  if [ -z "$src" ] || [ ! -f "$src/SKILL.md" ]; then
    echo "warning: skill '$name' not found under $REPO/skills — skipping" >&2
    continue
  fi

  target="$DEST/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
  fi

  ln -sfn "$src" "$target"
  echo "linked $name -> $src"
done
