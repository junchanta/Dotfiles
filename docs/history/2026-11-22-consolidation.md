# 管理の一本化と、検証の仕組み

2026-11-22 時点の決定を残す。
2026-11-18 の移行([2026-11-18-nix-migration.md](2026-11-18-nix-migration.md))の続きである。

# 背景

- 11-18 の移行の後、使って初めて気づく不具合が続いた
    - Neovim が 0.11 から 0.12 に上がり、プラグインの設定が 3 つ壊れた
        - nvim-lspconfig の `LspStart` がなくなった
        - nvim-treesitter の master ブランチが 0.12 に対応していなかった
        - markdown-togglecheck が、新しい nvim-treesitter から消えた関数に依存していた
    - fish の設定を分けたときに PATH の順序が変わり、`claude` が別のものに解決された
    - Homebrew の fish を消した後も、常駐していた skhd と herdr が古いシェルを使い続けた
- 原因は共通している
    - 版が変わることを、変更として扱っていなかった
    - 確認が、実際の使い方の経路を通っていなかった(ファイルを開かずに Neovim を起動しただけ、など)
    - 反映した後に全体を確かめる手段がなかった
- 「Nix で管理するのか、Homebrew で管理するのか」が、提案のたびに揺れた

# 決定事項と理由

## 入れる手段を 1 つの方針にする

- 何を入れるかは、すべてこのリポジトリに書く
- 手段は Nix を基本にする
- macOS の GUI アプリだけは Homebrew の cask にする
    - アプリ自身が更新するので、Nix で版を固定すると食い違う
    - cask の一覧は `modules/darwin.nix` に書き、反映のときに足りないものを入れる
- 言語の実行環境は管理しない(11-18 の決定のまま)

## nix-darwin を使わない

- 11-18 のメモでは「GUI アプリを Homebrew cask で宣言する段階で足す」としていた。これを取り消す
- 理由
    - nix-darwin の反映には毎回 sudo が要る。日常の変更のたびにパスワードが要り、Claude Code からも反映できない
    - macOS だけ反映のコマンドが別になる
    - 必要だったのは cask の一覧を宣言することだけで、home-manager の反映の中で `brew bundle` を呼べば足りる
- 結果
    - macOS でも Linux でも、反映は `scripts/switch`(home-manager)だけになる

## GUI アプリの入れ方

- `modules/darwin.nix` に、アプリの名前と cask の行の組を書く
- 反映のときに、`/Applications` にないアプリだけを `brew bundle install --no-upgrade` で入れる
    - 失敗しても反映は止めず、警告を出す。足りないものは `scripts/check` が `[ERROR]` で示す
- 「入っているか」は、Homebrew に登録されているかではなく、`/Applications` にあるかで決める
    - 最初は Homebrew への登録で判定し、手で入れてあった Cursor を登録しようとした
    - 登録にはアプリの中身の書き換えが要り、macOS が動いているアプリの書き換えを管理者にも許さなかった
    - 目的は「アプリが入っていること」なので、入れ方を問わない判定に改めた
- Homebrew 7 は、公式以外の tap のものを既定で読まない
    - Brewfile の該当行に `trusted: true` を付けると、その cask だけが信頼される
- 対象は、管理している設定が前提にするアプリに絞った
    - ghostty、Cursor、herdr のアプリ版
    - ほかの cask は管理せず、消しもしない

## フォントを Nix で入れる

- sketchybar の設定が JetBrainsMono Nerd Font を前提にしている
- home-manager が `~/Library/Fonts/HomeManager` に入れる
- Homebrew の同じフォントは消した

## 検証を scripts/check に固める

- 反映した後に、このマシンが定義どおりに動いているかを 1 コマンドで確かめる
- 上の「背景」の不具合を、それぞれ検出できるように項目を決めた
    - 版が上がって設定が壊れる → Neovim で種類の違うファイルを開き、全プラグインを読み込む
    - PATH の順序が変わる → 新しいログインシェルで、Nix で入れたコマンドの解決先を調べる
    - リンクが切れる、置き換わる → 管理している全ファイルの行き先を調べる
- わざと不具合を入れて、検出することを確かめた
    - `LspStart` の呼び出しを戻す → Neovim の項目が `[ERROR]` になった
    - 管理しているリンクを普通のファイルに置き換える → リンクの項目が `[ERROR]` になった
- 初回の実行で、以前からあった不具合を 2 つ見つけて直した
    - nvim-dap に存在しない `setup()` を呼んでいた
    - nvim-dap-ui に必要な nvim-nio が入っていなかった

## 変更の進め方を決める

- 仕組みの変更は、作業ブランチ、`scripts/check`、別の目によるレビューを通してから master に入れる
- push するのは `scripts/check` が通った master だけにする
- 版を上げる変更は単独のコミットにする
- 手順は README の「変更の進め方」が正である

## 運用のコマンドを 3 つにまとめる

- `scripts/setup <host>`：新しいマシンのセットアップ
- `scripts/switch`：反映
- `scripts/check`：確認
- マシンの名前は、反映のときに `~/.config/dotfiles/host` に書かれる。`switch` と `check` はこれを読むので、名前を毎回指定しなくてよい

# 残っていること

- yabai、skhd、sketchybar の本体を Nix で入れる
    - 切り替えると macOS のアクセシビリティの許可をやり直す必要があるので、手元で操作できるときに行う
- ghostty の設定が指定している Fira Code は、この Mac に入っていない
    - 今は ghostty の内蔵フォントで表示されている。入れるか、指定を消すかを決める
- `scripts/setup` は、まっさらなマシンではまだ実行していない
- Linux(Omarchy)では何も検証していない
