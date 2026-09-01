#!/bin/bash
#
# End your turn.  ./save.sh "what you changed"
#
# Saves your work and sends it to your friend. Run this BEFORE you walk
# away, or they can't see what you did.
#
set -e
BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; OFF=$'\033[0m'
ok()   { echo "  ${GREEN}✓${OFF} $1"; }
warn() { echo "  ${YELLOW}!${OFF} $1"; }
die()  { echo "  ${RED}✗${OFF} $1"; echo; exit 1; }

MSG="${1:-}"
[ -z "$MSG" ] && die "Say what you changed, in quotes:
    ./save.sh \"made the feed cards rounder\""

echo; echo "${BOLD}Saving your turn…${OFF}"; echo

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    ok "Nothing changed — nothing to save"
else
    git add -A
    git commit -q -m "$MSG"
    ok "Saved: $MSG"
fi

# If your friend pushed while you were working, fold their work in first.
# Without this the push is rejected and the error is not friendly.
if ! git push origin "$BRANCH" 2>/dev/null; then
    warn "Your friend pushed while you were working. Merging their work in…"
    if git pull --no-rebase origin "$BRANCH"; then
        git push origin "$BRANCH"
    else
        echo
        die "You and your friend edited the same lines, so git can't merge
    it automatically. This is normal and fixable — but don't guess at it.
    Open Claude Code here and say: \"I have a merge conflict, help me fix it\"
    Your work is saved and safe; nothing is lost."
    fi
fi

ok "Pushed — your friend can now run ./start.sh and pick up where you left off"
echo
