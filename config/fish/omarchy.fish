# Omarchy だけの fish 設定

# Omarchy は、Claude Code、Codex、node などを mise で入れる(/etc/mise/conf.d/omarchy-tools.toml)。
# bash では /usr/share/omarchy/default/bash/env-bootstrap が PATH を通すが、fish はそれを読まない。
# デスクトップから開いた fish は PATH を引き継ぐので困らないが、SSH で入った fish でも使えるように、ここでも通す
set -q OMARCHY_PATH; or set -gx OMARCHY_PATH /usr/share/omarchy
set -l mise_data $HOME/.local/share/mise
set -q XDG_DATA_HOME; and set mise_data $XDG_DATA_HOME/mise
set -q MISE_DATA_DIR; and set mise_data $MISE_DATA_DIR
fish_add_path --path $mise_data/command-wrappers/bin
fish_add_path --path --append $mise_data/shims

# bat の配色を、ターミナルの配色(Omarchy のテーマ)に合わせる
set -gx BAT_THEME ansi

# mise を fish で有効化しない。
# mise のパッケージは /usr/share/fish/vendor_conf.d/mise-activate.fish で自分を有効化し、
# 入れた道具(gh など)とその代理のコマンド(shims)を、プロンプトのたびに PATH の先頭へ置く。
# そうなると、Nix で入れた gh より mise の gh が先に使われる。
# 有効化しなくても、mise の道具は上で通した shims から使える。プロジェクトごとの版の切り替えも shims が行う。
# このファイルは mise-activate.fish より先に読まれる(conf.d は名前順)ので、ここで指定すれば間に合う
set -gx MISE_FISH_AUTO_ACTIVATE 0
