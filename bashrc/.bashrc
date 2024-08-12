# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto' 

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -e /home/mrogers/.profile_tm ]; then . /home/mrogers/.profile_tm; fi

#export KUBECONFIG=/home/mrogers/.kube/config
#for file in /home/mrogers/.kube/configs/*.yaml; do
#  export KUBECONFIG=$KUBECONFIG:$file
#done
#
#export GOPATH=/home/mrogers:/home/mrogers/src/plz-out/gen/third_party/go:/home/mrogers/src/plz-out/gen/third_party/go/kubernetes:/home/mrogers/src/plz-out/gen/third_party/go/operator-sdk

# Give a nice looking PS1 with git branch and k8s config highlighted.
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

prompt_k8s(){
  k8s_current_context=$(kubectl config current-context 2> /dev/null)
  if [[ $? -eq 0 ]] ; then echo -e "(${k8s_current_context}) "; fi
}

export PS1="\[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\] \[\e[0;34m\]\$(prompt_k8s)\[\e[00m\]$ "

alias k="kubectl"
alias kc="kubectl config use-context"
alias kpo="kubectl get pods"
alias ksv="kubectl get svc"
alias kap="kubectl apply -f"

source <(kubectl completion bash)


# - git
alias gco="git checkout"
alias gs="git status"
alias ga="git add"
alias gcm="git commit"
alias gpm="git checkout master && git pull origin master && git checkout - && git pull && git status"
alias gp="git pull"

source <(kubectl completion bash | sed 's|__start_kubectl kubectl|__start_kubectl k|g')

# - use nvim instead of vim
alias vim="nvim"
alias rs="source ~/.bashrc"

# - fzf integration for mucking through git gubbins.
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

function is_in_git_repo {
    git rev-parse HEAD &> /dev/null
}

function fzf-down {
    fzf --height 50% "$@" --border
}

function gf {
    is_in_git_repo || return
    git -c color.status=always status --short |
        fzf-down -m --ansi --nth 2..,.. \
            --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
        cut -c 4- |
        sed 's/.* -> //'
}

function gb {
    is_in_git_repo || return
    git branch --color=always |
        grep -v '/HEAD\s' |
        sort |
        fzf-down --ansi --multi --tac --preview-window right:70% \
            --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
        sed 's/^..//' |
        cut -d ' ' -f 1 |
        sed 's#^remotes/##'
}

function gt {
    is_in_git_repo || return
    git tag --sort -version:refname |
    fzf-down --multi --preview-window right:70% \
        --preview "git show --color=always {} | head -$LINES"
}

function gh {
    is_in_git_repo || return
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
        fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
            --header 'Press CTRL-S to toggle sort' \
            --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
        grep -o "[a-f0-9]\{7,\}"
}

function gr {
    is_in_git_repo || return
    git remote -v |
        awk '{print $1 "\t" $2}' |
        uniq |
        fzf-down --tac \
            --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
        cut -d $'\t' -f 1
}

function gc {
    is_in_git_repo || return
    git checkout $(gb)
}

export VISUAL=nvim
export EDITOR="$VISUAL"
