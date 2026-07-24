# hammerspoon-setup

**Ctrl + middle-mouse-click → a fresh Ghostty terminal running Claude Code** (Opus 4.8, 1M context, Fable system prompt), with the windows you launch this way auto-tiled into equal columns. macOS only.

Any three-button mouse works — no vendor software, no special hardware. There's a second trigger, the `⌃⌥⇧F12` hotkey, bound to the same launcher (see [Optional: trigger it from a programmable mouse](#optional-trigger-it-from-a-programmable-mouse)).

## Setup

```bash
git clone https://github.com/ANcpLua/hammerspoon-setup.git ~/.hammerspoon-setup
cd ~/.hammerspoon-setup && ./install.sh
```

`install.sh` is idempotent: Homebrew → Hammerspoon + Ghostty → Claude Code → symlinks the config + prompt → launches Hammerspoon. Then two things a script can't do:

1. **Hammerspoon permissions** — System Settings → Privacy & Security → **Accessibility** and **Input Monitoring** → enable Hammerspoon, then restart it.
2. **Claude login** — run `claude` once (opens a browser; needs a Pro/Max/Team/Enterprise or Console account).

That's it — `Ctrl` + middle-click now launches a Claude Code window.

### Optional: trigger it from a programmable mouse

`init.lua` also binds `⌃⌥⇧F12` to the same launcher — a deliberately rare keychord, so nothing else claims it. Skip this section unless you want a *dedicated* mouse button (rather than `Ctrl` + middle-click) to do the launching.

If your mouse can emit a keystroke macro, map a button to **Ctrl+Alt+Shift+F12**. Storing the macro in the mouse's **onboard memory** (if it has any) means the button keeps working on any Mac running this config, with no vendor driver installed. On Logitech hardware that's G HUB → Onboard Memory; other vendors have an equivalent. Either way it's just a keychord — a keyboard macro tool, Karabiner-Elements, or a Stream Deck sends it just as well.

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
