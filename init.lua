-- ~/.hammerspoon/init.lua
-- Ctrl + middle-mouse-button (anywhere) -> open a new Ghostty window running `cc`,
-- then auto-tile the windows YOU launched this way into equal side-by-side columns.
-- Runs claude directly (what your `cc` alias expands to), by absolute path -- no alias,
-- no login-shell tax. See CLAUDE below.
--
-- Tiling is scoped to launched windows (tracked by window id), so your main working
-- window and any other Ghostty terminals are never moved.

require("hs.ipc") -- enables the `hs` command-line tool (debugging / manual triggers)

local GHOSTTY        = "/Applications/Ghostty.app/Contents/MacOS/ghostty"
local GHOSTTY_BUNDLE = "com.mitchellh.ghostty"
local HOME           = os.getenv("HOME") -- resolved at load -> absolute paths, no literal username
-- What `cc` expands to, built from $HOME (portable across your Macs) and run by ABSOLUTE PATH:
-- claude's dir is on PATH only via your interactive zsh config, which the launcher's non-login
-- `zsh -c` never sources -- so a bare `claude` wouldn't resolve. Building from HOME keeps the
-- abs-path guarantee while dropping the hard-coded /Users/ancplua.
-- NOTE: model is claude-opus-4-8[1m] (Opus 4.8, 1M context). The [1m] brackets are a zsh glob,
-- so they're backslash-escaped -- inside `zsh -c '...'` they resolve to a literal [1m] (without
-- the escaping zsh dies with "no matches found").
local CLAUDE         = HOME .. "/.local/bin/claude --dangerously-skip-permissions --ide"
                       .. " --system-prompt-file " .. HOME .. "/.claude/CLAUDE-FABLE-5.md"
                       .. " --model claude-opus-4-8\\[1m\\]"
local managed        = {} -- set of window:id() we launched via Ctrl+middle

-- All current standard, visible Ghostty windows (across every Ghostty process).
local function ghosttyWindows()
  local t = {}
  for _, w in ipairs(hs.window.allWindows()) do
    local app = w:application()
    if app and app:bundleID() == GHOSTTY_BUNDLE
       and w:isStandard() and w:isVisible() and not w:isMinimized() then
      t[#t + 1] = w
    end
  end
  return t
end

-- Tile only the windows we launched, into equal vertical columns on the main screen.
function tileManaged()
  local wins = {}
  for _, w in ipairs(ghosttyWindows()) do
    if w:id() and managed[w:id()] then wins[#wins + 1] = w end
  end
  if #wins == 0 then return 0 end
  table.sort(wins, function(a, b) return a:frame().x < b:frame().x end) -- stable left-to-right
  local f    = hs.screen.mainScreen():frame()
  local colW = f.w / #wins
  for i, w in ipairs(wins) do
    w:setFrame({ x = f.x + (i - 1) * colW, y = f.y, w = colW, h = f.h }, 0) -- 0 = no animation
  end
  return #wins
end

-- Spawn claude, then claim+tile the new window. Runs OFF the mouse-event thread.
-- Detached via plain /bin/sh + `&` (returns instantly). Inside the window, `zsh -c`
-- sources ONLY ~/.zshenv (keeps your CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1) and skips
-- the ~1s p10k/nvm of an interactive login shell. Claude's own tool-shells re-init from
-- your profile, so PATH-dependent tools (dotnet/git) still resolve inside the session.
local function spawnAndTile()
  local before = {}
  for _, w in ipairs(ghosttyWindows()) do if w:id() then before[w:id()] = true end end

  hs.execute(GHOSTTY .. " -e zsh -c '" .. CLAUDE .. "' >/dev/null 2>&1 &") -- fast /bin/sh, detached

  local function claimAndTile()
    for _, w in ipairs(ghosttyWindows()) do
      if w:id() and not before[w:id()] then managed[w:id()] = true end
    end
    tileManaged()
  end
  for _, d in ipairs({ 0.7, 1.4, 2.4, 3.6 }) do hs.timer.doAfter(d, claimAndTile) end
end

-- Watch global mouse-button-down events. Button numbers: 0=left, 1=right, 2=middle.
ccLauncher = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(e)
  local button   = e:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
  local ctrlHeld = e:getFlags().ctrl
  if button == 2 and ctrlHeld then
    hs.timer.doAfter(0, spawnAndTile) -- defer OFF the event thread => zero click lag
    return true                       -- swallow ONLY Ctrl+middle; plain middle-click untouched
  end
  return false
end)
ccLauncher:start()

-- Optional second trigger: a deliberately rare keychord, bound to the SAME launcher, so a
-- programmable mouse / keyboard macro can fire it from a dedicated button. Nothing above
-- depends on this -- Ctrl + middle-click works on any three-button mouse without it.
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "F12", function() spawnAndTile() end)

-- Debug helper: hs -c "return ccStatus()"
function ccStatus()
  local n = 0
  for _ in pairs(managed) do n = n + 1 end
  return "ghostty windows: " .. #ghosttyWindows() .. " | managed(launched): " .. n
end

hs.alert.show("cc launcher reloaded — fast (non-blocking) launch")
