# ~/.bashrc: executed by bash(1) for non-login shells.

# this .bashrc gives a kinda-cool color bash prompt, and enables enhanced dircolors.
# place this file in your ~/ folder of your WSL userspace and re-launch your shell to enable.
# download optional DIR_COLORS file and place in /etc folder for enhanced ls colors.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022


export LS_OPTIONS='--color=auto'

if type -P dircolors >/dev/null ; then
	if [[ -f ~/.dir_colors ]] ; then
		eval $(dircolors -b ~/.dir_colors)
	elif [[ -f /etc/DIR_COLORS ]] ; then
		eval $(dircolors -b /etc/DIR_COLORS)
	fi
fi

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

PS1="\n\[\033[1;37m\]\342\224\214($(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]\h'; else echo '\[\033[01;34m\]\u@\h'; fi)\[\033[1;37m\])\$([[ \$? != 0 ]] && echo \"\342\224\200(\[\033[0;31m\]\342\234\227\[\033[1;37m\])\")\342\224\200(\[\033[1;34m\]\@ \d\[\033[1;37m\])\[\033[1;37m\]\n\342\224\224\342\224\200(\[\033[1;32m\]\w\[\033[1;37m\])\342\224\200(\[\033[1;32m\]\$(ls -1 | wc -l | sed 's: ::g') files, \$(ls -lah | grep -m 1 total | sed 's/total //')b\[\033[1;37m\])\342\224\200> \[\033[0m\]"
