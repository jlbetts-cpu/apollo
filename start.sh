#!/bin/bash
#
# Start your turn.  ./start.sh
#
# Gets your friend's latest work, then opens Xcode. Run this BEFORE you
# touch anything — that's the whole trick to two people sharing a repo.
#
set -e
BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; OFF=$'\033[0m'
ok()   { echo "  ${GREEN}✓${OFF} $1"; }
warn() { echo "  ${YELLOW}!${OFF} $1"; }

echo; echo "${BOLD}Starting your turn…${OFF}"; echo

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Uncommitted work from last time? Save it before pulling, or the pull fails.
if ! git diff --quiet || ! git diff --cached --quiet; then
    warn "You have unsaved changes from last time. Saving them first…"
    ./save.sh "work in progress"
fi

echo "  Fetching your friend's changes…"
git pull --no-rebase origin "$BRANCH"

BEHIND=$(git log --oneline HEAD@{1}..HEAD 2>/dev/null | wc -l | tr -d ' ')
if [ "$BEHIND" != "0" ] 2>/dev/null; then
    ok "Pulled $BEHIND new commit(s):"
    git log --oneline HEAD@{1}..HEAD | sed 's/^/      /'
else
    ok "Already up to date — nothing new since your last turn"
fi

[ -f Apollo/Core/Network/Config.swift ] || { warn "Config.swift missing — running setup"; ./setup.sh; exit 0; }

echo
open Apollo.xcodeproj
echo "  ${BOLD}Xcode is opening. Go build.${OFF}"
echo "  When you're done, run:  ${BOLD}./save.sh \"what you changed\"${OFF}"
echo
