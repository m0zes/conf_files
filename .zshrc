# .zshrc
if [ -f /etc/profile ]; then
    source /etc/profile
fi
# Specific settings Dependding on what computer i am on...
if [[ $(uname) = 'SunOS' ]]; then
    export PATH="/usr/gnu/bin:/opt/sfw/bin:/opt/sfw/sbin:/usr/sbin:/sbin:$PATH"
    alias tar='gtar'
fi
export PATH="$HOME/bin:$HOME/.homefiles/bin:$PATH"
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE=~/.history
export EDITOR="vim" VISUAL="vim"
export PAGER="less"
#export MANPAGER="col -b | view -c 'set ft=man nomod nolist nonu' -"
export MANPATH="$HOME/share/man:/usr/share/man:$MANPATH"
export PYTHONPATH="$HOME/lib/python:$HOME/lib/python2.4/site-packages:$PYTHONPATH"

if [[ $(uname) = 'Darwin' ]]; then
  alias ls=' ls -GF'
  alias dmesg="sudo dmesg"
fi

if [[ $(uname) = 'Linux' ]]; then
  alias ls=' ls --color=auto -F'
  export ANDROID_JAVA_HOME=$JAVA_HOME
  if [ "$USER" != "root" ]
  then
    alias emerge='sudo emerge'
  fi
fi

if [[ $(uname) != 'SunOS' ]]; then
    alias grep='grep --colour=auto'
fi

if [[ $(hostname) = 'athena' ]]; then
    alias sgeusedcores='/bin/bash ~/sgeusedcores.sh'
    . /opt/sge/util/dl.sh
fi

alias indent='indent -br -brs -cdw -ce -nut -nbfda -npcs -nbfde -nbc -nbad -cli4'

function lwhich() {
    ls -l $(which $@)
}

#alias homed=' screen -U -R -D -S home ssh root@tygart.dyndns.org'
alias irc=' ~/scripts/irc'

if [ "$USER" != "root" ]
then
  export PATH="$PATH:$HOME/scripts:$HOME/scripts/android-sdk-mac_86/tools:$HOME/scripts/android-sdk-mac_86/platforms/android-1.6/tools"
fi

# Set some vars for progs
export HISTFILE=~/.$USER.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000
export EDITOR=/usr/bin/vim
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
#bindkey '\e[H' beginning-of-line
#bindkey '\e[F' end-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line 
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line 
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

[ -z ${HOSTNAME} ] && HOSTNAME=$(uname -n)
if [[ -z ${SSH_CONNECTION} ]] || [ "$HOSTNAME" == "athena" ] || [ "$HOSTNAME" == "loki" ]
then
  if [[ -z ${SGE_JOBID} ]] && [ "$TERM" != "dumb" ]
  then
    if [[ $(whoami) != 'root' ]]; then
      [ -n "`which git`" ] && git fetch origin master ~/
      if which keychain 1>/dev/null 2>&1; then
        keychain id_rsa id_dsa
        . ~/.keychain/${HOSTNAME}-sh
      fi
    fi
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
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
export MANPATH=/opt/local/share/man:$MANPATH
export DISPLAY=:0.0
