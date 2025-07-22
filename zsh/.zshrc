# Paths
export ZSH="$HOME/.oh-my-zsh"
export PATH=/home/franck/.local/bin:$PATH

# execute fastfetch at start
fastfetch

# Theme
ZSH_THEME="franck"
#go-chroma-bin
ZSH_COLORIZE_TOOL=chroma
ZSH_COLORIZE_STYLE="colorful"
ZSH_COLORIZE_CHROMA_FORMATTER=terminal256

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Language environnement
export LANG=en_US.UTF-8

#alias
alias ..="cd ..";
alias update="paru -Syu";
alias pacman="sudo pacman";
alias cat="ccat";
alias vi="lvim"; #lunarvim
alias nvi="nvim";
