# macOS だけ
{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;

  # GUI アプリが入っているかを確かめる場所。/Applications か ~/Applications のどちらかにあればよい
  appPaths = app: [
    "/Applications/${app}/Contents/Info.plist"
    "${home}/Applications/${app}/Contents/Info.plist"
  ];

  # Homebrew で入れるもの。アプリ自身が更新するので、Nix で版を固定しない。
  # 反映のときに、present のどこにもないものだけを入れる。入れ方は問わず、あれば入っているとみなす。
  # line は Homebrew に渡す行。公式以外の tap のものには trusted: true を付ける(付けないと Homebrew が読まない)
  homebrewApps = [
    {
      name = "Ghostty";
      present = appPaths "Ghostty.app";
      line = ''cask "ghostty"'';
    }
    {
      name = "Cursor";
      present = appPaths "Cursor.app";
      line = ''cask "cursor"'';
    }
    {
      name = "Herdr";
      present = appPaths "Herdr.app";
      line = ''cask "penso/tap/herdr-gpui", trusted: true'';
    }
    {
      name = "Antigravity";
      present = appPaths "Antigravity.app";
      line = ''cask "antigravity"'';
    }
    {
      name = "Orca";
      present = appPaths "Orca.app";
      line = ''cask "stablyai/orca/orca", trusted: true'';
    }
    {
      # コマンドだけの cask。node がなくても入る
      name = "Codex";
      present = [ "/opt/homebrew/bin/codex" ];
      line = ''cask "codex"'';
    }
  ];
  # 1 行に「名前、確かめる場所(コロン区切り)、Homebrew に渡す行」をタブ区切りで書いた一覧
  homebrewAppsList = pkgs.writeText "homebrew-apps" (
    lib.concatMapStrings (
      a: "${a.name}\t${lib.concatStringsSep ":" a.present}\t${a.line}\n"
    ) homebrewApps
  );
in
{
  xdg.configFile."fish/conf.d/10-darwin.fish".source = config.lib.dotfiles.link "fish/darwin.fish";

  home.file.".yabairc".source = config.lib.dotfiles.link "yabai/yabairc";
  home.file.".skhdrc".source = config.lib.dotfiles.link "skhd/skhdrc";
  xdg.configFile."sketchybar".source = config.lib.dotfiles.link "sketchybar";

  # 共通の ghostty 設定が末尾で読み込む OS 別ファイル
  xdg.configFile."ghostty/local.conf".source = config.lib.dotfiles.link "ghostty/darwin.conf";
  # 配色の定義。ghostty に同梱の配色は、版によって名前が変わる(1.1 の tokyonight_night は、1.4 では別名)。
  # 同梱のものに頼らず、ここから配る
  xdg.configFile."ghostty/themes/tokyonight_night".source =
    config.lib.dotfiles.link "ghostty/themes/tokyonight_night";

  home.packages = [
    # sketchybar の表示に使うフォント
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # scripts/check が読む一覧
  xdg.configFile."dotfiles/homebrew-apps".source = homebrewAppsList;

  # 常駐ツールの登録(setupLaunchAgents)より後に行う。Homebrew が時間を取っても、常駐ツールの起動を待たせない
  home.activation.installHomebrewApps = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
    # $1 はコロン区切りの場所。どれか 1 つでもあれば、入っている
    homebrewAppInstalled() {
      local IFS=:
      local path
      for path in $1; do
        [ -e "$path" ] && return 0
      done
      return 1
    }

    missing=""
    while IFS="$(printf '\t')" read -r name present line; do
      homebrewAppInstalled "$present" || missing="$missing$line
    "
    done < ${homebrewAppsList}

    if [ -n "$missing" ]; then
      if [ -x /opt/homebrew/bin/brew ]; then
        echo "[INFO]  足りないものを Homebrew で入れる(ここから Homebrew の出力)"
        printf '%s' "$missing" \
          | run env HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew bundle install --no-upgrade --file=- \
          || echo "[WARN]  Homebrew が失敗した。反映は続ける"
        echo "[INFO]  Homebrew の出力はここまで"
        # 入ったかどうかを、もう一度確かめる。Homebrew は、登録だけが残っているものを入れ直さない。
        # dry run では何も入れていないので、確かめない
        if [[ ! -v DRY_RUN ]]; then
          while IFS="$(printf '\t')" read -r name present line; do
            homebrewAppInstalled "$present" \
              || echo "[WARN]  $name が入っていない($line)。Homebrew に登録だけが残っているなら brew reinstall --cask で入れ直す"
          done < ${homebrewAppsList}
        fi
      else
        echo "[WARN]  Homebrew がないので、Homebrew で入れるものを入れていない。scripts/setup で入る"
      fi
    fi
  '';
}
