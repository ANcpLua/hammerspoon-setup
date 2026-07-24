#!/usr/bin/env bash
# install.sh — bootstrap the "Ctrl + middle-mouse → Claude Code" agentic setup on a Mac.
#
# Turns a bare macOS machine into the exact setup in one command:
#   Homebrew → Hammerspoon + Ghostty → Claude Code → symlinked config + Fable prompt.
# Idempotent: safe to run repeatedly. The trigger is Ctrl + middle-click on any three-button
# mouse; a ⌃⌥⇧F12 hotkey is bound to the same launcher for programmable mice (optional).
#
# Usage:  ./install.sh          # run from inside the cloned repo (e.g. ~/.hammerspoon-setup)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m  %s\n' "$*"; }
ok()   { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

[[ "$(uname -s)" == "Darwin" ]] || { warn "This bootstrap targets macOS only."; exit 1; }

# 1. Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found — installing…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if   [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew   ]]; then eval "$(/usr/local/bin/brew shellenv)"
fi
command -v brew >/dev/null 2>&1 || { warn "Homebrew still not on PATH; aborting."; exit 1; }
ok "Homebrew: $(brew --prefix)"

# 2. Hammerspoon + Ghostty --------------------------------------------------
for cask in hammerspoon ghostty; do
  if brew list --cask "$cask" >/dev/null 2>&1; then
    ok "$cask already installed"
  else
    log "Installing $cask…"
    brew install --cask --adopt "$cask" \
      || warn "$cask install skipped/failed (already present outside Homebrew?) — continuing"
  fi
done

# 3. Claude Code ------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"   # so a freshly-installed native binary resolves this run
if command -v claude >/dev/null 2>&1; then
  ok "claude present: $(claude --version 2>/dev/null || echo 'version check failed')"
else
  log "Claude Code not found — installing (native installer)…"
  curl -fsSL https://claude.ai/install.sh | bash \
    || warn "Claude Code install failed — continuing; run 'claude doctor' or re-run install.sh later"
  export PATH="$HOME/.local/bin:$PATH"
  if command -v claude >/dev/null 2>&1; then
    ok "claude installed: $(claude --version 2>/dev/null || true)"
  else
    warn "claude not on PATH after install — run 'claude doctor' to diagnose."
  fi
fi

# 4. Symlink config + prompt (backs up any real file it would overwrite) ----
link_file() {  # link_file <src> <dest>
  local src="$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then ok "already linked: $dest"; return; fi
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local bak
    bak="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    warn "existing file at $dest → backing up to $bak"
    mv "$dest" "$bak"
  fi
  ln -sfn "$src" "$dest"
  ok "linked: $dest → $src"
}
mkdir -p "$HOME/.hammerspoon" "$HOME/.claude"
link_file "$REPO_DIR/init.lua"          "$HOME/.hammerspoon/init.lua"
link_file "$REPO_DIR/CLAUDE-FABLE-5.md" "$HOME/.claude/CLAUDE-FABLE-5.md"

# 5. Bring Hammerspoon up (it loads the freshly-linked config) --------------
if pgrep -x Hammerspoon >/dev/null 2>&1; then
  if command -v hs >/dev/null 2>&1; then
    ( hs -c "hs.reload()" >/dev/null 2>&1 & )
    ok "Hammerspoon running — reload issued"
  else
    warn "Hammerspoon running — press ⌃⌘R in its console (or Reload Config in its menu) to load the new config"
  fi
else
  log "Launching Hammerspoon…"
  open -a Hammerspoon 2>/dev/null || warn "couldn't auto-launch Hammerspoon — open it from Applications"
fi

# 6. The manual steps a script can't do -------------------------------------
cat <<'NEXT'

────────────────────────────────────────────────────────────────────────────
 Almost there — two manual steps a script can't do for you:

 1. GRANT PERMISSIONS to Hammerspoon (required for the global mouse trigger):
      System Settings → Privacy & Security →
        • Accessibility     → enable Hammerspoon
        • Input Monitoring  → enable Hammerspoon
      Then quit + reopen Hammerspoon.

 2. LOG IN to Claude Code (one time, opens a browser):
      claude
      (needs a Claude Pro / Max / Team / Enterprise or Console account)

 Then: Ctrl + middle-click → a Ghostty window opens running Claude Code as
 Opus 4.8 (1M context) with the Fable prompt, and the windows you launch this
 way auto-tile into equal columns.

 Optional: the same launcher is also bound to the Ctrl+Alt+Shift+F12 keychord,
 so a programmable mouse or keyboard macro can trigger it from a dedicated
 button. See "Optional: trigger it from a programmable mouse" in README.md.
────────────────────────────────────────────────────────────────────────────
NEXT
