# Dotfiles

複数のマシン(macOS と Omarchy)で同じ開発環境を使うための設定リポジトリである。
新しいマシンでは、このリポジトリを clone して `scripts/setup` を実行すると、同じ環境が立ち上がる。

この README は運用の手順書であり、常に現状に合わせて更新する。
なぜこの構成にしたかの経緯は [docs/history/](docs/history/) にある。

## 前提知識

- **Nix**：パッケージマネージャである。入れたものはすべて `/nix/store` に置かれ、設定ファイルに書いた内容から環境を組み立て直せる。
- **home-manager**：Nix の上で動く道具で、ユーザーのホームディレクトリ(ツール、設定ファイル、フォント、常駐ツール)を管理する。
- **flake**：Nix の設定リポジトリの形式である。`flake.nix` が依存と出力を定め、`flake.lock` が依存の版を固定する。
- **Homebrew の cask**：macOS の GUI アプリなどを入れる仕組みである。

## 方針

何を入れるかは、すべてこのリポジトリに書く。
入れる手段は次のように決めている。

- 基本は Nix で入れる。CLI ツールとフォントが当てはまる
- 自分で新しい版に更新するものは、Nix で入れない。Nix で版を固定すると、本体の更新と食い違うためである。一覧はこのリポジトリに書き、反映のときに、入っていないものだけが入る。入れた後の更新は、それぞれに任せる
    - macOS の GUI アプリと Codex は、Homebrew の cask で入れる
    - Claude Code と opencode は、それぞれの公式のインストーラで入れる
- 言語の実行環境(node、python など)と、プロジェクトごとの道具は管理しない。版がプロジェクトによって違うので、各マシンで個別に入れる

macOS でも Linux でも、反映に使うのは home-manager だけである。
nix-darwin は使っていない。

## 全体像

```
flake.nix        依存(nixpkgs、home-manager)と、マシンの一覧
flake.lock       依存の版の固定
hosts/           マシンごとの設定。使う modules を選ぶ
modules/         範囲ごとの設定。入れるものと、config/ のどれをどこへリンクするか
  common.nix     全マシン共通
  darwin.nix     macOS だけ
config/          設定ファイルの実体。アプリ名で並べる
scripts/         運用のコマンド
  setup          新しいマシンをセットアップする
  switch         リポジトリの定義をこのマシンに反映する
  check          このマシンが定義どおりに動いているかを確かめる
docs/history/    設計の経緯
```

設定ファイルは、次の順につながってホームに届く。

1. `flake.nix` がマシン(`macbook` など)を定義し、`hosts/macbook.nix` を読む
2. `hosts/macbook.nix` が、使う範囲(`common.nix`、`darwin.nix`)を選ぶ
3. 各 `modules/*.nix` が「`config/` のこのファイルを、ホームのこの場所にリンクする」と書く
4. `scripts/switch` を実行すると、ホームにリンクが張られ、ツールが入る

リンクの先はリポジトリのファイルそのものである。
そのため `config/` のファイルを編集すると、`scripts/switch` を実行しなくても、すぐに反映される。

マシンは現在 `macbook`(macOS)だけである。
Omarchy 用の `hosts/` と `modules/omarchy.nix` はまだない。
Omarchy に対応させるときは、次の点を直す必要がある。

- tmux：コピーに `pbcopy`、ディレクトリを開くのに `open` を使っている。Linux では `wl-copy` と `xdg-open` に切り替える
- ghostty：Omarchy のテーマを読み込む Linux 用の `local.conf` を作り、`modules/omarchy.nix` から配る
- herdr：`config.toml` のディレクトリを開くキーが `open .` である

## 何がどこで管理されているか

- 全マシン共通(`modules/common.nix`)
    - CLI ツール：eza、bat、tree、wget、ripgrep、fzf、jq、direnv、git、gh、lazygit、neovim、tmux、herdr、fish、luarocks、lua-language-server、shfmt、tree-sitter
    - 設定：fish(配色を含む)、nvim、tmux、git、ghostty、Cursor、herdr
    - Claude Code：グローバルの `CLAUDE.md` と、自作の skill(nvim-key、catch-up、dotfiles)
    - 公式のインストーラで入れるツール：Claude Code、opencode
- macOS だけ(`modules/darwin.nix`)
    - 設定：yabai、skhd、sketchybar、fish と ghostty の macOS 用の部分
    - フォント：JetBrainsMono Nerd Font(sketchybar の表示に使う)
    - Homebrew の cask で入れるもの：ghostty、Cursor、herdr のアプリ版、Antigravity、Orca、Codex
- マシンごと(リポジトリの管理外。各マシンで直接書く)
    - `~/.config/fish/conf.d/90-local.fish`：言語別の道具(anyenv、Go、Rust など)の PATH
    - `~/.config/fish/functions/`：そのマシンでだけ使う fish の関数
    - `~/.config/herdr/config-gpui.local.toml`、`~/.config/herdr/hws.json`：herdr の画面設定とワークスペース定義
    - `~/.claude/skills/` のほかの skill：会社のリポジトリ由来のものや、アプリ(herdr、Orca)が入れたもの

yabai、skhd、sketchybar の本体は、まだこのリポジトリで管理していない。
現在は Homebrew で手で入れたものが動いており、Nix への移行を準備している。

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
編集しても次の反映で上書きされるので、触らない。

## 日常の操作

以降のコマンドは、リポジトリが `~/Work/Dotfiles` にある前提である。
リンクの張り先がこの場所に固定されているため、別の場所には置けない。

使うコマンドは 2 つである。

- `scripts/switch`：リポジトリの定義をこのマシンに反映する
- `scripts/check`：このマシンが定義どおりに動いているかを確かめる。リポジトリも設定も変更しない

### 設定ファイルを変える

`config/` の中のファイルを直接編集する。
`scripts/switch` は不要である。

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

`modules/`、`hosts/`、`flake.nix`、`flake.lock` を変えたときは、反映する。

```sh
~/Work/Dotfiles/scripts/switch
```

新しく作ったファイルは、実行の前に `git add` しておく。
flake は Git が追跡していないファイルを読まないため、追加しないと「ファイルがない」というエラーになる。

### 確かめる

変更した後と、何かがおかしいときは、確かめる。

```sh
~/Work/Dotfiles/scripts/check
```

次のことを順に確かめる。
出力の各行の先頭には、種類が付く。

- `[OK]`：確かめて、問題がなかった
- `[ERROR]`：問題がある。直し方が一緒に出る
- `[INFO]`：知らせるだけで、直す必要はない

確かめる内容は次のとおりである。

- リポジトリの定義が、このマシンに反映済みであること
- 設定ファイルのリンクが、切れたり別のファイルに置き換わったりしていないこと
- 新しいシェルで、Nix で入れたコマンドと `~/.local/bin` のコマンドが、それぞれの場所のものに解決されること(PATH の順序の誤りを見つける)
- Homebrew に同じコマンドが重複して入っていないこと
- ログインシェルが Nix の fish であること
- 動いているアプリが、消えたシェルを使い続けていないこと
- tmux、git、ghostty の設定に誤りがなく、sketchybar のスクリプトが実行できること
- Nix で入れたフォントがあること
- Homebrew で入れるもの(GUI アプリと Codex)と、公式のインストーラで入れるツール(Claude Code と opencode)が入っていること
- Neovim で種類の違うファイルを開き、全プラグインを読み込み、キー操作(チェックボックスの切り替え、関数の選択)を試しても、エラーが出ないこと

Neovim の確認には 20 秒ほどかかる。
`scripts/check --quick` で省ける。
Neovim の確認は普段の設定で起動するので、まだ取得していないプラグインがあれば、その取得が走る。

`scripts/check` が確かめるのは、定義と実際の食い違いと、起動時に分かる誤りである。
画面の見た目や、キーを押したときの個々の動作までは確かめない。

### CLI ツールを足す、消す

1. パッケージ名を調べる(`nix search nixpkgs <名前>` か https://search.nixos.org/packages)
2. `modules/common.nix` の `home.packages` に足すか、消す。macOS だけで使うものは `modules/darwin.nix` の `home.packages` に書く
3. 反映して、確かめる

### 自分で更新するアプリやツールを足す、消す

GUI アプリと、AI のコーディングツールのように更新の速いツールが当てはまる。
どちらも、反映のときに「入っていなければ入れる」だけで、版は上げない。

Homebrew の cask で入れるもの(macOS)は、`modules/darwin.nix` の `homebrewApps` に書く。

1. 名前、入っているかを確かめる場所、cask の行を足すか、消す。GUI アプリの場所は `appPaths "<名前>.app"` と書く
2. 反映して、確かめる

Homebrew の公式以外の tap から入れるものは、cask の行を `cask "<tap>/<名前>", trusted: true` と書く。
`trusted: true` がないと、Homebrew がその cask を読まない。

公式のインストーラ(`curl ... | bash` の形で配られているもの)で入れるツールは、`modules/common.nix` の `installerTools` に書く。

1. 名前、コマンドが置かれる場所、インストーラの URL を足すか、消す
2. コマンドが置かれる場所が PATH に入っていなければ、`config/fish/common.fish` に足す
3. 反映して、確かめる

既に入っているものは、別の方法で入れたものでも、確かめる場所にあれば入っているとみなして触らない。
ただし、公式のインストーラで入れるツールは、別の方法で入れた同じ名前のコマンドが PATH の手前に残っていると、`scripts/check` が `[ERROR]` にする。古いほうを消す。

一覧から消しても、本体は自動では消えない。
Homebrew で入れたものは `brew uninstall --cask <名前>` で消す。
GUI アプリを Finder で消すと、Homebrew に登録だけが残り、次の反映で入り直らない(そのときは `brew reinstall --cask <名前>` で入れ直す)。

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
4. 確かめる

`config.lib.dotfiles.link` に書くパスを間違えても、反映はエラーにならず、切れたリンクができるだけである。
`scripts/check` はこれを見つける。

### ツールの版を上げる

```sh
cd ~/Work/Dotfiles
nix flake update
scripts/switch
scripts/check
```

`scripts/check` が通ったら、更新された `flake.lock` を単独のコミットにする。
ほかの変更と混ぜないのは、版を上げた結果として何かが壊れたときに、そのコミットだけを戻せるようにするためである。
ほかのマシンは、この `flake.lock` を取り込んで反映すると同じ版になる。

版が上がると、設定がそのままでは動かなくなることがある。
2026 年 11 月には、Neovim が 0.11 から 0.12 に上がって 3 つのプラグインの設定が壊れた。
`scripts/check` の Neovim の確認は、これを反映の直後に見つけるためのものである。

### ほかのマシンの変更を取り込む

別のマシンでコミットした変更を、このマシンに取り込む。

```sh
cd ~/Work/Dotfiles
git status                  # 未コミットの変更があれば、先にコミットする
git pull --ff-only
scripts/switch
scripts/check
```

`config/` だけの変更なら、pull した時点で反映される。
`modules/`、`hosts/`、`flake.nix`、`flake.lock` が変わっていた場合は、反映しないとツールやリンクが古いままになる。
迷ったら反映してよい。定義が変わっていなければ、ツールもリンクも変わらない。

### 元に戻す

基本は Git で戻してから反映する。
設定ファイルの中身も、ツールの版(`flake.lock`)も、リンクの張り方(`modules/`)も、すべて Git で管理しているためである。

```sh
cd ~/Work/Dotfiles
git revert <戻したいコミット>
scripts/switch
```

反映自体が失敗するときだけ、home-manager の世代を直接戻す。
世代は反映のたびに作られる。
一覧を見て、戻したい世代のパスにある `activate` を実行する。

```sh
home-manager generations
# 2026-11-18 22:07 : id 2 -> /nix/store/...-home-manager-generation
/nix/store/...-home-manager-generation/activate
```

世代を戻しても、リポジトリの中身は戻らない。
`config/` のファイルを動かした後なら、戻した世代のリンクが存在しないファイルを指すことがある。
また、次の反映でリポジトリの状態に戻る。
落ち着いたら、Git でも戻してから反映し直す。

### 古い世代を消す

30 日より古い世代と、どこからも使われなくなったパッケージを消して、ディスクを空ける。

```sh
nix-collect-garbage --delete-older-than 30d
```

home-manager の世代と、ツールが入っているプロファイルの世代の両方が対象になる。
消した世代には戻せなくなる。

## 変更の進め方

変更の大きさによって、通す手順を変える。

- 設定の中身(`config/`)だけを変える場合
    1. 編集し、そのアプリで動作を確かめる
    2. `scripts/check` を通す
    3. コミットする
- 仕組み(`modules/`、`hosts/`、`flake.nix`、`flake.lock`、`scripts/`)を変える場合
    1. 作業ブランチを切る
    2. 変更し、`scripts/switch` で反映する
    3. `scripts/check` を通す
    4. 変更した本人とは別の目でレビューする(Claude Code で作業しているなら、Codex のレビューか `/code-review`)
    5. 指摘を直し、もう一度 `scripts/check` を通す
    6. master に統合する

push するのは、`scripts/check` が通った master だけである。
途中の状態を master に入れない。

## 新しいマシンのセットアップ

このリポジトリは非公開なので、clone するのに GitHub へのログインが要る。
どの手順も、パスワードや続行の確認を聞かれる。入力できるターミナルで実行する。

1. macOS では、開発用のコマンドラインツールを入れる(`git` とコンパイラが入る)

```sh
xcode-select --install
```

このコマンドは、インストールの画面を開いてすぐに戻る。
画面のインストールが終わるまで待ち、`git --version` が版を表示することを確かめてから次に進む。

2. このリポジトリを `~/Work/Dotfiles` に clone する

```sh
git clone https://github.com/junchanta/Dotfiles.git ~/Work/Dotfiles
# SSH 鍵を使う場合
git clone git@github.com:junchanta/Dotfiles.git ~/Work/Dotfiles
```

HTTPS の場合は、ユーザー名とパスワードを聞かれる。
パスワードには、GitHub のアカウントのパスワードではなく、個人用のアクセストークンを入力する。

3. トークンも SSH 鍵も用意していない場合は、2 の代わりに、Nix から `gh` を一時的に使って、ブラウザでログインして clone する

```sh
curl -L https://nixos.org/nix/install | sh      # Linux では末尾に -s -- --daemon を付ける
# 新しいターミナルを開いてから
nix --extra-experimental-features 'nix-command flakes' run nixpkgs#gh -- auth login --hostname github.com --git-protocol https --web
nix --extra-experimental-features 'nix-command flakes' run nixpkgs#gh -- repo clone junchanta/Dotfiles ~/Work/Dotfiles
```

4. セットアップを実行する(`<host>` は `hosts/` のファイル名から `.nix` を除いたもの)

```sh
~/Work/Dotfiles/scripts/setup <host>
```

`scripts/setup` は次のことを行う。済んでいるものは飛ばすので、途中で止まったらもう一度実行すればよい。

- Nix がなければ入れる
- このマシンの種類(CPU と OS)が、指定した host の定義と合っているかを確かめる。合っていなければ、何も変えずに止まる
- flake を使えるようにする
- macOS で Homebrew がなければ入れる
- 環境を反映する。既にあるファイルは `.bak` を付けて退避する。GUI アプリ、Codex、Claude Code、opencode も、入っていなければ入る
- ログインシェルを Nix の fish にする(パスワードを聞かれる)
- 最後に `scripts/check --quick` を実行する。足りないものがあれば `[ERROR]` が出て、失敗として終わる

5. 最後に表示される「残りの手作業」を行う
    - ログインシェルを切り替えた場合は、一度ログアウトして入り直す。常駐しているアプリは起動したときのログインシェルを使い続けるので、入り直さないと古いシェルでコマンドを実行しようとして失敗する
    - マシンごとの設定を `~/.config/fish/conf.d/90-local.fish` に書く
    - Claude Code、Codex、opencode などにログインする
    - Cursor の拡張機能を入れる
    - ターミナルで `nvim` を一度起動する。プラグインが取得される。Cursor の中の Neovim はプラグインを取得しないので、Cursor より先にターミナルで起動する
    - node を入れた後に、Neovim で `:Lazy build markdown-preview.nvim` を実行する
6. `scripts/check` を通す

Neovim は、node や Go がまだないマシンでも、エラーなしで起動する。
言語ごとの LSP やフォーマッタは、その言語を入れた後に Neovim を起動すると入る。

macOS の yabai、skhd、sketchybar は、設定ファイルだけが配られ、本体は入らない。
本体を Nix で入れる変更は、準備はできているが、まだ master に入れていない。

確かめてある範囲は次のとおりである。

- `scripts/setup` を、設定済みの Mac で何度実行しても同じ結果になること
- Neovim を、プラグインが何も入っていない状態から、node のない環境で入れ直せること
- ghostty の設定が、新しく入る版(1.4.0)でも通ること

Nix と Homebrew を入れるところからの通しの実行は、まだしていない。
Linux では、まだ何も確かめていない。

Cursor の拡張機能を足したり消したりしたときは、一覧を更新してコミットする。

```sh
cursor --list-extensions > ~/Work/Dotfiles/config/cursor/extensions.txt
```

## マシンを増やす

同じ種類のマシン(たとえば Apple Silicon の Mac をもう 1 台)で、入れるものも同じなら、定義を足す必要はない。
既にある host(`macbook`)をそのまま指定して `scripts/setup` を実行する。
ユーザー名とホームの場所は、定義に書いておらず、実行したマシンの `$USER` と `$HOME` から読み取るためである。

マシンによって入れるものを変えたいとき、または種類の違うマシンを足すときは、host を足す。

1. `hosts/<マシン名>.nix` を作る(`hosts/macbook.nix` を写して、`imports` を直す)
2. `flake.nix` の `hosts` に 1 行足す。値は Apple Silicon の Mac なら `aarch64-darwin`、x86_64 の Linux なら `x86_64-linux` である
3. `git add` してから、そのマシンで `scripts/setup <マシン名>` を実行する

マシン名には実際のホスト名を使わない。
ホスト名に個人名が含まれることがあり、それをリポジトリに書かないためである。

`$USER` と `$HOME` を読み取るために、`nix` と `home-manager` のコマンドには `--impure` を付ける必要がある。
`scripts/` のコマンドは付けているので、手で `nix build` などを実行するときだけ気にすればよい。

## 困ったとき

まず `scripts/check` を実行する。
よくある問題は、`[ERROR]` の行に直し方が出る。

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

`scripts/switch -b bak` で反映すると、普通のファイルは消す代わりに `.bak` を付けて退避される。
ただし、シンボリックリンクは退避されずに止まるので、2 で手で消す。
同じ名前の `.bak` が既にある場合も止まる。

### 反映したのにコマンドが見つからない、古い版が動く

反映する前から開いているシェルは、古い PATH のままである。
新しいシェルを開く。
アプリ(Cursor、ghostty、herdr など)は起動したときの環境を使い続けるので、おかしいときは再起動する。

### 新しく作った .nix ファイルが「存在しない」と言われる

`git add` していない。
flake は Git が追跡しているファイルしか読まない。

### 反映のときに「[WARN] Homebrew が失敗した」「[WARN] … を入れられなかった」と出る

Homebrew か、公式のインストーラが、アプリやツールを入れられなかった。
`scripts/check` で、足りないものを確かめる。
ネットワークにつながっていない場合と、管理者のパスワードが必要な場合がある。
後者は、パスワードを入力できるターミナルから、もう一度 `scripts/switch` を実行する。
