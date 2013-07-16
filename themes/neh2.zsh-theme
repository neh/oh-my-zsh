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

function battery_gauge {
    if [[ -x '/usr/bin/ibam' ]]; then
        BATT_STATE="$(ibam --percentbattery)"
        BATT_PERCENT="${BATT_STATE[(f)1][(w)-2]}"
        BATT_TIME="${BATT_STATE[(f)2][(w)-1]}"
        (( BATT_USED_PERCENT = 100 - $BATT_PERCENT ))
        if [[ $BATT_USED_PERCENT -gt 80 ]]; then
            BATT_COLOUR="$FG[196]"
        elif [[ $BATT_USED_PERCENT -gt 60 ]]; then
            BATT_COLOUR="$FG[226]"
        else
            BATT_COLOUR="$FG[245]"
        fi

        BATT_A=$(printf "%.0f" $(( $BATT_PERCENT / 10.0 )) )
        BATT_B=$(printf "%.0f" $(( $BATT_A / 2 )) )
        (( BATT_C = $(( 10 - BATT_A  )) / 2 ))
        BATT_GAUGE="${(l.$BATT_B..●.)}"
        if [[ $(( $BATT_B + $BATT_C )) -lt 5 ]]; then
            BATT_GAUGE="$BATT_GAUGE◐"
        fi
        BATT_GAUGE="$BATT_GAUGE${(l.$BATT_C..◌.)}"

        echo "%{$BATT_COLOUR%}$BATT_GAUGE"
    else
        echo ''
    fi
}

RPROMPT='$(battery_gauge)%{$reset_color%}'

PROMPT_CHAR='⬤'
SEP_CHAR="%{$FG[239]%}─"

FILL_CHAR="─"
FILL_FG="$FG[238]"
FILL_BG=""

add-zsh-hook precmd term_width
function term_width {
    local TERMWIDTH

    PR_GIT_PROMPT_INFO=$(git_prompt_info)
    if [[ $PR_GIT_PROMPT_INFO != '' ]]; then
        PR_GIT_PROMPT_STATUS=$(git_prompt_status)
        if [[ $PR_GIT_PROMPT_STATUS != '' ]]; then
            PR_GIT_PROMPT_INFO="$PR_GIT_PROMPT_INFO $PR_GIT_PROMPT_STATUS";
        fi
        PR_GIT_PROMPT_INFO=" %{$SEP_CHAR%} $PR_GIT_PROMPT_INFO %{$SEP_CHAR%} "
    else
        PR_GIT_PROMPT_INFO=" %{$SEP_CHAR%} "
    fi

    PR_PATH="%{$PWD_COLOUR%}%4(c.…/.)%3c"

    PR_USER_HOST="%{$USER_COLOUR%}%n"
    if [[ $SSH_CONNECTION != '' ]]; then
        PR_USER_HOST="$PR_USER_HOST@%m"
    fi

    KNIFE_BLOCK_CURRENT=""
    if [[ -h $HOME/.chef/knife.rb ]]; then
      KNIFE_BLOCK_CURRENT="%{$FG[077]%}%{$FX[italic]%}⚔%{$FX[no-italic]%} $(ls -l $HOME/.chef/knife.rb | sed -r -e 's#^.*knife-(.+).rb$#\1#') %{$SEP_CHAR%} "
    fi

    PROMPT_LINE1="
%{$FILL_FG%}%{$FILL_CHAR%} %{$PR_PATH%}%{$PR_GIT_PROMPT_INFO%}%{$KNIFE_BLOCK_CURRENT%}%{$PR_USER_HOST%} %{$FILL_FG%}"
    PROMPT_LINE1_LENGTH=${#${(S%%)${PROMPT_LINE1}//(\%([KF1]|)\{*\}|\%[Bbkf])}}
    PROMPT_LINE2="
%{$reset_color%}%{$FX[bold]%}%{$FG[196]%}%(?..%?%{$FX[reset]%})%{$reset_color%} $BG_JOBS$PROMPT_CHAR %{$reset_color%}"

    (( TERMWIDTH = ${COLUMNS} - ${PROMPT_LINE1_LENGTH} - 1 ))
    FILL="\${(l.$TERMWIDTH..${FILL_CHAR}.)}"
    PROMPT="$PROMPT_LINE1$FILL$PROMPT_LINE2"
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
  if [[ $stat =~ "Initial commit on master" ]]; then
      branch="± %{$FG[033]%}shiny%{$reset_color%}";
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
