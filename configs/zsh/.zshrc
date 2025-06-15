declare -xA ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME}/zinit"
ZINIT[ZCOMPDUMP_PATH]="${XDG_STATE_HOME}/zcompdump"
source "${ZINIT[HOME_DIR]}/bin/zinit.zsh"

zinit light-mode depth'1' for \
    @'romkatv/powerlevel10k'

_atinit_environment() {
    zstyle ':prezto:*:*' color 'yes'
    zstyle ':prezto:environment:termcap' color 'yes'
}
_atinit_history() {
    zstyle ':prezto:module:history' histfile "${XDG_STATE_HOME:-ZDOTDIR}/zsh_history"
    zstyle ':prezto:module:history' histsize 10000
    zstyle ':prezto:module:history' savehist 10000
}
_atinit_utility() {
    zstyle ':prezto:module:utility:ls' dirs-first 'no'
}

zinit is-snippet for \
    atinit'_atinit_environment' PZTM::environment \
    atinit'_atinit_history' PZTM::history \
    PZTM::directory \
    PZTM::spectrum \
    PZTM::gnu-utility \
    atinit'_atinit_utility' PZTM::utility

zinit wait lucid blockf light-mode for \
    @'zdharma-continuum/fast-syntax-highlighting' \
    @'zsh-users/zsh-history-substring-search' \
    @'zsh-users/zsh-autosuggestions' \
    @'zsh-users/zsh-completions'

[[ ! -s "${ZDOTDIR:-$HOME}/conf.d/p10k.zsh" ]] || source "${ZDOTDIR:-$HOME}/conf.d/p10k.zsh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"

## Vim
export VIMINIT="set nocp | source ${XDG_CONFIG_HOME:-$HOME/.config}/vim/.vimrc"

## mise
eval "$(mise activate zsh)"

# Node.js
export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node_history"

## npm
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"

## Python
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/startup.py"

## RDBMS
export SQLITE_HISTORY="${XDG_STATE_HOME}/sqlite_history"
export MYSQL_HISTFILE="${XDG_STATE_HOME}/mysql_history"
export PSQL_HISTORY="${XDG_STATE_HOME}/psql_history"

## Ruby
export BUNDLE_USER_HOME="${XDG_CONFIG_HOME}/bundle"
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle"
export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME}/bundle"

## Bat
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/config"

fpath=(
    "${XDG_DATA_HOME}/zinit/completions"(N-/)
    "$(brew --prefix)/share/zsh/site-functions"(N-/)
    "$fpath[@]"
)

alias eza='eza --icons'
alias l='eza -1A'
alias ll='eza -lh'
alias lr='ll -T'
alias la='ll -A'
alias lk='ll --sort=size'
alias lt='ll --sort=modified'
alias lc='lt --changed'
alias lu='lt -u'
alias tree='eza -T'

zpcompinit

source "${ZDOTDIR:-$HOME}/conf.d/completions.zsh"
source "${ZDOTDIR:-$HOME}/conf.d/fzf.zsh"
source "${ZDOTDIR:-$HOME}/conf.d/tmux.zsh"
source "${ZDOTDIR:-$HOME}/conf.d/utils.zsh"

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-insert true
zstyle ':chpwd:*' recent-dirs-file "${XDG_STATE_HOME}/chpwd-recent-dirs"
zstyle ':completion:*' recent-dirs-insert both

if [ -f "${ZDOTDIR}/.zshrc.local" ]; then
    source "${ZDOTDIR}/.zshrc.local"
fi
