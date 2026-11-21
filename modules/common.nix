# 全マシン共通
{ config, pkgs, ... }:
let
  # リポジトリの場所。全マシンで ~/Work/Dotfiles に置く前提
  dotfiles = "${config.home.homeDirectory}/Work/Dotfiles";

  # Cursor の設定の置き場所(ホームからの相対)。OS で違う
  cursorUserDir =
    if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support/Cursor/User" else ".config/Cursor/User";
in
{
  # config/ 以下のファイルへ直接リンクを張る関数。ほかの modules からも使う。
  # Nix ストアにコピーしないので、ファイルを編集するとすぐ反映される
  lib.dotfiles.link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/${path}";

  home.packages = with pkgs; [
    # 基本
    eza
    bat
    tree
    wget
    ripgrep
    fzf
    jq
    direnv

    # Git
    git
    gh
    lazygit

    # エディタ、ターミナル(fish は下の programs.fish が入れる)
    neovim
    tmux
    herdr # 本体だけ。macOS のアプリ版(herdr-gpui)は Homebrew で入れる

    # neovim が使うもの
    # (node も必要だが、言語の実行環境はマシンごとに入れるので、ここには含めない)
    luarocks
    lua-language-server
    shfmt
    tree-sitter # nvim-treesitter がパーサーを入れるときに使う
  ];

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        # プロンプトのテーマ
        name = "theme-batman";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-batman";
          rev = "2a76bd81f4805debd7f137cb98828bff34570562";
          hash = "sha256-Ko4w9tMnIi17db174FzW44LgUdui/bUzPFEHEHv//t4=";
        };
      }
    ];
  };

  # conf.d のファイルは名前順に読まれる。10 が OS 別、20 が共通、90 が各マシンの管理外ファイル
  xdg.configFile."fish/conf.d/20-common.fish".source = config.lib.dotfiles.link "fish/common.fish";
  xdg.configFile."fish/conf.d/21-theme.fish".source = config.lib.dotfiles.link "fish/theme.fish";

  # 設定ファイルのリンク。左が配置先、右が config/ の中の実体
  xdg.configFile."nvim".source = config.lib.dotfiles.link "nvim";
  home.file.".tmux.conf".source = config.lib.dotfiles.link "tmux/tmux.conf";
  home.file.".tmux.powerline.conf".source = config.lib.dotfiles.link "tmux/tmux.powerline.conf";
  home.file.".gitconfig".source = config.lib.dotfiles.link "git/config";
  xdg.configFile."git/ignore".source = config.lib.dotfiles.link "git/ignore";
  xdg.configFile."ghostty/config".source = config.lib.dotfiles.link "ghostty/config";
  xdg.configFile."herdr/config.toml".source = config.lib.dotfiles.link "herdr/config.toml";
  home.file."${cursorUserDir}/keybindings.json".source = config.lib.dotfiles.link "cursor/keybindings.json";
  home.file."${cursorUserDir}/settings.json".source = config.lib.dotfiles.link "cursor/settings.json";

  # Claude Code。skill は共有するものだけを 1 つずつリンクし、ほかの skill はマシンごとに残す
  home.file.".claude/CLAUDE.md".source = config.lib.dotfiles.link "claude/CLAUDE.md";
  home.file.".claude/skills/nvim-key".source = config.lib.dotfiles.link "claude/skills/nvim-key";
  home.file.".claude/skills/catch-up".source = config.lib.dotfiles.link "claude/skills/catch-up";
  home.file.".claude/skills/dotfiles".source = config.lib.dotfiles.link "claude/skills/dotfiles";

  # home-manager コマンド自体も home-manager で入れる
  programs.home-manager.enable = true;

  # 初回導入時の版。後から上げない(設定の互換性の基準になる値)
  home.stateVersion = "26.05";
}
