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
    --color preview-fg:white,preview-scrollbar:yellow
    --color gutter:-1,prompt:blue,info:yellow,pointer:red,marker:green
"

export FZF_DEFAULT_COMMAND='fd --type file'

function _fzf_cdr() {
  target_dir="$(cdr -l | awk '{ print $2 }' | fzf --preview 'f() { sh -c "eza --icons --tree --level=2 --color=always $1" }; f {}')"
  target_dir="$(echo ${target_dir/\~/${HOME}})"
  if [[ -n "${target_dir}" ]]; then
    cd "${target_dir}"
  fi
}

function _fzf_branch() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "${branches}" | fzf --no-multi --ansi --preview='git --no-pager log -100 --graph --oneline --decorate=full --color=always {}') &&
  git checkout $(echo "${branch}" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

function _fzf_history() {
  print -z $( ([ -n "${ZSH_NAME}" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

function _fzf_cd() {
  local dir
  dir=$(fd --type d 2> /dev/null | fzf +m --preview 'f() { sh -c "eza --icons --tree --level=2 --color=always $1" }; f {}') && cd "${dir}"
}

function _fzf_ghq() {
  local repo="$(ghq list | fzf --query="${LBUFFER}" --preview 'p="$(ghq list --full-path --exact {})";
    [ -f "${p}/README.md" ] && bat --style=grid,header --color=always "${p}/README.md" || eza --icons --tree --level=2 --color=always "${p}"')"
  if [[ -n "${repo}" ]]; then
    repo="$(ghq list --full-path --exact ${repo})"
    BUFFER="cd ${repo}"
    zle accept-line
  fi
  zle clear-screen
}

function _fzf_git_worktree() {
  local selected full_path
  selected=$(git worktree list | awk '{
    branch = $NF
    gsub(/[\[\]]/, "", branch)
    print branch " " $0
  }' | fzf --with-nth=1 --preview 'echo {} | awk "{print \$2}" | xargs -I path sh -c "cd path && git log --oneline --graph --decorate --color=always -10"')
  if [[ -n "${selected}" ]]; then
    full_path=$(echo "${selected}" | awk '{print $2}')
    BUFFER="cd ${full_path}"
    zle accept-line
  fi
  zle clear-screen
}

alias fcr="_fzf_cdr"
alias fbr="_fzf_branch"
alias fh="_fzf_history"
alias fcd="_fzf_cd"
alias fwt="_fzf_git_worktree"

zle -N _fzf_ghq
bindkey '^]' _fzf_ghq

zle -N _fzf_git_worktree
bindkey '^W' _fzf_git_worktree
