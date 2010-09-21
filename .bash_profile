if [[ $(uname) = 'SunOS' ]]; then
    export PATH="/usr/gnu/bin:/opt/sfw/bin:/opt/sfw/sbin:/usr/sbin:/sbin:$PATH"
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
fi

if [[ $(uname) = 'Linux' ]]; then
  alias ls=' ls --color=auto -F'
  export ANDROID_JAVA_HOME=$JAVA_HOME
fi

if [[ $(uname) != 'SunOS' ]]; then
    alias grep='grep --colour=auto'
fi

if [[ $(uname) = 'SunOS' ]]; then
    alias tar='gtar'
fi

if [[ $(hostname) = 'athena' ]]; then
    alias sgeusedcores='/bin/bash ~/sgeusedcores.sh'
    . /opt/sge/util/dl.sh
fi

alias indent='indent -br -brs -cdw -ce -nut -nbfda -npcs -nbfde -nbc -nbad -cli4'

function lwhich() {
    ls -l $(which $@)
}

#Load keychain
[ -z ${HOSTNAME} ] && HOSTNAME=$(uname -n)
if [[ -z ${SSH_CONNECTION} ]] || [ "$HOSTNAME" == "athena" ] || [ "$HOSTNAME" == "loki" ]
then
    if [[ -z ${SGE_JOBID} ]] && [ "$TERM" != "dumb" ]
    then
        if which keychain 1>/dev/null 2>&1; then
            if [[ $(whoami) != 'root' ]]; then
                keychain id_rsa id_dsa
                . ~/.keychain/${HOSTNAME}-sh
            fi
        fi
    fi
fi

export MMTSBDIR=~mozes/mmtsb2/
export CHARMMEXEC=~jianhanc/charmm/c35b2/mpi/exec/gnu/charmm
export CHARMMDATA=~jianhanc/programs/mmtsb/data/charmm
export PATH=$PATH:$MMTSBDIR/perl:$MMTSBDIR/bin
#setenv REMOTESHELL ssh
export REMOTESHELL="qrsh -inherit"
