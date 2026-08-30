#!/bin/bash
#
# Apollo — one-time setup.
#
# Run this once after cloning:   ./setup.sh
# It creates the secrets file the app needs, then opens the project in Xcode.
#

set -e

BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; OFF=$'\033[0m'
say()  { echo "${BOLD}$1${OFF}"; }
ok()   { echo "  ${GREEN}✓${OFF} $1"; }
warn() { echo "  ${YELLOW}!${OFF} $1"; }
die()  { echo "  ${RED}✗${OFF} $1"; echo; exit 1; }

echo
say "Setting up Apollo…"
echo

# ── 1. Right kind of computer? ───────────────────────────────────────────
if [ "$(uname)" != "Darwin" ]; then
    die "Apollo is a native iOS app, so it only builds on a Mac.
    This computer is $(uname), and there is no way around that —
    Xcode does not exist for Windows or Linux."
fi
ok "macOS detected"

# ── 2. Xcode installed? ──────────────────────────────────────────────────
if ! xcode-select -p >/dev/null 2>&1; then
    die "Xcode isn't installed yet.

    Open the App Store, search ${BOLD}Xcode${OFF}, install it (it's free, ~15GB,
    and takes a while). Then open Xcode once so it can finish setting
    itself up, and run ./setup.sh again."
fi
ok "Xcode found at $(xcode-select -p)"

# ── 3. The secrets file ──────────────────────────────────────────────────
# Config.swift is gitignored, so a fresh clone doesn't have it and the app
# won't compile without it. It was committed once early on, so we can pull
# it straight back out of git history instead of hunting for the keys.
CONFIG="Apollo/Core/Network/Config.swift"

if [ -f "$CONFIG" ]; then
    ok "Config.swift already present — leaving it alone"
else
    if git cat-file -e 1297cf7:"$CONFIG" 2>/dev/null; then
        mkdir -p "$(dirname "$CONFIG")"
        git show 1297cf7:"$CONFIG" > "$CONFIG"
        ok "Config.swift recovered from git history"
    else
        cat > "$CONFIG" <<'TEMPLATE'
import Foundation

// Fill these in from your Supabase dashboard: Settings → API
enum Config {
    static let supabaseURL = URL(string: "https://YOUR-PROJECT.supabase.co")!
    static let supabaseAnonKey = "YOUR-ANON-KEY"
}
TEMPLATE
        warn "Couldn't recover the real keys — wrote a template instead."
        warn "Open $CONFIG and paste your values from the Supabase dashboard."
    fi
fi

# ── 4. Open it ───────────────────────────────────────────────────────────
echo
say "Opening Xcode…"
open Apollo.xcodeproj
echo
cat <<'NEXT'
  Xcode is opening. Once it's up:

    1. Top-left, next to the ▶ button, pick a simulator
       (any recent iPhone — "iPhone 16 Pro" is a fine default).
    2. Press ⌘R, or click ▶.
    3. First build takes a few minutes. After that it's seconds.

  To edit: everything you'll want to touch is in Apollo/Features/
  (one folder per screen) and Apollo/Components/Theme.swift (all the
  colours and fonts in one place).

  Xcode's live preview: open any file in Apollo/Features/, press
  ⌥⌘↩, and you'll see that screen render as you type.

NEXT
