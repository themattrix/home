# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

function define_colors() {
    # https://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash
    txtblk='\e[0;30m' # Black - Regular
    txtred='\e[0;31m' # Red
    txtgrn='\e[0;32m' # Green
    txtylw='\e[0;33m' # Yellow
    txtblu='\e[0;34m' # Blue
    txtpur='\e[0;35m' # Purple
    txtcyn='\e[0;36m' # Cyan
    txtwht='\e[0;37m' # White
    bldblk='\e[1;30m' # Black - Bold
    bldred='\e[1;31m' # Red
    bldgrn='\e[1;32m' # Green
    bldylw='\e[1;33m' # Yellow
    bldblu='\e[1;34m' # Blue
    bldpur='\e[1;35m' # Purple
    bldcyn='\e[1;36m' # Cyan
    bldwht='\e[1;37m' # White
    unkblk='\e[4;30m' # Black - Underline
    undred='\e[4;31m' # Red
    undgrn='\e[4;32m' # Green
    undylw='\e[4;33m' # Yellow
    undblu='\e[4;34m' # Blue
    undpur='\e[4;35m' # Purple
    undcyn='\e[4;36m' # Cyan
    undwht='\e[4;37m' # White
    bakblk='\e[40m'   # Black - Background
    bakred='\e[41m'   # Red
    bakgrn='\e[42m'   # Green
    bakylw='\e[43m'   # Yellow
    bakblu='\e[44m'   # Blue
    bakpur='\e[45m'   # Purple
    bakcyn='\e[46m'   # Cyan
    bakwht='\e[47m'   # White
    txtrst='\e[0m'    # Text Reset
}

function __should_reload_bashrc() {
    local actual_bashrc_timestamp=$(stat -c %Y -- "${HOME}/.bashrc")

    if [ -n "${RECORDED_BASHRC_TIMESTAMP}" ]; then
        if [ "${actual_bashrc_timestamp}" -eq "${RECORDED_BASHRC_TIMESTAMP}" ]; then
            return 1
        fi
    fi

    RECORDED_BASHRC_TIMESTAMP=${actual_bashrc_timestamp}
    return 0
}

function __reload_bashrc() {
    source "${HOME}/.bashrc"
}

function __define_prompt() {
    local status="${1:-$?}"

    if __should_reload_bashrc; then
        __reload_bashrc
        __define_prompt "${status}"
    else
        local git_branch
        local git_nothing_to_commit
        local git_branch_out_of_sync
        local git_unstaged_changes
        local git_untracked_files

        if [ "${status}" -eq 0 ]; then
            local status_color="${txtgrn}"
        else
            local status_color="${txtred}"
        fi

        if which git &> /dev/null; then
            git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

            if [ -n "${git_branch}" ]; then
                local git_status=$(git status)

                grep -sqFx "nothing to commit, working directory clean" <<< "${git_status}"
                git_nothing_to_commit=$?

                if [ ${git_nothing_to_commit} -eq 1 ]; then
                    grep -sqFx "# Changes not staged for commit:" <<< "${git_status}"
                    git_unstaged_changes=$?

                    if [ "${git_unstaged_changes}" -eq 1 ]; then
                        grep -sqFx "# Untracked files:" <<< "${git_status}"
                        git_untracked_files=$?
                    fi
                fi

                grep -sq "^# Your branch is" <<< "${git_status}"
                git_branch_out_of_sync=$?
            fi
        fi

        if [ "$(id -u)" -eq 0 ]; then
            local user_color="${txtred}"
            local user_prompt="#"
        else
            local user_color="${txtcyn}"
            local user_prompt="$"
        fi

        PS1=$(
            echo -n "${bldblk}"
            printf  "%*s" "$((${COLUMNS} - ${#status} - 2))" "" | sed 's/ /_/g'
            echo -n "${txtrst}${bldblk}[${txtrst}${status_color}${status}${txtrst}${bldblk}]${txtrst}"
            echo
            echo -n "${user_color}\u${txtrst}"
            echo -n "${bldblk}@${txtrst}"
            echo -n "${txtylw}\h${txtrst}"
            echo -n " ${bldblk}[${txtrst}${txtpur}\w${txtrst}${bldblk}]${txtrst}"

            if [ -n "${git_branch}" ]; then
                local icon

                if [ ${git_nothing_to_commit} -eq 1 ]; then
                    # There is something to commit...
                    if [ ${git_unstaged_changes} -eq 0 ]; then
                        # Unstaged changes exist
                        local plus_color="${txtred}"
                    elif [ ${git_untracked_files} -eq 0 ]; then
                        # No unstaged changes exist, but untracked files exist
                        local plus_color="${txtylw}"
                    else
                        # No unstaged changes or untracked files exist
                        local plus_color="${txtgrn}"
                    fi
                    icon=" ${bldblk}[${txtrst}${plus_color}+${txtrst}${bldblk}]${txtrst}"
                elif [ ${git_branch_out_of_sync} -eq 0 ]; then
                    icon=" ${bldblk}[^]${txtrst}"
                fi

                echo -n " ${bldblk}(git: ${txtrst}${txtgrn}${git_branch}${txtrst}${icon}${bldblk})${txtrst}"
            fi

            echo
            echo "${user_prompt} "
        )
    fi
}

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    define_colors
    export PROMPT_COMMAND=__define_prompt
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
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

# Launch tmux automatically in new sessions
# -> http://stackoverflow.com/a/11069117/27925
if [[ ! $TERM =~ screen ]]; then
    if which tmux &> /dev/null; then
        exec tmux
    fi
fi
