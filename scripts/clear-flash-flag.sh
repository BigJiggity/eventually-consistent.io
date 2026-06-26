#!/usr/bin/env bash

########################
# Script by John Reed  #
# 2026-06-26           #
########################

# Removes the home-list "flashUpdated" flag from a post once it's no longer
# fresh, then commits + pushes so CI redeploys without the badge/pulse.
# Idempotent: if the flag is already gone, it does nothing.
#
# Usage: clear-flash-flag.sh [path/to/post.md]
#   defaults to the Cairn post.

set -euo pipefail

REPO="/Users/jsreed/repos/eventually-consistent.io"
POST="${1:-$REPO/content/posts/wiring-gsd-and-beads.md}"

cd "$REPO"

# Nothing to do if the flag isn't there (idempotent — safe to re-run).
if ! grep -q '^flashUpdated[[:space:]]*=' "$POST"; then
  echo "no flashUpdated flag in $POST... nothing to do."
  exit 0
fi

echo "clearing flashUpdated flag from $POST..."
sed -i '' '/^flashUpdated[[:space:]]*=/d' "$POST"

git add "$POST"
git commit -F - <<'MSG'
content(wiring): clear home-list flashUpdated flag (no longer fresh)

Scheduled cleanup — drops the "Updated" badge + pulse from the home list now
that the post has been live for a week.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
MSG

git pull --rebase --autostash origin main || true
git push origin main

echo "flag cleared + pushed."
