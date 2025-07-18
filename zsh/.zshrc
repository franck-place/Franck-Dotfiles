# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# execute fastfetch at start
fastfetch

# Theme
ZSH_THEME="agnoster"
#need go-chroma-bin & ccat
ZSH_COLORIZE_TOOL=chroma
ZSH_COLORIZE_STYLE="colorful"
ZSH_COLORIZE_CHROMA_FORMATTER=terminal256

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Language environnement
export LANG=en_US.UTF-8

#alias
alias ..="cd ..";
alias update="paru -Syu";
alias pacman="sudo pacman";
alias cat="ccat";





