# hammerspoon-setup

**Ctrl + middle-mouse-click → a fresh Ghostty terminal running Claude Code** (Opus 4.8, 1M context, Fable system prompt), with the windows you launch this way auto-tiled into equal columns. macOS only.

The mouse carries the *trigger* (a `⌃⌥⇧F12` onboard macro); this repo is the *engine* it needs on each Mac.

## Setup

```bash
git clone https://github.com/ANcpLua/hammerspoon-setup.git ~/.hammerspoon-setup
cd ~/.hammerspoon-setup && ./install.sh
```

`install.sh` is idempotent: Homebrew → Hammerspoon + Ghostty → Claude Code → symlinks the config + prompt → launches Hammerspoon. Then three things a script can't do:

1. **Hammerspoon permissions** — System Settings → Privacy & Security → **Accessibility** and **Input Monitoring** → enable Hammerspoon, then restart it.
2. **Claude login** — run `claude` once (opens a browser; needs a Pro/Max/Team/Enterprise or Console account).
3. **Mouse macro** — G HUB → Onboard Memory → map a button to **Ctrl+Alt+Shift+F12**. Onboard mode fires it on any Mac, no G HUB needed.

## Files

| File | Symlinked to | Role |
|------|--------------|------|
| `init.lua` | `~/.hammerspoon/init.lua` | the launcher + window tiler |
| `CLAUDE-FABLE-5.md` | `~/.claude/CLAUDE-FABLE-5.md` | the Fable system prompt |
| `install.sh` | — | idempotent bootstrap |

## Notes

- Paths are built from `$HOME` (no hard-coded username), so it's portable across your Macs.
- `[1m]` in the model id = 1M context; it's backslash-escaped in `init.lua` so zsh doesn't glob it.
- Native Claude installs auto-update; update the casks with `brew upgrade`.
