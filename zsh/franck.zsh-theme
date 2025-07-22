# Franck Monochrome Agnoster Theme for ZSH

# color definitions
SEGMENT_SEPARATOR=$'\ue0b0'
PLUSMINUS=$'\u00b1'
BRANCH=$'\ue0a0'
DETACHED=$'\u27a6'
CROSS=$'\u2718'
LIGHTNING=$'\u26a1'
GEAR=$'\u2699'

# colors (using 256-color codes)
COLOR_BLACK=0
COLOR_DARK_GRAY=236
COLOR_MEDIUM_GRAY=240
COLOR_LIGHT_GRAY=244
COLOR_BRIGHT_GRAY=248
COLOR_WHITE=255

# Status colors
COLOR_ERROR=$COLOR_WHITE
COLOR_WARNING=$COLOR_BRIGHT_GRAY
COLOR_SUCCESS=$COLOR_LIGHT_GRAY

# Begin a segment
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`
  
  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment $COLOR_DARK_GRAY $COLOR_WHITE "%(!.%{%F{$COLOR_WHITE}%}.)$user@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment $COLOR_MEDIUM_GRAY $COLOR_WHITE
    else
      prompt_segment $COLOR_MEDIUM_GRAY $COLOR_BRIGHT_GRAY
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:git:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${ref/refs\/heads\// }${vcs_info_msg_0_%% }${mode}"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment $COLOR_LIGHT_GRAY $COLOR_BLACK '%~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment $COLOR_MEDIUM_GRAY $COLOR_WHITE "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$COLOR_WHITE}%}$CROSS"
  [[ $UID -eq 0 ]] && symbols+="%{%F{$COLOR_WHITE}%}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$COLOR_BRIGHT_GRAY}%}$GEAR"

  [[ -n "$symbols" ]] && prompt_segment $COLOR_DARK_GRAY $COLOR_WHITE "$symbols"
}

# Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '

# Right prompt showing time
RPROMPT='%{%F{$COLOR_MEDIUM_GRAY}%}%D{%H:%M:%S}%{%f%}'

# Terminal color configuration for monochrome
# Add these to your .zshrc or terminal configuration

# ANSI Color definitions (0-15)
# Black and dark colors (0-7)
export COLOR_0="#000000"   # Black
export COLOR_1="#404040"   # Dark Gray (Red)
export COLOR_2="#505050"   # Medium Dark Gray (Green)
export COLOR_3="#606060"   # Medium Gray (Yellow)
export COLOR_4="#707070"   # Medium Light Gray (Blue)
export COLOR_5="#808080"   # Gray (Magenta)
export COLOR_6="#909090"   # Light Gray (Cyan)
export COLOR_7="#A0A0A0"   # Bright Gray (White)

# Bright colors (8-15)
export COLOR_8="#303030"   # Bright Black
export COLOR_9="#B0B0B0"   # Bright Dark Gray (Bright Red)
export COLOR_10="#C0C0C0"  # Bright Medium Gray (Bright Green)
export COLOR_11="#D0D0D0"  # Bright Light Gray (Bright Yellow)
export COLOR_12="#E0E0E0"  # Very Light Gray (Bright Blue)
export COLOR_13="#F0F0F0"  # Near White (Bright Magenta)
export COLOR_14="#F8F8F8"  # Off White (Bright Cyan)
export COLOR_15="#FFFFFF"  # White (Bright White)

# LS_COLORS for monochrome file listings
export LS_COLORS='di=1;37:ln=37:so=37:pi=37:ex=1;37:bd=37:cd=37:su=37:sg=37:tw=37:ow=37:*.tar=37:*.tgz=37:*.arc=37:*.arj=37:*.taz=37:*.lha=37:*.lz4=37:*.lzh=37:*.lzma=37:*.tlz=37:*.txz=37:*.tzo=37:*.t7z=37:*.zip=37:*.z=37:*.Z=37:*.dz=37:*.gz=37:*.lrz=37:*.lz=37:*.lzo=37:*.xz=37:*.bz2=37:*.bz=37:*.tbz=37:*.tbz2=37:*.tz=37:*.deb=37:*.rpm=37:*.jar=37:*.war=37:*.ear=37:*.sar=37:*.rar=37:*.alz=37:*.ace=37:*.zoo=37:*.cpio=37:*.7z=37:*.rz=37:*.cab=37:*.jpg=37:*.jpeg=37:*.gif=37:*.bmp=37:*.pbm=37:*.pgm=37:*.ppm=37:*.tga=37:*.xbm=37:*.xpm=37:*.tif=37:*.tiff=37:*.png=37:*.svg=37:*.svgz=37:*.mng=37:*.pcx=37:*.mov=37:*.mpg=37:*.mpeg=37:*.m2v=37:*.mkv=37:*.webm=37:*.ogm=37:*.mp4=37:*.m4v=37:*.mp4v=37:*.vob=37:*.qt=37:*.nuv=37:*.wmv=37:*.asf=37:*.rm=37:*.rmvb=37:*.flc=37:*.avi=37:*.fli=37:*.flv=37:*.gl=37:*.dl=37:*.xcf=37:*.xwd=37:*.yuv=37:*.cgm=37:*.emf=37:*.axv=37:*.anx=37:*.ogv=37:*.ogx=37:*.aac=37:*.au=37:*.flac=37:*.mid=37:*.midi=37:*.mka=37:*.mp3=37:*.mpc=37:*.ogg=37:*.ra=37:*.wav=37:*.axa=37:*.oga=37:*.spx=37:*.xspf=37:'

# Git config for monochrome
# Add to ~/.gitconfig
# [color]
#     ui = always
# [color "branch"]
#     current = white
#     local = white
#     remote = white
# [color "diff"]
#     meta = white
#     frag = white
#     old = white
#     new = white bold
# [color "status"]
#     added = white
#     changed = white
#     untracked = white dim
