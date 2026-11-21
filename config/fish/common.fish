# 全マシン共通の fish 設定
# マシンごとの設定(言語別の道具の PATH など)はここに書かず、
# ~/.config/fish/conf.d/90-local.fish に書く(リポジトリの管理外)

# Nix で入れたツールを PATH の先頭に置く(Homebrew などの同名ツールより優先する)
fish_add_path --path --move $HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin
fish_add_path --path $HOME/.local/bin
# opencode の公式インストーラが置く場所
fish_add_path --path $HOME/.opencode/bin

# 共有する自作関数は、このファイルの実体と同じ場所の functions/ に置く
set -l here (path dirname (path resolve (status filename)))
if test -d $here/functions
    set -p fish_function_path $here/functions
end

# editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# alias
alias g 'git'
alias v 'nvim'
alias clc 'claude'
alias clca 'claude --permission-mode auto'
alias clcd 'claude --dangerously-skip-permissions'
alias opc 'opencode'
alias gemi 'gemini'
alias tf 'terraform'

# eza
if command -v eza >/dev/null 2>&1
    alias ls 'eza --icons --git'
    alias la 'eza -T -L 1 -a -l --icons'
    alias lt 'eza -T -L 3 -a --icons'
    alias lta 'eza -T -L 3 -a -l --icons'
end

# bat
if command -v bat >/dev/null 2>&1
    alias cat 'bat'
end

# direnv
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
end
