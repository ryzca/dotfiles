() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
    newline
    prompt_char
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    time
    newline
  )
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=

  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=112
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=173
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true

  typeset -g POWERLEVEL9K_DIR_FOREGROUND=111
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=105
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=111
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .bzr
    .citc
    .git
    .hg
    .node-version
    .python-version
    .go-version
    .ruby-version
    .lua-version
    .java-version
    .perl-version
    .php-version
    .tool-version
    .shorten_folder_marker
    .svn
    .terraform
    CVS
    Cargo.toml
    composer.json
    go.mod
    package.json
    stack.yaml
  )
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=true

  typeset -g POWERLEVEL9K_DIR_CLASSES=(
      '/etc|/etc/*'                 ETC             '\uF013'
      '~/dev*'                      DEV             '\uE20F'
      '~/Documents*'                DOCUMENTS       '\uF02D'
      '~/Pictures*'                 PICTURES        '\uF03E'
      '~/Music*'                    MUSIC           '\uFC58'
      '~/Movies*'                   MOVIES          '\uF03D'
      '~/Desktop*'                  DESKTOP         '\uF108'
      '~/Downloads*'                DOWNLOADS       '\uF0AB'
      '*Applications*'              APPLICATIONS    '\uEAAE'
      '~'                           HOME            '\uF015'
      '~/*'                         HOME_SUBFOLDER  '\uF07C'
      '*'                           DEFAULT         '\uF115'
  )

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    if (( $1 )); then
      # Styling for up-to-date Git status.
      local        meta='%f'
      local    meta_wip='%180F' # orange
      local meta_remote='%248F' # gray
      local    meta_tag='%70F'  # green
      local meta_commit='%246F' # gray
      local       clean='%186F' # yellow
      local    modified='%186F' # yellow
      local      behind='%75F'  # blue
      local       ahead='%1F'   # red
      local     stashes='%140F' # purple
      local      staged='%114F' # green
      local    unstaged='%173F' # orange
      local   untracked='%252F' # white
      local  conflicted='%9F'   # red
    else
      # Styling for incomplete and stale Git status.
      local        meta='%244F'
      local    meta_wip='%244F'
      local meta_remote='%244F'
      local    meta_tag='%244F'
      local meta_commit='%244F'
      local       clean='%244F'
      local    modified='%244F'
      local      behind='%244F'
      local       ahead='%244F'
      local     stashes='%244F'
      local      staged='%244F'
      local    unstaged='%244F'
      local   untracked='%244F'
      local  conflicted='%244F'
    fi

    local res

    # Display branch always.
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi

    # Show tracking branch name if it differs from local branch.
    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta_remote}:${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi

    # Display current Git commit if there is no branch.
    if [[ -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      res+="${meta_commit} ${VCS_STATUS_COMMIT[1,8]}" # \uEA66
    fi

    # Display "wip" if the latest commit's summary contains "wip" or "WIP".
    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+="${meta_wip}(wip)"
    fi

    # Display tag always.
    if [[ -n $VCS_STATUS_TAG
          # && -z $VCS_STATUS_LOCAL_BRANCH
        ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"
      res+=" "
      res+="${meta_tag} ${tag//\%/%%}" # \uEA66
    fi

    # ⇣42 if behind the remote.
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${behind}⇣${VCS_STATUS_COMMITS_BEHIND}"
    # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
    (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${ahead}⇡${VCS_STATUS_COMMITS_AHEAD}"
    # ⇠42 if behind the push remote.
    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${behind}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
    # ⇢42 if ahead of the push remote; no leading space if also behind: ⇠42⇢42.
    (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${ahead}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    # *42 if have stashes.
    (( VCS_STATUS_STASHES        )) && res+=" ${stashes}*${VCS_STATUS_STASHES}"
    # 'merge' if the repo is in an unusual state.
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    # ~42 if have merge conflicts.
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    # +42 if have staged changes.
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${staged}+${VCS_STATUS_NUM_STAGED}"
    # !42 if have unstaged changes.
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${unstaged}!${VCS_STATUS_NUM_UNSTAGED}"
    # ?42 if have untracked files. It's really a question mark, your font isn't broken.
    # See POWERLEVEL9K_VCS_UNTRACKED_ICON above if you want to use a different icon.
    # Remove the next line if you don't want to see untracked files at all.
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}?${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    # "─" if the number of unstaged files is unknown. This can happen due to
    # POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY (see below) being set to a non-negative number lower
    # than the number of files in the Git index, or due to bash.showDirtyState being set to false
    # in the repository config. The number of staged and untracked files may also be unknown
    # in this case.
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=186 # 76
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=244
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=186
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=186
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=186

  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔ '
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔ '
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=208
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=208
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=208
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=142

  typeset -g POWERLEVEL9K_TIME_FOREGROUND=247
}
