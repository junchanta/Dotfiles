---
name: nvim-key
description: この環境の Neovim で「○○したいけどキーが思い出せない」を自然言語で引く。cheatsheet.txt・実際の設定（~/.config/nvim）・lazy.nvim が入れたプラグインの既定キーを横断して調べ、実打鍵で答える。逆に「このキーは何か」も引ける。Neovim の操作・キーマップ・プラグインの使い方を聞かれたときに使う。
---

# Neovim のキーを自然言語で引く

「ステージしたい」「コミットの中身を見たい」「タブを移りたい」のような曖昧な問いから、この環境で**実際に効くキー**を答える。一般的な Vim の知識ではなく、必ず手元の設定を根拠にする。

## 前提

- 設定の実体は `~/Work/Dotfiles/config/nvim`。`~/.config/nvim` はそこへの symlink。
- プラグインの実体は `~/.local/share/nvim/lazy/<plugin>/`。
- **leader は Space**（`lua/keymaps.lua:12`）。`<leader>gg` ではなく「`Space g g`」と実打鍵で答える。
- **tmux の prefix が `C-t`**（`~/.tmux.conf:7`）。`<C-t>` 系は Neovim に届かないので候補に出さない。
- 設定の置き場所は `lua/plugins/` 配下で、`core/`（LSP・treesitter・補完）、`tools/`（git・terminal・ai・markdown・memo・debugger）、`navigation/`（telescope・flash・filer・yanky）、`ui/`、`lang/` に分かれている。

## 調べる順序

1. **`~/.config/nvim/cheatsheet.txt`** を引く。`## セクション @タグ` と `説明 | キー` の形式で、日本語の説明が付いているので自然言語からの当たりを付けやすい。ここで見つかれば最短。
2. **実際の設定で裏を取る。** `lua/**/*.lua` を `keys = {`、`vim.keymap.set`、`mappings`、`map(` で grep する。cheatsheet は手書きなので設定より古いことがある。**食い違ったら設定が正**。
3. **プラグイン内部の既定キー**は cheatsheet にも設定にも書かれていないことが多い（Neogit の `s` / `u` / `?`、diffview の `g?` など）。`~/.local/share/nvim/lazy/<plugin>/` の `config.lua` や `keymaps` を読む。lazy.nvim の spec で上書きしている場合は上書きが優先されるので、両方を突き合わせる。
4. どうしても無ければ「無い」と答える。似た標準機能があれば示し、割り当てるならどのファイルに何を書くかを提示する（勝手に書き込まない）。

逆引き（「`gzr` って何」）も同じ順序で、キーから説明を引く。

## 答え方

- **候補は 3 つまで。**最有力を先頭に置く。網羅は要らない。
- 各候補は 1 行で「**実打鍵** — 何が起きるか（どこで効くか）」。どこで効くかは「通常のバッファで」「Neogit の status 内で」のように、モードやバッファを明示する。
- 根拠として設定の位置を `file:line` で添える。すぐ直せるようにするため。
- 手順が要るものだけ、2〜3 行で流れを書く（例：`Space g g` → `Recent Commits` で `Tab` → コミットの上で `Enter`）。
- 打鍵の表記は `Space g h s`、`Ctrl-r g`、`Shift-Tab` のように、そのまま押せる形で書く。`<leader>` や `<C-r>` の記法は使わない。

## 例

**問い**「hunk をステージしたい」

```
- Space g h s  — カーソル下の hunk をステージ（通常のバッファで。gitsigns）
    lua/plugins/tools/git.lua:24
- s            — Neogit の status でファイルまたは hunk をステージ
    Space g g で開く。hunk 単位なら Tab で展開してから
- Ctrl-s       — Neogit の status で全部ステージ
```

**問い**「コミットの中身を見たい」

```
- Space g g → Recent Commits で Tab → コミットの上で Enter
    commit view がタブで開き、メタ情報・メッセージ・全ファイルの差分が出る
- :DiffviewOpen <sha>^!  — そのコミット 1 個を差分 UI で開く（左右比較）
- Space g F  — リポジトリ全体の履歴を diffview で辿る
```

## cheatsheet.txt の扱い

調べた結果が `cheatsheet.txt` に載っていなかった場合は、答えの末尾に**追記案を 1 行だけ**示す。

```
cheatsheet.txt に足すなら（## Git (neogit) @git @neogit の節）:
  コミットの中身を見る | <CR> (Recent Commits内)
```

実際に書き込むのはユーザーが求めたときだけ。書き込む場合は既存の節と形式（`説明 | キー`、節見出しの `@タグ`）を崩さない。

## やらないこと

- 設定を勝手に変更しない。キーの追加・変更は提案に留め、依頼されてから行う。
- 手元の設定で確認していない一般論の Vim キーを、この環境のキーであるかのように答えない。確認していない場合はそう言う。
