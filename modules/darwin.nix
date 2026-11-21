# macOS だけ
{
  config,
  lib,
  pkgs,
  ...
}:
let
  brewfile = "${config.xdg.configHome}/dotfiles/Brewfile";
in
{
  xdg.configFile."fish/conf.d/10-darwin.fish".source = config.lib.dotfiles.link "fish/darwin.fish";

  home.file.".yabairc".source = config.lib.dotfiles.link "yabai/yabairc";
  home.file.".skhdrc".source = config.lib.dotfiles.link "skhd/skhdrc";
  xdg.configFile."sketchybar".source = config.lib.dotfiles.link "sketchybar";

  # 共通の ghostty 設定が末尾で読み込む OS 別ファイル
  xdg.configFile."ghostty/local.conf".source = config.lib.dotfiles.link "ghostty/darwin.conf";

  home.packages = [
    # sketchybar の表示に使うフォント
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # GUI アプリは Homebrew の cask で入れる。アプリ自身が更新するので、Nix で版を固定しない。
  # 何を入れるかはここに書き、反映のときに足りないものだけが入る(入っているものの版は上げない)。
  # Homebrew の公式以外の tap から入れるものには trusted: true を付ける(付けないと Homebrew が読まない)
  xdg.configFile."dotfiles/Brewfile".text = ''
    tap "penso/tap"
    cask "ghostty"
    cask "cursor"
    cask "penso/tap/herdr-gpui", trusted: true
  '';

  home.activation.installHomebrewApps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ ! -x /opt/homebrew/bin/brew ]; then
      warnEcho "Homebrew がないので GUI アプリを入れていない。scripts/setup で入る"
    elif ! HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew bundle check --no-upgrade --file=${lib.escapeShellArg brewfile} >/dev/null 2>&1; then
      run env HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew bundle install --no-upgrade --file=${lib.escapeShellArg brewfile} \
        || warnEcho "GUI アプリを入れられなかった。scripts/check で足りないものを確かめる"
    fi
  '';
}
