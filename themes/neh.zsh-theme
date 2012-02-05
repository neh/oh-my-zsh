PROMPT='$(git_prompt_info)$(git_prompt_status) %{$FX[bold]%}%{$FG[196]%}%(?..%?%{$FX[reset]%})%{$reset_color%}$BG_JOBS$PROMPT_CHAR%{$reset_color%} $(vi_mode_prompt_info)'
RPS1='%{$PWD_COLOUR%}%3(c.…/.)%2c %{$USER_COLOUR%}%n@%{$HOST_COLOUR%}%m%{$reset_color%}'

# vi mode indicator
MODE_INDICATOR="%{$FG[196]%}%{$FX[bold]%}!%{$FX[no-bold]%}%{$reset_color%}"

PROMPT_CHAR='➤'

# Background job(s) indicator
add-zsh-hook precmd jobs_precmd_hook
jobs_precmd_hook() {
  local rcount=$#jobstates[(R)running*]
  local scount=$#jobstates[(R)suspended*]
  if [[ rcount -gt 0 && scount -gt 0 ]]; then
    BG_JOBS="$FG[196]"
  elif [[ rcount -gt 0 ]]; then
    BG_JOBS="$FG[196]"
  elif [[ scount -gt 0 ]]; then
    BG_JOBS="$FG[226]"
  else
    BG_JOBS=""
  fi
}

add-zsh-hook precmd pwd_colour
function pwd_colour {
    if [[ -w $PWD ]]; then
        PWD_COLOUR="$FG[246]"
    else
        PWD_COLOUR="$FG[196]"
    fi
}

# change username color if root
if [ $UID -eq 0 ]; then USER_COLOUR="$FG[196]"; else USER_COLOUR="$FG[077]"; fi

# change hostname color if in ssh connection
case "$SSH_CONNECTION" in
    '') HOST_COLOUR="";;
    *) HOST_COLOUR="$FG[220]";;
esac

function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  STASH=$(git stash list 2> /dev/null | wc -l)
  if [[ $STASH -gt 0 ]]; then
    chars=(¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹)
    #STASHCOUNT="$STASH:"
    STASHCOUNT="$chars[$STASH]"
  fi
  echo "$STASHCOUNT$ZSH_THEME_GIT_PROMPT_PREFIX$(parse_git_dirty)${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

parse_git_dirty() {
  if [[ -n $(git status -s --untracked-files=no --ignore-submodules=dirty 2> /dev/null) ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

GIT_DIRTY_COLOR=$FG[133]
GIT_CLEAN_COLOR=$FG[077]
GIT_PROMPT_INFO=$FG[077]

ZSH_THEME_GIT_PROMPT_PREFIX="%{$GIT_PROMPT_INFO%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$FX[no-bold]%}%{$FX[no-italic]%}"
#ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_CLEAN=" %{$GIT_CLEAN_COLOR%}✔ "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$GIT_CLEAN_COLOR%}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} ⚡%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FX[italic]%}%{$FX[bold]%}"

ZSH_THEME_GIT_PROMPT_ADDED="%{$FG[082]%}✚"
#ZSH_THEME_GIT_PROMPT_MODIFIED="%{$FG[226]%}✎"
ZSH_THEME_GIT_PROMPT_MODIFIED=""
ZSH_THEME_GIT_PROMPT_DELETED="%{$FG[196]%}✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$FG[220]%}➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$FG[082]%}═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$FG[220]%}‽"
