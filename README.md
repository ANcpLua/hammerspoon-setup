# hammerspoon-setup — Ctrl + middle-mouse → Claude Code, anywhere

One-command bootstrap that turns a bare Mac into a portable agentic launcher.
**Ctrl + middle-mouse-click** (or a mouse onboard macro) opens a fresh Ghostty
terminal running Claude Code as **Opus 4.8 (1M context)** with the **Fable**
system prompt — and auto-tiles the windows you launch this way into equal columns.

The mouse carries the **trigger** (a `⌃⌥⇧F12` onboard macro). This repo carries the
**engine** (Hammerspoon config + prompt + installer). Run the installer once per
Mac, map the mouse once, and the chord works everywhere.

## Install

```bash
git clone <your-repo-url> ~/.hammerspoon-setup
cd ~/.hammerspoon-setup
./install.sh
```

`install.sh` is idempotent — safe to re-run. It:

1. installs **Homebrew** (if missing),
2. installs the **Hammerspoon** + **Ghostty** casks,
3. installs **Claude Code** via the native installer if `claude` isn't found,
4. symlinks `init.lua` → `~/.hammerspoon/init.lua` and `CLAUDE-FABLE-5.md` → `~/.claude/CLAUDE-FABLE-5.md` (backing up any real file it would replace),
5. launches / reloads Hammerspoon.

## Three manual steps (a script can't do these for you)

1. **Grant Hammerspoon permissions** — System Settings → Privacy & Security → **Accessibility** *and* **Input Monitoring** → enable Hammerspoon, then quit + reopen it. Without these the global mouse trigger can't fire.
2. **Log in to Claude Code** — run `claude` once (opens a browser; needs a Pro / Max / Team / Enterprise or Console account).
3. **Map the mouse** — Logitech G HUB → **Onboard Memory** mode → assign a button's onboard macro to **Ctrl + Alt + Shift + F12**. Onboard mode stores the chord on the mouse itself, so it fires on any Mac running this config with no G HUB installed.

## Trigger

- **Ctrl + middle-click** anywhere — or your mapped mouse button.
- Opens Ghostty running:

  ```
  $HOME/.local/bin/claude --dangerously-skip-permissions --ide \
    --system-prompt-file $HOME/.claude/CLAUDE-FABLE-5.md \
    --model claude-opus-4-8[1m]
  ```

- Windows launched this way tile into equal side-by-side columns; your other terminals are never moved.

## Files

| File | Role |
|------|------|
| `init.lua` | Hammerspoon config — the launcher + window tiler. Symlinked to `~/.hammerspoon/init.lua`. |
| `CLAUDE-FABLE-5.md` | The Fable system prompt. Symlinked to `~/.claude/CLAUDE-FABLE-5.md`. |
| `install.sh` | Idempotent bootstrap. |

## Notes

- **macOS only** — Hammerspoon and the mouse eventtap are Mac-specific. A different OS would need its own trigger handler (e.g. AutoHotkey on Windows).
- Paths in `init.lua` are built from `$HOME` (via `os.getenv`), so there's no hard-coded username — it's portable across your Macs.
- The `[1m]` in the model id is the **1M-context** variant; drop it and you get standard-context Opus 4.8. In `init.lua` its brackets are backslash-escaped so `zsh` doesn't treat them as a glob.
- Claude Code native installs auto-update in the background; Hammerspoon/Ghostty casks update via `brew upgrade`.
