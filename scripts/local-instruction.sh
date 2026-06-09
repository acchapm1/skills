#!/usr/bin/env bash
set -euo pipefail

# Links the LOCAL skill set for an INSTRUCTIONAL / writeup project (LCI
# modules, SLURM labs, decks, research) into ./.claude/skills in the current
# working directory. Run this from inside the project repo you want to equip.
#
# These supplement the global core (grill-me, diagnose, handoff, ...) which is
# inherited from ~/.claude/skills — only the instruction-specific extras are
# linked here.

SKILLS=(
  scaffold-exercises  # course exercise directory structures
  teach               # workspace-scoped learning docs
)

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$PWD/.claude/skills"

# Refuse to run from inside the skills repo itself: DEST would point back into
# the repo and we'd link skills onto themselves.
case "$PWD" in
  "$REPO"|"$REPO"/*)
    echo "error: run this from inside a TARGET project, not the skills repo ($REPO)." >&2
    exit 1
    ;;
esac

# If ./.claude/skills is a symlink that resolves into this repo, bail out
# instead of writing the per-skill symlinks back into the repo's skills/ tree.
if [ -L "$DEST" ]; then
  resolved="$(readlink -f "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into the skills repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"
echo "target: $DEST"

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
