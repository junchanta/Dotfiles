---
name: dotfiles
description: このマシンの開発環境の設定（fish、nvim、tmux、git、ghostty、Cursor、herdr、yabai、skhd、sketchybar、Claude Code の CLAUDE.md と共有 skill）や、Nix で入れる CLI ツールを変更するときに使う。~/Work/Dotfiles（Nix + home-manager）を編集し、反映、確認、コミットまでを同じ手順で行う。「tmux のキーを変えて」「fish にエイリアスを足して」「〇〇を入れて」「この設定を dotfiles で管理して」「ghostty の設定を直して」「dotfiles を更新して」「/dotfiles」と言われた場合に、どのディレクトリで作業中でも使う。言語の実行環境（node、python など）や GUI アプリは対象外（各マシンで個別に入れる）。
---

# dotfiles を変更する

設定とツールは `~/Work/Dotfiles` で管理している。
ホームにある設定ファイルの多くはリポジトリへのリンクなので、ホーム側を直接書き換えず、必ずリポジトリ側を編集する。

## 最初に読むもの

`~/Work/Dotfiles/README.md` を読む。
仕組み、何がどこで管理されているか、各操作の手順は README が正であり、この skill は作業の進め方だけを定める。
README と食い違ったら README に従う。

## 進め方

1. **置き場所を決める。** README の「何がどこで管理されているか」に従う。
    - 全マシン共通：`config/` と `modules/common.nix`
    - macOS だけ：`modules/darwin.nix`
    - そのマシンだけ（言語別の道具の PATH など）：リポジトリには入れず、`~/.config/fish/conf.d/90-local.fish` などに書く。この場合は 4 以降を行わない
2. **作業前の状態を確かめる。** `git -C ~/Work/Dotfiles status` で未コミットの変更を確認する。自分の作業と関係ない変更があれば、混ぜずにユーザーに伝える。
3. **編集する。**
    - 設定の中身：`config/<アプリ名>/` のファイル
    - ツールの追加・削除、新しい設定ファイルの管理：`modules/*.nix`
    - 生成ファイル（`~/.config/fish/config.fish` など）は編集しない
4. **新しいファイルを `git add` する。** flake は Git が追跡していないファイルを読まない。
5. **反映する。** `config/` の中身だけの変更なら不要で、アプリの読み直しだけ伝える（README の「設定ファイルを変える」）。`modules/`、`hosts/`、`flake.nix`、`flake.lock` を変えたときは、先にビルドで誤りを確かめてから反映する。

    ```sh
    cd ~/Work/Dotfiles
    nix build .#homeConfigurations.<host>.activationPackage --no-link
    home-manager switch --flake ~/Work/Dotfiles#<host>
    ```

    `<host>` は `hosts/` のファイル名のうち、このマシンのものである。
    `hosts/` にこのマシンらしいものが 1 つに決まらないときは、ユーザーに聞く。
    「Existing file ... is in the way」で止まったら、README の「困ったとき」に従う。
    `-b bak` は、退避されるファイルが skill のディレクトリなど、残ると害があるものでないことを確かめてから使う。
6. **確かめる。**
    - リンクを足した場合：`path resolve <配置先>` が `~/Work/Dotfiles/config/` の中を指し、`test -e <配置先>` が成り立つこと
    - ツールを足した場合：新しいシェルで `type -p <コマンド>` が `~/.nix-profile/bin` を指すこと
    - 設定の中身を変えた場合：そのアプリが設定を読めること（例：`tmux source-file ~/.tmux.conf`、`ghostty +validate-config`、`nvim --headless +qa`）
7. **コミットする。** 1 つの目的ごとに 1 コミットにし、メッセージは日本語で「何を、なぜ」を書く。push はユーザーに頼まれたときだけ行う。
8. **報告する。** 何を変えたか、反映済みか、ユーザーがすること（アプリの再起動、新しいシェルを開くなど）を数行で伝える。

## やらないこと

- ホーム側のリンク先を直接編集したり、リンクを普通のファイルで置き換えたりしない
- 認証情報（トークン、`gh` の `hosts.yml` など）をリポジトリに入れない
- 会社のリポジトリ由来の skill や、アプリ（herdr、Orca など）が入れた skill を dotfiles に取り込まない
- `nix flake update` は、ユーザーが版の更新を頼んだときだけ行う
