# macOS だけ
{ config, ... }:
{
  xdg.configFile."fish/conf.d/10-darwin.fish".source = config.lib.dotfiles.link "fish/darwin.fish";

  home.file.".yabairc".source = config.lib.dotfiles.link "yabai/yabairc";
  home.file.".skhdrc".source = config.lib.dotfiles.link "skhd/skhdrc";
  xdg.configFile."sketchybar".source = config.lib.dotfiles.link "sketchybar";

  # 共通の ghostty 設定が末尾で読み込む OS 別ファイル
  xdg.configFile."ghostty/local.conf".source = config.lib.dotfiles.link "ghostty/darwin.conf";
}
