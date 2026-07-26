# https://github.com/jackharrisonsherlock/common

# Prompt symbol
: ${COMMON_PROMPT_SYMBOL:="❯"}

# Colors
: ${COMMON_COLORS_HOST_ME:=green}
: ${COMMON_COLORS_HOST_AWS_VAULT:=yellow}
: ${COMMON_COLORS_CURRENT_DIR:=blue}
: ${COMMON_COLORS_RETURN_STATUS_TRUE:=magenta}
: ${COMMON_COLORS_RETURN_STATUS_FALSE:=yellow}
: ${COMMON_COLORS_GIT_STATUS_DEFAULT:=green}
: ${COMMON_COLORS_GIT_STATUS_STAGED:=red}
: ${COMMON_COLORS_GIT_STATUS_UNSTAGED:=yellow}
: ${COMMON_COLORS_GIT_PROMPT_SHA:=green}
: ${COMMON_COLORS_BG_JOBS:=yellow}

# Git status symbols
: ${COMMON_GIT_STAGED_SYMBOL:="+"}
: ${COMMON_GIT_UNSTAGED_SYMBOL:="!"}
: ${COMMON_GIT_UNTRACKED_SYMBOL:="?"}

# Use zsh-async when it has been loaded before this theme.
: ${COMMON_GIT_ASYNC:=true}

# Left prompt
PROMPT='$(common_host)$(common_current_dir)$(common_bg_jobs)$(common_return_status)'

# Right prompt
RPROMPT='$(common_git_status)'

# Enable redrawing of prompt variables
setopt promptsubst

# Prompt with current SHA
# PROMPT='$(common_host)$(common_current_dir)$(common_bg_jobs)$(common_return_status)'
# RPROMPT='$(common_git_status) $(git_prompt_short_sha)'

# Host
common_host() {
  local me=""

  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi

  if [[ -n $me ]]; then
    print -rn -- "%{$fg[$COMMON_COLORS_HOST_ME]%}$me%{$reset_color%}:"
  fi

  if [[ -n $AWS_VAULT ]]; then
    print -rn -- "%{$fg[$COMMON_COLORS_HOST_AWS_VAULT]%}$AWS_VAULT%{$reset_color%} "
  fi
}

# Current directory
common_current_dir() {
  print -rn -- "%{$fg[$COMMON_COLORS_CURRENT_DIR]%}%c "
}

# Prompt symbol
common_return_status() {
  print -rn -- "%(?.%F{$COMMON_COLORS_RETURN_STATUS_TRUE}.%F{$COMMON_COLORS_RETURN_STATUS_FALSE})$COMMON_PROMPT_SYMBOL%f "
}

# Build the Git segment.
common_git_status_render() {
  local working_directory=$1
  local git_status branch message_color
  local -i staged_count=0
  local -i unstaged_count=0
  local -i untracked_count=0
  local status_line index_status worktree_status

  if [[ -n $working_directory ]]; then
    builtin cd -q -- "$working_directory" || return
  fi

  git_status=$(command git status --porcelain=v1 2>/dev/null) || return
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null ||
    command git rev-parse --short HEAD 2>/dev/null) || return

  for status_line in ${(f)git_status}; do
    if [[ $status_line == \?\?* ]]; then
      (( untracked_count++ ))
      continue
    fi

    index_status=${status_line[1]}
    worktree_status=${status_line[2]}

    [[ $index_status != ' ' ]] && (( staged_count++ ))
    [[ $worktree_status != ' ' ]] && (( unstaged_count++ ))
  done

  if (( staged_count > 0 )); then
    message_color=$COMMON_COLORS_GIT_STATUS_STAGED
  elif (( unstaged_count > 0 || untracked_count > 0 )); then
    message_color=$COMMON_COLORS_GIT_STATUS_UNSTAGED
  else
    message_color=$COMMON_COLORS_GIT_STATUS_DEFAULT
  fi

  print -rn -- "%F{$message_color}$branch"
  (( staged_count > 0 )) && print -rn -- " $COMMON_GIT_STAGED_SYMBOL$staged_count"
  (( unstaged_count > 0 )) && print -rn -- " $COMMON_GIT_UNSTAGED_SYMBOL$unstaged_count"
  (( untracked_count > 0 )) && print -rn -- " $COMMON_GIT_UNTRACKED_SYMBOL$untracked_count"
  print -rn -- '%f'
}

# Git status
common_git_status() {
  if [[ $COMMON_GIT_ASYNC == true && $+functions[async_job] -eq 1 ]]; then
    print -rn -- "$COMMON_GIT_STATUS"
  else
    common_git_status_render
  fi
}

# Refresh the cached Git segment without blocking prompt rendering.
common_git_status_async() {
  async_flush_jobs common_git_prompt
  async_job common_git_prompt common_git_status_render "$PWD"
}

common_git_status_async_callback() {
  local job_name=$1
  local return_code=$2
  local output=$3
  local has_next=$6

  [[ $job_name == common_git_status_render ]] || return

  if (( return_code == 0 )); then
    COMMON_GIT_STATUS=$output
  else
    COMMON_GIT_STATUS=""
  fi

  if (( has_next == 0 )) && [[ -o interactive ]] && zle; then
    zle reset-prompt
  fi
}

# Enable asynchronous Git status when zsh-async is available.
if [[ $COMMON_GIT_ASYNC == true && $+functions[async_start_worker] -eq 1 ]]; then
  typeset -g COMMON_GIT_STATUS=""
  async_start_worker common_git_prompt -n
  async_register_callback common_git_prompt common_git_status_async_callback

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd common_git_status_async
  add-zsh-hook chpwd common_git_status_async
fi

# Git prompt SHA
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{%F{$COMMON_COLORS_GIT_PROMPT_SHA}%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%} "

# Background jobs
common_bg_jobs() {
  local bg_status="%{$fg[$COMMON_COLORS_BG_JOBS]%}%(1j.↓%j .)"
  print -rn -- "$bg_status"
}
