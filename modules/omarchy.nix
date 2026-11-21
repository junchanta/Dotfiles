# Omarchy だけ
#
# デスクトップ(Hyprland、テーマ、GUI アプリ)と、mise で入る道具(Claude Code、Codex、opencode、node など)は
# Omarchy に任せる。ここには、共通の設定を Omarchy の上で動かすのに要るものだけを書く
{ config, lib, ... }:
{
  # Claude Code と opencode は、Omarchy 自身が mise で入れて更新する(/etc/mise/conf.d/omarchy-tools.toml)。
  # その設定はシステムのもので外せないので、公式のインストーラでも入れると、同じコマンドが 2 つになる。
  # そのため、共通の一覧を Omarchy でだけ空にする。Omarchy 以外の Linux では、共通の一覧どおりに入る
  dotfiles.installerTools = lib.mkForce [ ];

  xdg.configFile."fish/conf.d/10-omarchy.fish".source = config.lib.dotfiles.link "fish/omarchy.fish";

  # 共通の ghostty 設定が末尾で読み込む OS 別ファイル。Omarchy のテーマと見た目はここで読み込む
  xdg.configFile."ghostty/local.conf".source = config.lib.dotfiles.link "ghostty/omarchy.conf";

  # tmux は ~/.tmux.conf の後に ~/.config/tmux/tmux.conf も読む。
  # Omarchy が置いた設定が残っていると、共通の設定(prefix など)を上書きするので、このファイルで置き換える
  xdg.configFile."tmux/tmux.conf".source = config.lib.dotfiles.link "tmux/omarchy.conf";
}
