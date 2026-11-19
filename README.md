# Dotfiles

複数のマシン(macOS と Omarchy)で同じ開発環境を使うための設定リポジトリである。
CLI ツールは Nix で入れ、設定ファイルは home-manager がホームディレクトリへリンクする。

この README は運用の手順書であり、常に現状に合わせて更新する。
なぜこの構成にしたかの経緯は [docs/history/](docs/history/) にある。

## 前提知識

- **Nix**：パッケージマネージャである。入れたものはすべて `/nix/store` に置かれ、設定ファイルに書いた内容から環境を組み立て直せる。
- **home-manager**：Nix の上で動く道具で、ユーザーのホームディレクトリ(CLI ツールとドットファイル)を管理する。
- **flake**：Nix の設定リポジトリの形式である。`flake.nix` が依存と出力を定め、`flake.lock` が依存の版を固定する。

## 全体像

```
flake.nix        依存(nixpkgs、home-manager)と、マシンの一覧
flake.lock       依存の版の固定
hosts/           マシンごとの設定。使う modules を選ぶ
modules/         範囲ごとの設定。入れるツールと、config/ のどれをどこへリンクするか
  common.nix     全マシン共通
  darwin.nix     macOS だけ
config/          設定ファイルの実体。アプリ名で並べる
docs/history/    設計の経緯
```

設定ファイルは、次の順につながってホームに届く。

1. `flake.nix` がマシン(`macbook` など)を定義し、`hosts/macbook.nix` を読む
2. `hosts/macbook.nix` が、使う範囲(`common.nix`、`darwin.nix`)を選ぶ
3. 各 `modules/*.nix` が「`config/` のこのファイルを、ホームのこの場所にリンクする」と書く
4. `home-manager switch` を実行すると、ホームにリンクが張られる

リンクの先はリポジトリのファイルそのものである。
そのため `config/` のファイルを編集すると、`home-manager switch` を実行しなくても、すぐに反映される。

マシンは現在 `macbook`(macOS)だけである。
Omarchy 用の `hosts/` と `modules/omarchy.nix` はまだない。
Omarchy に対応させるときは、次の点を直す必要がある。

- tmux：コピーに `pbcopy`、ディレクトリを開くのに `open` を使っている。Linux では `wl-copy` と `xdg-open` に切り替える
- ghostty：Omarchy のテーマを読み込む Linux 用の `local.conf` を作り、`modules/omarchy.nix` から配る
- herdr：`config.toml` のディレクトリを開くキーが `open .` である

## 何がどこで管理されているか

- 全マシン共通(`modules/common.nix`)
    - CLI ツール：eza、bat、tree、wget、ripgrep、fzf、jq、direnv、git、gh、lazygit、neovim、tmux、fish、luarocks、lua-language-server、shfmt
    - 設定：fish、nvim、tmux、git、ghostty、Cursor、herdr
- macOS だけ(`modules/darwin.nix`)
    - 設定：yabai、skhd、sketchybar、fish と ghostty の macOS 用の部分
- マシンごと(リポジトリの管理外。各マシンで直接書く)
    - `~/.config/fish/conf.d/90-local.fish`：言語別の道具(anyenv、Go、Rust など)の PATH
    - `~/.config/fish/functions/`：そのマシンでだけ使う fish の関数
    - `~/.config/herdr/config-gpui.local.toml`、`~/.config/herdr/hws.json`：herdr の画面設定とワークスペース定義

GUI アプリと、言語の実行環境(node、python など)は Nix で管理していない。
各マシンで個別に入れる。

### fish の設定の読み込み順

fish の設定は 3 つのファイルに分かれており、`~/.config/fish/conf.d/` の中で名前順に読まれる。

1. `10-darwin.fish`：macOS だけの設定(`config/fish/darwin.fish`)
2. `20-common.fish`：全マシン共通の設定(`config/fish/common.fish`)
3. `90-local.fish`：そのマシンだけの設定(管理外)

共通の設定は、Nix のツールを Homebrew より前に置く。
`90-local.fish` で PATH を足すときは、次の書き方にする。

```fish
fish_add_path --path --move <ディレクトリ>
```

`--move` を付けると、そのディレクトリが既に PATH にあっても先頭へ移すので、Nix の同名のコマンドより優先される。
付けないと、既に PATH にある場合は位置が変わらず、Nix のほうが使われることがある。

`~/.config/fish/config.fish` は home-manager が生成するファイルである。
編集しても次の `home-manager switch` で上書きされるので、触らない。

## 日常の操作

以降のコマンドは、リポジトリが `~/Work/Dotfiles` にある前提である。
リンクの張り先がこの場所に固定されているため、別の場所には置けない。

### 設定ファイルを変える

`config/` の中のファイルを直接編集する。
`home-manager switch` は不要である。

アプリが設定を読み直すまでは反映されない。

- fish：新しいシェルを開く
- tmux：`Ctrl-t` → `r`
- ghostty：`Cmd-Shift-,`
- herdr：`Ctrl-t` → `Shift-r`
- nvim：開き直す
- Cursor：自動で反映される

Cursor のように、アプリの画面から設定を変えた場合も、`config/` のファイルが直接書き換わる。
変更はそのままコミットすればよい。

### 反映する

`modules/`、`hosts/`、`flake.nix` を変えたときは、次のコマンドで反映する。

```sh
home-manager switch --flake ~/Work/Dotfiles#macbook
```

新しく作ったファイルは、実行の前に `git add` しておく。
flake は Git が追跡していないファイルを読まないため、追加しないと「ファイルがない」というエラーになる。

### CLI ツールを足す、消す

1. パッケージ名を調べる(`nix search nixpkgs <名前>` か https://search.nixos.org/packages)
2. `modules/common.nix` の `home.packages` に足すか、消す
3. 反映する

macOS だけで使うツールは `modules/darwin.nix` に足す。
`darwin.nix` はまだ `pkgs` を受け取っていないので、引数にも足す。

```nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ <パッケージ名> ];
  # 既存の設定はそのまま
}
```

### 管理する設定ファイルを足す

1. 設定ファイルを `config/<アプリ名>/` に移す
2. `modules/common.nix`(macOS だけなら `modules/darwin.nix`)に、リンクを 1 行足す

```nix
# ~/.config/<アプリ名>/config に置く場合
xdg.configFile."<アプリ名>/config".source = config.lib.dotfiles.link "<アプリ名>/config";

# ホーム直下(~/.<名前>)に置く場合
home.file.".<名前>".source = config.lib.dotfiles.link "<アプリ名>/<名前>";
```

3. 反映する(元のファイルが残っていると止まる。[困ったとき](#困ったとき)を参照)
4. リンクの最終的な行き先が `~/Work/Dotfiles/config/` の中で、実在することを確かめる

```fish
path resolve ~/.config/<アプリ名>/config   # ~/Work/Dotfiles/config/... と出ればよい
test -e ~/.config/<アプリ名>/config; and echo ok
```

`config.lib.dotfiles.link` に書くパスを間違えても、エラーにはならず、切れたリンクができるだけである。
4 の確認はそのためである。
リンクは Nix のストアを経由するので、`ls -l` では最終的な行き先が分からない。

### ツールの版を上げる

```sh
cd ~/Work/Dotfiles
nix flake update
home-manager switch --flake ~/Work/Dotfiles#macbook
```

動作に問題がなければ、更新された `flake.lock` をコミットする。
ほかのマシンは、この `flake.lock` を取り込んで反映すると同じ版になる。

### ほかのマシンの変更を取り込む

別のマシンでコミットした変更を、このマシンに取り込む。

```sh
cd ~/Work/Dotfiles
git status                  # 未コミットの変更があれば、先にコミットする
git pull --ff-only
home-manager switch --flake ~/Work/Dotfiles#macbook
```

`config/` だけの変更なら、pull した時点で反映される。
`modules/`、`hosts/`、`flake.nix`、`flake.lock` が変わっていた場合は、switch しないとツールやリンクが古いままになる。
迷ったら switch してよい。変更がなければ何も起きない。

### 元に戻す

基本は Git で戻してから反映する。
設定ファイルの中身も、ツールの版(`flake.lock`)も、リンクの張り方(`modules/`)も、すべて Git で管理しているためである。

```sh
cd ~/Work/Dotfiles
git revert <戻したいコミット>
home-manager switch --flake ~/Work/Dotfiles#macbook
```

switch 自体が失敗して反映できないときだけ、home-manager の世代を直接戻す。
世代は switch のたびに作られる。
一覧を見て、戻したい世代のパスにある `activate` を実行する。

```sh
home-manager generations
# 2026-11-18 22:07 : id 2 -> /nix/store/...-home-manager-generation
/nix/store/...-home-manager-generation/activate
```

世代を戻しても、リポジトリの中身は戻らない。
`config/` のファイルを動かした後なら、戻した世代のリンクが存在しないファイルを指すことがある。
また、次の switch でリポジトリの状態に戻る。
落ち着いたら、Git でも戻してから switch し直す。

### 古い世代を消す

30 日より古い世代と、どこからも使われなくなったパッケージを消して、ディスクを空ける。

```sh
nix-collect-garbage --delete-older-than 30d
```

home-manager の世代と、ツールが入っているプロファイルの世代の両方が対象になる。
消した世代には戻せなくなる。

## 新しいマシンのセットアップ

1. Nix を入れる

```sh
# macOS
curl -L https://nixos.org/nix/install | sh
# Linux
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

終わったら新しいターミナルを開き、`nix --version` が動くことを確かめる。

2. flake を使えるようにする

```sh
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

3. このリポジトリを `~/Work/Dotfiles` に clone する
4. 環境を適用する(`<host>` は `hosts/` のファイル名)

```sh
nix run home-manager -- switch --flake ~/Work/Dotfiles#<host> -b bak
```

`-b bak` を付けると、既にあるファイルは `.bak` を付けて退避される。
中身を確かめて、不要なら消す。

5. ログインシェルを Nix の fish にする(sudo のパスワードを聞かれる)

```sh
echo ~/.nix-profile/bin/fish | sudo tee -a /etc/shells
chsh -s ~/.nix-profile/bin/fish
```

6. 必要なら、マシンごとの設定を `~/.config/fish/conf.d/90-local.fish` に書く
7. Cursor の拡張機能を入れる

```sh
cat ~/Work/Dotfiles/config/cursor/extensions.txt | xargs -L1 cursor --install-extension
```

拡張機能を足したり消したりしたときは、一覧を更新してコミットする。

```sh
cursor --list-extensions > ~/Work/Dotfiles/config/cursor/extensions.txt
```

## マシンを増やす

1. `hosts/<マシン名>.nix` を作る(`hosts/macbook.nix` を写して、`imports`、`home.username`、`home.homeDirectory` を直す)
2. `flake.nix` の `homeConfigurations` に 1 項目足す。`system` は Apple Silicon の Mac なら `aarch64-darwin`、x86_64 の Linux なら `x86_64-linux` である
3. `git add` してから、そのマシンで反映する

マシン名には実際のホスト名を使わない。
ホスト名に個人名が含まれることがあり、それをリポジトリに書かないためである。

## 困ったとき

### 「Existing file ... is in the way」と出て止まる

home-manager がリンクを張ろうとした場所に、別のものがある。
原因は次のどれかである。

- 初めて管理する設定ファイルが、普通のファイルとして残っている
- アプリが、リンクを普通のファイルで上書きした
- 以前に手で張ったシンボリックリンクが残っている

対処は次のとおりである。

1. そのファイルと `config/` の中身を比べ、必要な変更を `config/` に取り込む
2. そのファイル(シンボリックリンクならリンク自体)を消す
3. もう一度反映する

`-b bak` を付けて反映すると、普通のファイルは消す代わりに `.bak` を付けて退避される。
ただし、シンボリックリンクは退避されずに止まるので、2 で手で消す。
同じ名前の `.bak` が既にある場合も止まる。

### 反映したのにコマンドが見つからない、古い版が動く

反映する前から開いているシェルは、古い PATH のままである。
新しいシェルを開く。
アプリ(Cursor、ghostty、herdr など)は起動したときの環境を使い続けるので、おかしいときは再起動する。

### 新しく作った .nix ファイルが「存在しない」と言われる

`git add` していない。
flake は Git が追跡しているファイルしか読まない。
