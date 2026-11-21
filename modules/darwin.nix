# macOS だけ
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Homebrew の cask で入れる GUI アプリ。アプリ自身が更新するので、Nix で版を固定しない。
  # app は /Applications に置かれる名前、cask は Homebrew に渡す行。
  # 反映のときに、/Applications にないものだけを入れる。入れ方は問わず、あれば入っているとみなす
  guiApps = [
    {
      app = "Ghostty.app";
      cask = ''cask "ghostty"'';
    }
    {
      app = "Cursor.app";
      cask = ''cask "cursor"'';
    }
    {
      app = "Herdr.app";
      # Homebrew の公式以外の tap のものには trusted: true を付ける(付けないと Homebrew が読まない)
      cask = ''cask "penso/tap/herdr-gpui", trusted: true'';
    }
  ];
  guiAppsList = pkgs.writeText "gui-apps" (lib.concatMapStrings (a: "${a.app}\t${a.cask}\n") guiApps);
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

  # scripts/check が読む一覧
  xdg.configFile."dotfiles/gui-apps".source = guiAppsList;

  # 常駐ツールの登録(setupLaunchAgents)より後に行う。Homebrew が時間を取っても、常駐ツールの起動を待たせない
  home.activation.installGuiApps = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
    missing="$(mktemp)"
    while IFS="$(printf '\t')" read -r app cask; do
      if [ ! -d "/Applications/$app" ] && [ ! -d "$HOME/Applications/$app" ]; then
        printf '%s\n' "$cask" >> "$missing"
      fi
    done < ${guiAppsList}
    if [ -s "$missing" ]; then
      if [ -x /opt/homebrew/bin/brew ]; then
        echo "[INFO]  /Applications にない GUI アプリを Homebrew で入れる(ここから Homebrew の出力)"
        if run env HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew bundle install --no-upgrade --file="$missing"; then
          echo "[INFO]  GUI アプリを入れた"
        else
          echo "[WARN]  GUI アプリを入れられなかった。反映は続ける。scripts/check で足りないものを確かめる"
        fi
      else
        echo "[WARN]  Homebrew がないので GUI アプリを入れていない。scripts/setup で入る"
      fi
    fi
    rm -f "$missing"
  '';
}
