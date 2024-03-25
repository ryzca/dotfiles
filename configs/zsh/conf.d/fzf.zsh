#!/bin/zsh

export FZF_DEFAULT_OPTS="
    --reverse
    --height=90%
    --border
    --no-mouse
    --filepath-word
    --prompt='$(echo "\uE68F") '
    --pointer='$(echo "\uF00c")'
    --marker='$(echo "\uF00c")'
    --color fg:248,fg+:white,bg:-1,bg+:-1,hl:red,hl+:red
    --color preview-fg:white
    --color gutter:-1,prompt:blue,info:yellow,pointer:red,marker:green
"

export FZF_DEFAULT_COMMAND='fd --type file'

function _fzf_cdr() {
    target_dir="$(cdr -l | awk '{ print $2 }' | fzf --preview 'f() { sh -c "eza -1A --color=always $1" }; f {}')"
    target_dir="$(echo ${target_dir/\~/${HOME}})"
    if [[ -n "${target_dir}" ]]; then
        cd "${target_dir}"
    fi
}

function _fzf_branch() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" | fzf --no-multi --ansi --preview='git --no-pager log -100 --graph --oneline --decorate=full --color=always {}') &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

function _fzf_history() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

function _fzf_cd() {
  local dir
  dir=$(fd --type d 2> /dev/null | fzf +m --preview 'f() { sh -c "eza -1A --color=always $1" }; f {}') && cd "$dir"
}

function _ghq_fzf () {
    local repo="$(ghq list | fzf --query="$LBUFFER" --preview 'full_path=$(ghq list --full-path --exact {}); echo ${full_path}; eza ${full_path}')"
    if [[ -n "${repo}" ]]; then
        repo="$(ghq list --full-path --exact ${repo})"
        BUFFER="cd ${repo}"
        zle accept-line
    fi
    zle clear-screen
}


alias fcdr="_fzf_cdr"
alias fbr="_fzf_branch"
alias fh="_fzf_history"
alias fcd="_fzf_cd"

zle -N _ghq_fzf
bindkey '^]' _ghq_fzf
