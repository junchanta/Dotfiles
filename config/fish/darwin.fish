# macOS だけの fish 設定

# Homebrew
if status is-interactive; and test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end
