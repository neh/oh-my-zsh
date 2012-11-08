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
        PWD_COLOUR="$FG[249]"
    else
        PWD_COLOUR="$FG[196]"
    fi
}

# change username color if root
if [ $UID -eq 0 ]; then USER_COLOUR="$FG[196]"; else USER_COLOUR="$FG[245]"; fi

# change hostname color if in ssh connection
case "$SSH_CONNECTION" in
    '') HOST_COLOUR="";;
    *) HOST_COLOUR="$FG[220]";;
esac


RPROMPT='%{$FG[242]%}!%!%{$reset_color%}'

PROMPT_CHAR='⬤'
SEP_CHAR="%{$FG[239]%}•"

FILL_CHAR="─"
FILL_FG="$FG[238]"
FILL_BG=""

add-zsh-hook precmd term_width
function term_width {
    local TERMWIDTH

    MGPI=$(git_prompt_info)
    if [[ $MGPI != '' ]]; then
        MGPS=$(git_prompt_status)
        MGPA=$(git_prompt_ahead)
        if [[ $MGPS != '' ]]; then MGPI="$MGPI $MGPS"; fi
        if [[ $MGPA != '' ]]; then MGPI="$MGPI $MGPA"; fi
        MGPI=" %{$SEP_CHAR%} $MGPI %{$SEP_CHAR%} "
    else
        MGPI=" %{$SEP_CHAR%} "
    fi

    PRE_PROMPT="
%{$FILL_FG%}%{$FILL_CHAR%} %{$PWD_COLOUR%}%4(c.…/.)%3c%{$MGPI%}%{$USER_COLOUR%}%n@%{$HOST_COLOUR%}%m %{$FILL_FG%}"
    PROMPT_SIZE=${#${(S%%)${PRE_PROMPT}//(\%([KF1]|)\{*\}|\%[Bbkf])}}
    PROMPT_LINE2="
%{$reset_color%}%{$FX[bold]%}%{$FG[196]%}%(?..%?%{$FX[reset]%})%{$reset_color%} $BG_JOBS$PROMPT_CHAR %{$reset_color%}"

    (( TERMWIDTH = ${COLUMNS} - ${PROMPT_SIZE} - 1 ))
    FILL="\${(l.$TERMWIDTH..${FILL_CHAR}.)}"
    PROMPT="$PRE_PROMPT$FILL$PROMPT_LINE2"
}

function git_prompt_info() {
  stat=$(git status --porcelain -s -b 2>/dev/null) || return
  branch=$(current_branch)
  if [[ $branch == '' ]]; then
      branch="± $(git show-ref --head -s --abbrev | head -n1 2> /dev/null)";
  else
      branch="± ⌥ $branch";
  fi
  # Just for fun:
  if [[ $stat =~ "Initial commit" && $branch == 'master' ]]; then
      branch="%{$FG[033]%}shiny%{$reset_color%}";
  fi

  STASH=$(git stash list 2> /dev/null | wc -l)
  if [[ $STASH -gt 0 ]]; then
    chars=(¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹)
    STASHCOUNT="$chars[$STASH]"
  fi
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(parse_git_dirty)$branch$ZSH_THEME_GIT_PROMPT_SUFFIX$STASHCOUNT"
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

#⬆ ⇪ ⇮ ➠ ⇡ ⇑ ⇧ ⬀ ⇗ ↥ ↨ ↕ ↗ ↑ ⬍ ⇅
ZSH_THEME_GIT_PROMPT_AHEAD="%{$FG[077]%}(ahead)"

ZSH_THEME_GIT_PROMPT_ADDED="%{$FG[082]%}✚"
#ZSH_THEME_GIT_PROMPT_MODIFIED="%{$FG[226]%}✎"
ZSH_THEME_GIT_PROMPT_MODIFIED=""
ZSH_THEME_GIT_PROMPT_DELETED="%{$FG[196]%}✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$FG[220]%}➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$FG[082]%}═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$FG[220]%}‽"
