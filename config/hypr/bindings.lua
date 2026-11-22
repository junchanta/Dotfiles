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

-- SUPER + 文字 → CTRL + 文字。ターミナルでは CTRL + 文字が別の意味（中断、
-- 一時停止など）になるので、terminal に書いたキーだけ CTRL + SHIFT で送り、
-- それ以外は何もしない。
local mac_shortcuts = {
  { key = "Z", description = "取り消し" },
  { key = "S", description = "保存" },
  { key = "F", description = "検索", terminal = true },
  { key = "G", description = "次を検索" },
  { key = "T", description = "新しいタブ", terminal = true },
  { key = "W", description = "タブを閉じる", terminal = true },
  { key = "N", description = "新しいウィンドウ", terminal = true },
  { key = "L", description = "アドレスバー" },
  { key = "R", description = "再読み込み" },
  { key = "O", description = "開く" },
  { key = "P", description = "印刷" },
  { key = "B", description = "太字 / ブックマーク" },
  { key = "I", description = "斜体" },
  { key = "U", description = "下線" },
  { key = "D", description = "ブックマークに追加" },
  { key = "E" },
  { key = "J" },
  { key = "K" },
  { key = "Y" },
}

for _, shortcut in ipairs(mac_shortcuts) do
  local sends = "アプリへ CTRL + " .. shortcut.key
  local description = shortcut.description and (shortcut.description .. "（" .. sends .. "）") or sends

  o.rebind("SUPER + " .. shortcut.key, description, function()
    if not active_window_is_terminal() then
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
