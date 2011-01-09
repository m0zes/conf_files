# .zshrc
# Source /etc/profile if it exists. This contains per host settings for paths and such
if [ -f /etc/profile ]; then
    source /etc/profile 2>/dev/null
fi

[ -z ${HOSTNAME} ] && HOSTNAME=$(uname -n)

# Functions
# Needed a sudo function, as simply sudo -s wasn't giving me my zsh shell with new versions of sudo
function _sudo() {
  if [[ "${1}" == "-s" ]]
  then
    sudo -E $@
  else
    sudo $@
  fi
}
# Allows remote console access to nodes on Beocat
function _remoteconsole() {
  if [[ -z "$1" ]]
  then
    echo "Specify a hostname"
    return 1
  fi
  H=${1}.manage
  if [[ -e "`which dnsdomainname`" ]] && [[ "`dnsdomainname`" == "beocat" ]]
  then
    echo "Enter password for admin on the remote host: "
    stty -echo
    read PASS
    stty echo
    if [[ "${HOSTNAME}" == "nyx" ]]
    then
      /usr/sbin/ipmitool -I lanplus -U admin -H ${H} -P ${PASS} -e '`' sol activate
    else
      ssh m0zes@nyx -t "/usr/sbin/ipmitool -I lanplus -U admin -H ${H} -P ${PASS} -e \\\` sol activate" #\`
    fi
  else
    if [[ -n "$2" ]] && [[ "$2" == "jnlp" ]]
    then
      echo "Fire up the jnlp after the shell has fired off"
      sudo ssh m0zes@beocat.cis.ksu.edu -p 5022 -L 443:${H}:443 -L 5120:${H}:5120 -L 5121:${H}:5121 -L 5123:${H}:5123 -L 7578:${H}:7578 -L 5555:${H}:5555 -L 5556:${H}:5556 -L 6481:${H}:6481 -L 8890:${H}:8890 -L 9000:${H}:9000 -L 9001:${H}:9001 -L 9002:${H}:9002 -L 9003:${H}:9003
    else
      echo "Enter password for admin on the remote host: "
      stty -echo
      read PASS
      stty echo
      ssh m0zes@beocat.cis.ksu.edu -t -p 5022 "/usr/sbin/ipmitool -I lanplus -U admin -H ${H} -P ${PASS} -e \\\` sol activate" #\`
    fi
  fi
}
# Accesses my irssi instance from whatever host I am on
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
# ls -l on whatever binary passed to it (as long as it is in the PATH)
function lwhich() {
    ls -l $(which $@)
}
# git checkin for my config files.
function _checkin() {
  cd ~/conf_files
  git push ssh://mozes@cislinux.cis.ksu.edu/~/public_html/conf_files.git
  cd - >/dev/null 2>&1
}
# git checkout for my config files.
function _checkout() {
  cd ~/conf_files
  git pull origin 
  ./link_dot_files.sh
  cd - >/dev/null 2>&1
}
#set window title
function _title() {
  if [[ "$1" != "" ]]; then
    WINTITLE="$@ " && export WINTITLE
  else
    unset WINTITLE
  fi
}
# Copy wii game to external disk
function _wiimv() {
  WITCMD=/Users/mozes/Downloads/wit-v1.23b-r2096-mac/bin/wit
  for game in $@; do 
    GAME=$( $WITCMD LS -H ${game} | tr -d '[:punct:]' | tr '\ ' '#' )
    GAMEID=$( echo ${GAME} | sed -e 's/##.*//' )
    TITLE=$( echo ${GAME} | sed -e 's/.*##//' -e 's/#/_/g' )
    if [[ -n "${GAMEID}" ]] && [[ -n "${TITLE}" ]] && [[ -f ${game} ]]; then
      mkdir -p /Volumes/WiiGames/wbfs/${GAMEID}_${TITLE}/
      $WITCMD CP -B ${game} -d /Volumes/WiiGames/wbfs/${GAMEID}_${TITLE}/${GAMEID}.wbfs
      rm ${game}
    fi
  done
}
# unrar all rar files in the passed directories
function _tbunrar() {
  if [[ "$1" == "-h" ]]; then
    echo "_tbunrar dir\ to\ extract"
    return
  elif [[ "$1" == "" ]]; then
    _tbunrar $PWD
    return
  fi
  for dir in $@ ; do
    for arc in `find $dir -iname '*01.rar' -o -iname '*.r01'`; do
      unrar e ${arc}
    done
  done
}

# Specific settings Depending on what computer i am on...
if [[ $(uname) = 'SunOS' ]]; then
  export PATH="/usr/gnu/bin:/opt/sfw/bin:/opt/sfw/sbin:/usr/sbin:/sbin:$PATH"
  alias tar='gtar'
  alias ls=' ls --color=auto -F'
  if [[ -e /var/run/screen ]]; then
    if [[ ! -e /var/run/screen/S-$USER ]]; then
      mkdir /var/run/screen/S-$USER
      chmod 700 /var/run/screen/S-$USER
    fi
  else
    if [[ "$USER" == "root" ]]; then
      mkdir -p /var/run/screen
      sudo chmod 777 /var/run/screen 
      mkdir /var/run/screen/S-$USER
      chmod 700 /var/run/screen/S-$USER
    fi
  fi
  export SCREENDIR=/var/run/screen/S-$USER
fi

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
  if [[ $(whoami) != 'root' ]]; then
    if which keychain 1>/dev/null 2>&1; then
      keychain id_rsa id_dsa
      . ~/.keychain/${HOSTNAME}-sh
    fi
  fi
fi

if [[ $(uname) = 'Linux' ]]; then
  alias ls=' ls --color=auto -F'
  export ANDROID_JAVA_HOME=$JAVA_HOME
  alias sudo="_sudo"
  if [ "$USER" != "root" ]
  then
    alias emerge='sudo emerge'
  fi
  if [ -e /usr/bin/time ]
  then
    alias time="/usr/bin/time -f 'real %e\nuser %U\nsys %S\nmem %M\n'"
  fi
fi

if [[ $(uname) != 'SunOS' ]]; then
    alias grep='grep --colour=auto'
fi

if [ -e /etc/beocat/beocat_users ]
then
  accounts=( $(</etc/beocat/beocat_users) $(</etc/beocat/beocat_admins))
  zstyle -e ':completion:*' users          'reply=($accounts)'
  #zstyle -e ':completion:*' accounts       'reply=($accounts)'
  #zstyle -e ':completion:*' my-accounts    'reply=($accounts)'
  #zstyle -e ':completion:*' other-accounts 'reply=($accounts)'
  alias sgeusedcores='/bin/bash ~/sgeusedcores.sh'
  export PATH="/usr/local/bin:$PATH"
  if [[ -e /opt/sge/util/dl.sh ]]; then
    . /opt/sge/util/dl.sh
  fi
  if [[ "$HOSTNAME" == "athena" ]] || [[ "$HOSTNAME" == "loki" ]]; then
    if [[ $(whoami) != 'root' ]]; then
      if which keychain 1>/dev/null 2>&1; then
        keychain id_rsa id_dsa
        . ~/.keychain/${HOSTNAME}-sh
      fi
    fi
  fi
fi

if [[ $(whoami) != 'root' ]]; then
  export PATH="$PATH:$HOME/scripts:$HOME/scripts/android-sdk-mac_86/tools:$HOME/scripts/android-sdk-mac_86/platform-tools"
  if which git 1>/dev/null 2>&1; then 
    _checkout
  fi
fi

# Handle screen and xterm titles
preexec () {
  local HOSTNAME
  [ -z ${HOSTNAME} ] && HOSTNAME=$(hostname -s 2>/dev/null)
  [ -z ${HOSTNAME} ] && HOSTNAME=$(uname -n)
  if [[ "${TERM[0,6]}" == "screen" ]]
  then
    if [[ $(whoami) != 'root' ]]; then
      echo -ne "\ek${WINTITLE}${HOSTNAME} ${1%% *}\e\\"
    else
      echo -ne "\ek*${WINTITLE}${HOSTNAME} ${1%% *}\e\\"
    fi
    echo -ne "\e_${WINTITLE}${USER}@${HOSTNAME}: ${1%% *}\e\\"
  elif [[ "${TERM[0,5]}" == "xterm" ]]; then
    echo -ne "\e]0;${WINTITLE}${USER}@${HOSTNAME}: ${PWD}\a"
  fi
}
precmd () {
  local HOSTNAME
  [ -z ${HOSTNAME} ] && HOSTNAME=$(hostname -s 2>/dev/null)
  [ -z ${HOSTNAME} ] && HOSTNAME=$(uname -n)
  if [[ "${TERM[0,6]}" == "screen" ]]
  then
    if [[ $(whoami) != 'root' ]]; then
      echo -ne "\ek${WINTITLE}${HOSTNAME}\e\\"
    else
      echo -ne "\ek*${WINTITLE}${HOSTNAME}\e\\"
    fi
    echo -ne "\e_${WINTITLE}${USER}@${HOSTNAME}: ${PWD}\e\\"
  elif [[ "${TERM[0,5]}" == "xterm" ]]; then
    echo -ne "\e]0;${WINTITLE}${USER}@${HOSTNAME}: ${PWD}\a"
  fi
}

alias irc="_irc"
alias indent='indent -br -brs -cdw -ce -nut -nbfda -npcs -nbfde -nbc -nbad -cli4'
alias -s gz=tar -zxvf
alias -s bz2=tar -jxvf

export PATH="/opt/local/bin:/opt/local/sbin:$HOME/bin:$PATH"
export EDITOR="vim" VISUAL="vim"
export PAGER="less"
export MANPATH="/opt/local/share/man:$HOME/share/man:/usr/share/man:$MANPATH"

# Set some vars for progs
export HISTFILE=~/.zsh/.$USER.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000
export SHELL=/bin/zsh
export SED=sed
# Shell options
TIMEFMT=$'real\t%*Es\nuser\t%*Us\nsys \t%*Ss\ncpu \t%P'

# Some options..
setopt autocd
setopt cdablevars
setopt globdots
setopt interactivecomments
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

# manpage completion
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
zmodload zsh/complist
autoload -U compinit && compinit -d ~/.zsh/.zcompdump.${HOST} 

if [[ ! -f ~/.zsh/.zcompdump.$HOST.zwc ||
    -n ${~:-~/.zsh/.zshrc(Nmm+1)} &&
    ~/.zsh/.zcompdump.$HOST -nt \
    ~/.zsh/.zcompdump.$HOST.zwc ]];
then
    zcompile ~/.zsh/.zcompdump.$HOST
fi

### If you want zsh's completion to pick up new commands in $path automatically
### comment out the next line and un-comment the following 5 lines
#zstyle ':completion:::::' completer _complete _approximate
_force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1	# Because we didn't really complete anything
}
zstyle ':completion:::::' completer _force_rehash _expand _complete _correct _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes

# tab completion for PID :D
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# cd not select parent dir.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

groups=( "${(@)${(@f)$(</etc/group)}%%:*}" )
zstyle ':completion:*' groups $groups
#if [[ -r $HOME/.ssh/known_hosts ]]; then
#  sshhosts=(
#    ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*}
#  )
#fi
#if [[ -r /etc/ssh/ssh_known_hosts ]]; then
#  sshhosts=(
#    $sshhosts
#    ${${${${(f)"$(</etc/ssh/ssh_known_hosts)"}:#[0-9]*}%%\ *}%%,*}
#  )
#fi
#zstyle ':completion:*' hosts $sshhosts
