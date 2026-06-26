#!/usr/bin/env bash

########################
# Script by John Reed  #
# 2026-06-26           #
########################

# Removes home-list "flash" flags (flashUpdated / flashNew) from posts once
# they're no longer fresh, then commits + pushes so CI redeploys without the
# badge/pulse. Idempotent: if no flags are present, it does nothing.
#
# Usage: clear-flash-flag.sh [post.md ...]
#   With no args, clears both currently-flashing posts.

set -euo pipefail

REPO="/Users/jsreed/repos/eventually-consistent.io"
cd "$REPO"

# Default targets: every post that can currently be flashing.
if [ "$#" -gt 0 ]; then
  POSTS=("$@")
else
  POSTS=(
    "$REPO/content/posts/wiring-gsd-and-beads.md"
    "$REPO/content/posts/containers-a-means-to-an-end.md"
  )
fi

changed=()
for post in "${POSTS[@]}"; do
  [ -f "$post" ] || { echo "skip (missing): $post"; continue; }
  if grep -qE '^flash(Updated|New)[[:space:]]*=' "$post"; then
    echo "clearing flash flag(s) from $post..."
    sed -i '' -E '/^flash(Updated|New)[[:space:]]*=/d' "$post"
    git add "$post"
    changed+=("$post")
  fi
done

if [ "${#changed[@]}" -eq 0 ]; then
  echo "no flash flags found... nothing to do."
  exit 0
fi

git commit -F - <<'MSG'
content: clear home-list flash flags (no longer fresh)

Scheduled cleanup — drops the "New!" / "Updated" badge + pulse from the home
list now that these posts have been live for a week.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
MSG

git pull --rebase --autostash origin main || true
git push origin main

echo "cleared ${#changed[@]} post(s) + pushed."
