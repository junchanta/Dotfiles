# ドットファイル管理の設計メモ

なぜこの構成にしたのかを後から辿れるように、決めたことと理由を残す。

- 作成: 2026-11-18
- 対象のリポジトリ: この Dotfiles(非公開)

# 背景と目的

- 複数のラップトップで、同じ開発環境を使いたい
    - 現在: macOS が 1 台、Omarchy(Arch Linux ベース)が 1 台
    - 今後: Omarchy をもう 1 台増やす可能性がある
- Neovim は全マシンで同じ設定、同じキーバインドにする
- ツールと設定を、範囲を分けて管理する
    - 全マシン共通
    - macOS だけ
    - Omarchy だけ
- 新しいマシンでは、リポジトリを落としてコマンド 1 つで環境を立ち上げる

# 決定事項と理由

## Nix と home-manager で管理する

- 設定ファイルから環境を組み立て直せるので、マシン間の同期がリポジトリの共有だけで済む
- macOS と Linux の両方で同じ仕組みが使える
- `flake.lock` で全マシンのツールの版が揃う

## Omarchy では NixOS を使わず、Nix と home-manager だけを載せる

- Omarchy は Arch Linux が前提で、NixOS には置き換えられない
- デスクトップ(Hyprland、テーマ、GUI アプリ)は Omarchy に任せる
- Nix は、マシンをまたいで共有したい部分(CLI ツールと設定ファイル)だけを受け持つ

## macOS のシステム設定(nix-darwin)は後回しにする

- まず home-manager だけで CLI ツールと設定ファイルを移す
- nix-darwin は、GUI アプリを Homebrew cask で宣言する段階で足す

## 範囲(modules)とマシン(hosts)を分ける

- `modules/` に範囲ごとの設定を書き、`hosts/` の各マシンが必要な範囲を選ぶ
- マシンを増やすときは `hosts/` に 1 ファイル足すだけで済む
- マシン名は `macbook` のような短い別名にする
    - 実際のホスト名には本名が含まれるため、リポジトリに書かない

## 設定ファイルの実体は `config/` に普通のファイルとして置く

- Nix の記述に書き直さず、元の形式のまま置いてリンクを張る
- アプリからの変更がそのままリポジトリに反映される
- Nix を使わない環境でも、手でリンクを張れば使える

## CLI ツールは開発の土台だけに絞る

- クラウド系や言語別の道具は、必要なマシンで都度入れる
- 認証情報はリポジトリに入れない

## Neovim の LSP とフォーマッタは mason のままにする

- 現在の構成がそのまま全マシンで動く
- Nix に移すと nvim の設定の書き換えが必要になり、得るものが少ない

## fish の設定は 3 層に分ける

- 層
    - 共通: `config/fish/common.fish`
        - エイリアス、Nix で入れたツールの PATH、エディタの指定
    - OS 別: `config/fish/darwin.fish`
        - Homebrew の初期化
    - マシン別: `~/.config/fish/conf.d/90-local.fish`
        - リポジトリの管理外
        - 言語別の道具の PATH など、そのマシンにしかないもの
- 理由
    - 言語別の道具はマシンごとに入れるものが違うので、共通の設定に混ぜない
    - インストーラが勝手に追記する設定も、マシン別の側に寄せられる
- 仕組み
    - `~/.config/fish` 自体は普通のフォルダのままにし、`conf.d` に個別のファイルをリンクする
    - `conf.d` は名前順に読まれるので、`10-`(OS 別)、`20-`(共通)、`90-`(マシン別)の順になる
    - PATH の優先順位は、マシン別 → Nix → Homebrew の順になる
        - マシン別の設定で入れたツールは、Nix の同名のものより優先される
- 自作の関数
    - 共有するもの: `config/fish/functions/` に置く
    - そのマシンだけのもの: `~/.config/fish/functions/` に置く(管理外)
    - 2026-11-18 時点で共有する関数はない。既存の関数はすべてマシン別として残した
- プラグイン
    - fisher をやめ、home-manager に入れさせる(新しいマシンで手作業を残さないため)
    - 対象は z とテーマ(theme-batman)

# ディレクトリ構成

```
flake.nix
flake.lock
hosts/       マシンごと。使う modules を選ぶ
modules/     範囲ごと。入れるツールと、config/ のどれをどこに配るか
config/      設定ファイルの実体。アプリ名で並べる
docs/history/  設計の経緯。このメモもここに置く
```

- `modules/` の中身
    - `common.nix`: 全マシン共通
    - `darwin.nix`: macOS だけ
    - `omarchy.nix`: Omarchy だけ
- 現状(2026-11-18)
    - `flake.nix`、`hosts/macbook.nix`、`modules/common.nix`、`modules/darwin.nix` を作成した
    - `config/` に移行済み
        - fish、nvim、tmux、git、ghostty、Cursor、herdr
        - yabai、skhd、sketchybar(macOS だけ)

# 管理対象

`$HOME/.config` 配下が中心である。

## 共通(全マシン)

- neovim
    - OS 別の分割: 不要
    - Omarchy 標準の nvim 設定を置き換える
    - Omarchy のテーマ連動は効かなくなる

- tmux
    - OS 別の分割: 不要

- fish
    - OS 別の分割: 一部必要
    - 共通、OS 別、マシン別の 3 層に分ける(「決定事項と理由」を参照)

- ghostty
    - OS 別の分割: 一部必要
    - 共通: `ctrl+g` を prefix にしたキーバインド、余白、`term`
    - OS 別: テーマ、フォント、ウィンドウの見た目、`super`(Cmd)を使うキーバインド
        - テーマとフォントは Omarchy が自分で管理するので、共通に入れると Omarchy の切り替えが効かなくなる
        - `super` は Omarchy ではウィンドウ操作に使われる
    - 共通ファイルの末尾の `config-file = ?local.conf` で OS 別ファイルを読み込む
    - macOS では設定が 2 か所(`~/.config/ghostty` と `~/Library/Application Support/com.mitchellh.ghostty`)にあり、両方が読まれていた
        - 2026-11-18 に、実際に効いていた値を基準に 1 つへ統合した
        - `Application Support` 側のファイルは `config.bak` に退避した

- herdr
    - OS 別の分割: 不要
    - Linux でも動く(herdr の設定の説明に Omarchy 向けの記述がある)
    - 設定フォルダにログやセッションが混在しているので、フォルダごとではなく `config.toml` だけを管理する
    - 管理しないもの
        - `config-gpui.toml`: herdr が起動のたびに上書きする
        - `config-gpui.local.toml`: 画面のテーマやレイアウトの上書き。テーマは Omarchy では Omarchy に追従させたいので、マシンごとに持つ
        - `hws.json`: 仕事用のワークスペース定義。`hws` 関数と同じくマシン別とする
        - `plugins.json`、`plugins/`: 入れたプラグインの状態とビルド結果。絶対パスを含む

- git
    - OS 別の分割: 不要
    - 対象は `~/.gitconfig` と `~/.config/git/ignore`

- Cursor
    - OS 別の分割: 不要(1 ファイルで可)
    - 対象は `keybindings.json` と `settings.json`
    - 置き場所は OS で違うが、中身は共有できる
    - `cmd` を使うキーバインドは 8 個ある
        - 7 個は、macOS の既定のキーを無効にする行である。Linux では既定のキーが `ctrl` なので、何もしない行になる
        - 残る 1 個は `cmd+i`(エージェントを開く)
        - Linux 用の行は、Omarchy で実際に Cursor を動かして、困ったものだけ足す
    - `settings.json` に、nvim の設定の場所を Linux でも指す行を 1 行足した(vscode-neovim 用)
    - 拡張機能は `config/cursor/extensions.txt` に ID の一覧を置く
        - 入れ直すとき: `cat config/cursor/extensions.txt | xargs -L1 cursor --install-extension`
        - 一覧の更新: `cursor --list-extensions > config/cursor/extensions.txt`

- CLI ツール
    - OS 別の分割: 不要
    - Nix で入れる
    - 開発の土台になるものだけに絞る
    - 基本
        - eza
        - bat
        - tree
        - wget
        - ripgrep
        - fzf
        - jq
        - direnv
    - Git
        - git
        - gh
        - lazygit
    - エディタ、ターミナル
        - neovim
        - tmux
        - fish
    - neovim が使うもの
        - luarocks
        - lua-language-server
        - shfmt
        - そのほかの LSP とフォーマッタは、今と同じく mason に任せる
    - 入れないもの(必要なマシンで都度入れる)
        - awscli などのクラウド系
        - anyenv、pyenv、tfenv、rustup、uv などの言語別の道具
        - node
            - mason と一部の nvim プラグインが必要とするので、各マシンに何らかの形で入っている必要がある
            - 版がプロジェクトごとに違うので、共通には含めず、マシン別に入れる
        - postgresql、docker-compose
        - nuclei、grpcurl、graphviz
    - 認証情報は管理しない(gh の `hosts.yml` など)

## macOS だけ

- sketchybar
- yabai(`~/.yabairc`)
- skhd(`~/.skhdrc`)
- GUI アプリ、フォント(nix-darwin 経由の Homebrew cask)

## Omarchy だけ

- Hyprland まわりの自分用カスタマイズ(リーダーキーなど)
- GUI アプリは pacman(Omarchy)に任せ、Nix では入れない

## 削除したもの(2026-11-18)

- `.vimrc` 系
    - `~/.vimrc` が存在せず、読まれていなかった
- `fish/`
    - 2023 年 6 月で更新が止まっており、現役の `~/.config/fish` とは別物だった
- `old/`
    - dein 時代の nvim 設定の退避で、どこからも参照されていなかった
- いずれも Git の履歴から取り出せる

# 考慮点

## OS 別に分けるかの原則

- 中身が同じ: 1 ファイルを全マシンに配る
- 違いが数行: 共通ファイルから OS 別ファイルを読み込む
- 丸ごと別物: OS ごとにファイルを持つ

## 置き場所が OS で違うもの

- 例: Cursor
- ファイルは分けない
- Nix 側で配置先だけを切り替える

## アプリが書き換えるファイル

- 例
    - nvim の `lazy-lock.json`
    - Cursor の設定
    - fish の `fish_variables`
- 読み取り専用にしない
- リポジトリへ直接リンクを張る(`mkOutOfStoreSymlink`)

## Omarchy が所有するファイル

- 対象: Hyprland、Waybar、テーマ関連
- Omarchy の更新で書き換わる
- Nix の管理から外すか、書き込み可能なリンクにする

## 管理しないもの

- ログ、ソケット、セッション、キャッシュ
- ログイン状態
- 秘密情報(トークンなど)

## マシンの追加

- 範囲別のモジュール(共通、macOS、Linux、Omarchy)を組み合わせる構成にする
- 新しいマシンは 1 ファイル足すだけにする

# 新しいマシンのセットアップ

1. Nix を入れる
    - `sh <(curl -L https://nixos.org/nix/install)`
2. flake を有効にする
    - `mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf`
3. このリポジトリを `~/Work/Dotfiles` に clone する
4. 環境を適用する(`<host>` は `hosts/` のファイル名)
    - `nix run home-manager -- switch --flake ~/Work/Dotfiles#<host> -b bak`
    - 既存のファイルは `.bak` を付けて退避される
5. ログインシェルを Nix の fish にする(sudo のパスワードを聞かれる)
    - `echo ~/.nix-profile/bin/fish | sudo tee -a /etc/shells`
    - `chsh -s ~/.nix-profile/bin/fish`
6. 必要なら、マシン別の設定を `~/.config/fish/conf.d/90-local.fish` に書く
7. Cursor の拡張機能を入れる
    - `cat ~/Work/Dotfiles/config/cursor/extensions.txt | xargs -L1 cursor --install-extension`

# 未決定

- なし(2026-11-18 時点)

