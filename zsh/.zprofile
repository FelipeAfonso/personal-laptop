# Login shells read this file. ZDOTDIR hides ~/.zprofile, where the Homebrew
# installer puts its PATH setup, so it has to live here. Ghostty starts tmux
# from a non-interactive login shell, which never reads .zshrc.
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
