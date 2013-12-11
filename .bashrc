# User specific aliases and functions
alias c=clear
alias cls='clear; ls'
alias tmux='TERM=screen-256color-bce tmux'
alias grep='grep --color -n'

#
# Custom prompt
#

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

function __define_prompt() {
    local status="$?"
    local git_branch

    if [ "${status}" -eq 0 ]; then
        local status_color="${txtgrn}"
    else
        local status_color="${txtred}"
    fi

    if which git &> /dev/null; then
        git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
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
            echo -n " ${bldblk}(git: ${txtrst}${txtgrn}${git_branch}${txtrst}${bldblk})${txtrst}"
        fi

        echo
        echo    "${user_prompt} "
    )
}

define_colors

export PROMPT_COMMAND=__define_prompt
