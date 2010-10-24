# .zshrc
if [ -f /etc/profile ]; then
    source /etc/profile
fi
# Specific settings Dependding on what computer i am on...
if [[ $(uname) = 'SunOS' ]]; then
    export PATH="/usr/gnu/bin:/opt/sfw/bin:/opt/sfw/sbin:/usr/sbin:/sbin:$PATH"
    alias tar='gtar'
    alias ls=' ls --color=auto -F'
fi
export PATH="$HOME/bin:$HOME/.homefiles/bin:$PATH"
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE=~/.history
export EDITOR="vim" VISUAL="vim"
export PAGER="less"
export EDITOR=/usr/bin/vim
#export MANPAGER="col -b | view -c 'set ft=man nomod nolist nonu' -"
export MANPATH="$HOME/share/man:/usr/share/man:$MANPATH"
export PYTHONPATH="$HOME/lib/python:$HOME/lib/python2.4/site-packages:$PYTHONPATH"

if [[ $(uname) = 'Darwin' ]]; then
  alias ls=' ls -GF'
  alias dmesg="sudo dmesg"
  if [[ -e /Applications/MacVim.app/Contents/MacOS/MacVim ]]
  then
    alias gvim=/Applications/MacVim.app/Contents/MacOS/MacVim
  fi
  if [[ -e /Applications/MacVim.app/Contents/MacOS/Vim ]]
  then
    alias vim=/Applications/MacVim.app/Contents/MacOS/Vim
    alias vi=/Applications/MacVim.app/Contents/MacOS/Vim
    export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
  fi
  [ -z ${HOSTNAME} ] && HOSTNAME=$(uname -n)
  if [[ $(whoami) != 'root' ]]; then
    if which keychain 1>/dev/null 2>&1; then
      keychain id_rsa id_dsa
      . ~/.keychain/${HOSTNAME}-sh
    fi
  fi
fi

function _sudo() {
  if [[ "${1}" == "-s" ]]
  then
    sudo -E $@
  else
    sudo $@
  fi
}

function _irc() {
  if [[ -e `which screen` ]]
  then
    if [[ -n "`screen -wipe 2>&1 >/dev/null; screen -ls 2>&1 | grep irc`" ]]
    then
      screen -RRDD -S irc irssi
      return 0
    fi
  fi
  if [[ -e "`which dnsdomainname`" ]] && [[ "`dnsdomainname`" == "beocat" ]]
  then
    ssh -t mozes@wedge "screen -RRDD -S irc irssi"
  else
    ssh -t mozes@beocat.cis.ksu.edu -p 2201 "screen -RRDD -S irc irssi"
  fi
}

alias irc="_irc"

if [[ $(uname) = 'Linux' ]]; then
  alias ls=' ls --color=auto -F'
  export ANDROID_JAVA_HOME=$JAVA_HOME
  alias sudo="_sudo"
  if [ "$USER" != "root" ]
  then
    alias emerge='sudo emerge'
  fi
fi

if [[ $(uname) != 'SunOS' ]]; then
    alias grep='grep --colour=auto'
fi

alias indent='indent -br -brs -cdw -ce -nut -nbfda -npcs -nbfde -nbc -nbad -cli4'

function lwhich() {
    ls -l $(which $@)
}

function _checkin() {
  cd ~/conf_files
  git push ssh://mozes@cislinux.cis.ksu.edu/~/public_html/conf_files.git
  cd -
}

function _checkout() {
  cd ~/conf_files
  git pull origin master
  cd -
}

if [ "$USER" != "root" ]
then
  export PATH="$PATH:$HOME/scripts:$HOME/scripts/android-sdk-mac_86/tools:$HOME/scripts/android-sdk-mac_86/platforms/android-1.6/tools"
fi

# Set some vars for progs
export HISTFILE=~/.$USER.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000
export SHELL=/bin/zsh
export SED=sed
# Shell options
TIMEFMT=$'real\t%*Es\nuser\t%*Us\nsys \t%*Ss\ncpu \t%P'

# Some options..
#setopt autopushd pushdminus pushdsilent pushdtohome
setopt autocd
setopt cdablevars
setopt globdots
#setopt ignoreeof
setopt interactivecomments
#setopt nobanghist
setopt noclobber
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt SH_WORD_SPLIT
setopt bash_auto_list
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt nohup
#bindkey '\e[3~' delete-char
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line 
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line 

if [ -e /etc/beocat/beocat_users ]
then
  accounts=( $(</etc/beocat/beocat_users) )
  zstyle -e ':completion:*' users          'reply=($accounts)'
  zstyle -e ':completion:*' accounts       'reply=($accounts)'
  zstyle -e ':completion:*' my-accounts    'reply=($accounts)'
  zstyle -e ':completion:*' other-accounts 'reply=($accounts)'
  alias sgeusedcores='/bin/bash ~/sgeusedcores.sh'
  export PATH="/usr/local/bin:$PATH"
  if [[ -e /opt/sge/util/dl.sh ]]
  then
    . /opt/sge/util/dl.sh
  fi
  [ -z ${HOSTNAME} ] && HOSTNAME=$(uname -n)
  if [[ "$HOSTNAME" == "athena" ]] || [[ "$HOSTNAME" == "loki" ]] 
  then
    if [[ $(whoami) != 'root' ]]; then
      if which keychain 1>/dev/null 2>&1; then
        keychain id_rsa id_dsa
        . ~/.keychain/${HOSTNAME}-sh
      fi
    fi
  fi
fi

# allow approximate
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

## These next 2 lines are from compinstall.
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

# tab completion for PID :D
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# cd not select parent dir.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

alias -s gz=tar -zxvf
alias -s bz2=tar -jxvf

# type a directory's name to cd to it.
# compctl -/ cd

# Prompts
autoload colors
colors
ZLS_COLORS=$LS_COLORS
if [ "$USER" = "root" ]
then
  export PS1=" %{${fg[red]}%}%n%{${fg_bold[yellow]}%}@[%m] %{${fg[blue]}%}%~%{${reset_color}%} $ "
  export PATH="${PATH}:~mozes/scripts"
else
  export PS1="%{${fg[green]}%}%n%{${fg_bold[yellow]}%}@[%m] %{${fg[blue]}%}%~%{${reset_color}%} $ "
fi
export RPS1="%? %t"

if [[ $(whoami) != 'root' ]]; then
  if which git 1>/dev/null 2>&1; then 
    _checkout
  fi
fi

# manpage comletion
man_glob () {
  local a
  read -cA a
  if [[ $a[2] = -s ]] then
  reply=( ${^manpath}/man$a[3]/$1*$2(N:t:r) )
  else
  reply=( ${^manpath}/man*/$1*$2(N:t:r) )
  fi
}
compctl -K man_glob -x 'C[-1,-P]' -m - 'R[-*l*,;]' -g '*.(man|[0-9nlpo](|[a-z]))' + -g '*(-/)' -- man
packagelists() {
	reply=( `ls -A1 /home/mozes/scripts/package_lists` e world system )
}
compctl -K packagelists rebuild
zmodload zsh/complist
autoload -U compinit && compinit

### If you want zsh's completion to pick up new commands in $path automatically
### comment out the next line and un-comment the following 5 lines
#zstyle ':completion:::::' completer _complete _approximate
_force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1	# Because we didn't really complete anything
}
zstyle ':completion:::::' completer _force_rehash _complete _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
#zstyle ':completion::complete:*' use-cache 1
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
export MANPATH=/opt/local/share/man:$MANPATH
#export DISPLAY=:0.0
