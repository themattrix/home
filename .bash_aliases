if which nvim &> /dev/null; then
    alias vim=nvim
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias c='clear'
alias cls='clear; ls'
alias tmux='TERM=screen-256color-bce tmux'
alias ccat='pygmentize -g -O bg=dark'
alias percol='percol --match-method regex'
alias copy='xclip -selection clipboard'

function cless() {
    pygmentize -g -O bg=dark "$@" | less -R
}

REAL_DOCKER=$(which docker)

# Provides a 'docker clean' command.
function docker() {
    if [ "$1" == "clean" ]; then
        local stopped_containers=$("${REAL_DOCKER}" ps -a | grep 'Exited' | awk '{print $1}')
        local untagged_images=$("${REAL_DOCKER}" images | grep '^<none>' | awk '{print $3}')

        if [ -n "${stopped_containers}" ]; then
            echo ">>> Removing stopped containers..."
            "${REAL_DOCKER}" rm ${stopped_containers}
        fi

        if [ -n "${untagged_images}" ]; then
            echo ">>> Removing untagged images..."
            "${REAL_DOCKER}" rmi ${untagged_images}
        fi
    else
        "${REAL_DOCKER}" "$@"
    fi
}

function trim() {
    expand | cut -c-$COLUMNS
}
