-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- SUPER+SPACE: 日本語 <-> 英語の入力切り替え（元は Omarchy メニュー）。
o.rebind("SUPER + SPACE", "Switch input language", "omarchy-input-method cycle")

-- ---------------------------------------------------------------------------
-- Mac 風の構成
--   SUPER + 文字  = アプリのショートカット（Mac の Cmd と同じ。CTRL + 文字を送る）
--   CTRL + ; → 1 文字 = Omarchy の窓操作（リーダーキー）
-- ---------------------------------------------------------------------------

-- Omarchy の clipboard.lua と同じ送り方（押す/離すを分ける）。
local function send_shortcut_once(mods, key)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

-- Obsidian では CTRL + 文字を Vim の操作（<C-k>、<C-d>、<C-w> など）に使う。
-- SUPER + 文字を CTRL に変えて送ると Vim の操作と区別できなくなるので、
-- obsidian を付けたキーは SUPER のまま送る。Obsidian 側では、これらのコマンドの
-- ホットキーを Mod（Linux では CTRL）から Meta（SUPER。Mac では Cmd）に付け替えてある。
local function active_window_is_obsidian()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  return (window.class or window.initial_class or ""):lower():find("obsidian", 1, true) ~= nil
end

-- SUPER + 文字 → CTRL + 文字。ターミナルでは CTRL + 文字が別の意味（中断、
-- 一時停止など）になるので、terminal に書いたキーだけ CTRL + SHIFT で送り、
-- それ以外は何もしない。
local mac_shortcuts = {
  { key = "Z", description = "取り消し" },
  { key = "S", description = "保存" },
  { key = "F", description = "検索", terminal = true, obsidian = true },
  { key = "G", description = "次を検索", obsidian = true },
  { key = "T", description = "新しいタブ", terminal = true },
  { key = "W", description = "タブを閉じる", terminal = true, obsidian = true },
  { key = "N", description = "新しいウィンドウ", terminal = true },
  { key = "L", description = "アドレスバー" },
  { key = "R", description = "再読み込み" },
  { key = "O", description = "開く", obsidian = true },
  { key = "P", description = "印刷", obsidian = true },
  { key = "B", description = "太字 / ブックマーク", obsidian = true },
  { key = "I", description = "斜体", obsidian = true },
  { key = "U", description = "下線" },
  { key = "D", description = "ブックマークに追加", obsidian = true },
  { key = "E", obsidian = true },
  { key = "J" },
  { key = "K", obsidian = true },
  { key = "Y" },
}

for _, shortcut in ipairs(mac_shortcuts) do
  local sends = "アプリへ CTRL + " .. shortcut.key
  local description = shortcut.description and (shortcut.description .. "（" .. sends .. "）") or sends

  o.rebind("SUPER + " .. shortcut.key, description, function()
    if shortcut.obsidian and active_window_is_obsidian() then
      send_shortcut_once("SUPER", shortcut.key)
    elseif not active_window_is_terminal() then
      send_shortcut_once("CTRL", shortcut.key)
    elseif shortcut.terminal then
      send_shortcut_once("CTRL SHIFT", shortcut.key)
    end
  end)
end

o.bind("SUPER + SHIFT + Z", "やり直し（アプリへ CTRL + SHIFT + Z）", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL SHIFT", "Z")
  end
end)

-- リーダーキー CTRL+; : 押した直後の 1 打だけ Omarchy 用のキーになる。
-- 1 回操作すると自動で通常に戻る。ESC や他のキーで取り消し。
local after = "（CTRL + ; の後に押す）"

hl.define_submap("omarchy", "reset", function()
  o.bind("SPACE", "Omarchyメニュー" .. after, { menu = "root" })
  o.bind("K", "キーバインド一覧" .. after, "omarchy-menu-keybindings")
  o.bind("T", "フローティング/タイル切り替え" .. after, hl.dsp.window.float({ action = "toggle" }))
  o.bind("F", "最大化（トップバーは残す）" .. after, hl.dsp.window.fullscreen({ mode = "maximized" }))
  o.bind("M", "全画面（トップバーも隠す）" .. after, hl.dsp.window.fullscreen({ mode = "fullscreen" }))
  o.bind("J", "分割の向きを切り替え" .. after, hl.dsp.layout("togglesplit"))
  o.bind("L", "ワークスペースレイアウトを切り替え" .. after, "omarchy-hyprland-workspace-layout-toggle")
  o.bind("O", "ポップアウト（フロート＆ピン）" .. after, "omarchy-hyprland-window-pop")
  o.bind("P", "擬似ウィンドウ" .. after, hl.dsp.window.pseudo())
  o.bind("S", "スクラッチパッド" .. after, hl.dsp.workspace.toggle_special("scratchpad"))
  o.bind("G", "ウィンドウのグループ化" .. after, hl.dsp.group.toggle())

  -- 追加のスクラッチパッド 1〜3 を出し入れする。
  -- code:10〜12 は数字キーの 1〜3（Omarchy のワークスペース切り替えと同じ書き方）。
  for number = 1, 3 do
    o.bind("code:" .. tostring(number + 9), "スクラッチパッド " .. number .. after,
      hl.dsp.workspace.toggle_special("scratchpad" .. number))
  end
  hl.bind("ESCAPE", hl.dsp.submap("reset"))
  hl.bind("catchall", hl.dsp.submap("reset"))
end)
o.bind("CTRL + semicolon", "Omarchyリーダーキー（続けて 1 文字。SPACE でメニュー）", hl.dsp.submap("omarchy"))

-- CTRL+SHIFT+; → 数字 : いまのウィンドウをスクラッチパッド 1〜3 に入れる。
-- リーダーの後で SHIFT を押すと、その時点で「他のキー」扱いになって取り消される
-- ので、入れる操作は別のリーダーにしてある。SHIFT を押したままでも効くよう、
-- 数字だけの組み合わせと SHIFT 付きの両方を受ける。
local after_move = "（CTRL + SHIFT + ; の後に押す）"

hl.define_submap("omarchy_move", "reset", function()
  for number = 1, 3 do
    local key = "code:" .. tostring(number + 9)
    local move = hl.dsp.window.move({ workspace = "special:scratchpad" .. number, follow = false })

    o.bind(key, "ウィンドウをスクラッチパッド " .. number .. " へ移動" .. after_move, move)
    hl.bind("SHIFT + " .. key, move)
  end
  hl.bind("ESCAPE", hl.dsp.submap("reset"))
  hl.bind("catchall", hl.dsp.submap("reset"))
end)
o.bind("CTRL + SHIFT + semicolon", "ウィンドウをスクラッチパッドへ入れる（続けて 1〜3）", hl.dsp.submap("omarchy_move"))

-- SUPER+TAB: 開いているウィンドウをフローティングメニューで選んで切り替える（元は次のワークスペースへ移動）。
-- 表示中は TAB / SUPER+TAB で下へ、SHIFT+TAB / SUPER+SHIFT+TAB で上へ動く。Enter で決定、Esc で閉じる。
-- メニュー（Omarchy の持ち物）は上下キーしか受けないので、表示中だけ TAB を上下キーに変えて送る。
local window_switcher = os.getenv("HOME") .. "/.config/hypr/scripts/window-switcher"
local switcher_state = "closed" -- closed / starting / open
local switcher_tab_binds = {}

local function send_key_once(key)
  hl.dispatch(hl.dsp.send_key_state({ mods = "", key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = "", key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function set_switcher_tab_binds(enabled)
  for _, keybind in pairs(switcher_tab_binds) do
    -- Hyprland 0.56 は、消えたバインドの tostring 以外を触ると落ちる（Omarchy の utilities.lua と同じ対策）
    if keybind ~= nil and tostring(keybind) ~= "HL.Keybind(expired)" then
      keybind:set_enabled(enabled)
    end
  end
end

switcher_tab_binds.down = hl.bind("TAB", function() send_key_once("Down") end)
switcher_tab_binds.up = hl.bind("SHIFT + TAB", function() send_key_once("Up") end)
set_switcher_tab_binds(false)

hl.on("layer.opened", function(layer)
  if layer.namespace == "omarchy-menu" and switcher_state == "starting" then
    switcher_state = "open"
    set_switcher_tab_binds(true)
  end
end)

hl.on("layer.closed", function(layer)
  if layer.namespace == "omarchy-menu" then
    switcher_state = "closed"
    set_switcher_tab_binds(false)
  end
end)

o.rebind("SUPER + TAB", "Window switcher", function()
  if switcher_state == "open" then
    send_key_once("Down")
  elseif switcher_state == "closed" then
    switcher_state = "starting"
    hl.dispatch(hl.dsp.exec_cmd(window_switcher))
    -- メニューが開かなかったときに、表示待ちのまま残らないようにする
    hl.timer(function()
      if switcher_state == "starting" then switcher_state = "closed" end
    end, { timeout = 3000, type = "oneshot" })
  end
end)

o.rebind("SUPER + SHIFT + TAB", "Previous workspace (window switcher: up)", function()
  if switcher_state == "open" then
    send_key_once("Up")
  else
    hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
  end
end)
