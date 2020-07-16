# Path to your oh-my-zsh installation.
export ZSH="/Users/${USER}/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Deletect platform
__OS__=""
if [[ $OSTYPE == "linux-gnu" ]]
then
    __OS__="linux"
elif [[ $OSTYPE == "darwin"* ]]
then
    __OS__="osx"
fi

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  colorize
  colored-man-pages
  command-not-found
  mosh
  ssh-agent
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Setup aliases
source ~/.aliases

# File search functions
function f() { find . -iname "*$1*" ${@:2} }
function r() { grep -R -n "$1" $2 }
function pub() { ssh-keygen -y -f $1 > $1.pub }

# autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# Homebrew needs /usr/local/bin to be before /usr/bin in PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export EDITOR=vim
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/developers/workspace
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
export PATH=$PATH:$GOROOT/bin

echo "FUCKING WORK $(date +%V/54)"

# Set locale
export LC_ALL=en_US.UTF-8

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(direnv hook zsh)"
