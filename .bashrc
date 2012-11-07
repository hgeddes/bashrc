# .bashrc

# Source global definitions

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# colors

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensty
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensty
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensty backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[10;95m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

# History

HISTCONTROL="erasedups:ignoreboth"

__git_ps1() 
{ 
    local b="$(git symbolic-ref HEAD 2>/dev/null)"
	b="${b##refs/heads/}"
    if [ -n "$b" ]; then
		rev=$(git log --pretty=format:'%h' -n 1)
		if [ $b == "master" ]; then
			c=$Blue
		else
			c=$Yellow
		fi
        printf " $c(%s %s)$Color_Off " "$b" "$rev";
    fi
}

function _prompt_command
{
	files=$(_update_tree '*')
	_complete_ff

	hidden=$(_update_tree '.')
	_complete_fh
}

_prompt_command
PROMPT_COMMAND="_prompt_command"
PS1="\n\[${Red}\]\u@\h: \w\$(__git_ps1)\n\[${Blue}\]>>\[${Color_Off}\] "

# User specific aliases and functions

alias st="svn st | \
perl -pe 's/^M.*$/${Yellow}$&${Color_Off}/g' | \
perl -pe 's/^A.*$/${IPurple}$&${Color_Off}/g' | \
perl -pe 's/^C.*$/${Red}$&${Color_Off}/g' | \
perl -pe 's/^\?.*$/${Blue}$&${Color_Off}/g' | \
perl -pe 's/^D.*$/${BRed}$&${Color_Off}/g'"

#git config --global alias.lg "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

alias ll='ls -al'

# Typo list for use with qwerty keyboard

alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'
alias lk='ll'
alias lks='ls'
alias ks='ls'

# Functions

# set editor to your fav
export EDITOR=/usr/bin/vim

# returns the list of files based on the arg given
# . returns all files including hidden
# * returns all normal files
function _update_tree
{
	echo $(find $* -type f -print | awk -F"/" '{print $NF}')
}

# find files of arg skipping files with svn in the name
# also gives a list if more that one file is found
# and takes user input to ope the file
function ff() 
{
    local array=($(find * -type f -iname '*'$*'*' | grep -v svn))
	local count=${#array[@]}

	if [ "${count:-0}" -eq 1 ]; then
		$EDITOR $array
	elif [ "${count:-0}" -gt 1 ]; then
		i=1
		for value in "${array[@]}"; do
			echo -e "$i:\t$value"
			i=`expr $i + 1`

			mylist[$i]=$value
		done
		echo
		echo "Select the file you wish to open:"
		echo "(enter a non number to exit)"
		read input

		if [ "$input" -eq "$input" 2> /dev/null ]; then
			$EDITOR ${mylist[input]}
		fi
	fi
}

# returns the word list of files from the tree
function _auto_complete_file
{
	local file=$*

	local array=($file)
	local count=${#file[@]}

	if [ "${count:=0}" -gt 0 ]; then
		echo $files
	else
		echo ""
	fi
}

# add auto complete from find that shows the file names in the current tree
# when using the ff command and then allows you to fully auto complete
function _complete_ff
{
	complete -W "$(_auto_complete_file $files)" ff
}

# find hidden files as well.  Can be noisy so made a seperate function
function fh() 
{
    local array=($(find . -type f -iname '*'$*'*' | grep -v svn))
	local count=${#array[@]}

	if [ "${count:-0}" -eq 1 ]; then
		$EDITOR $array
	else
		for value in "${array[@]}"; do
			echo "$value"
		done
	fi
}

# add auto complete from find that shows the file names in the current tree
# when using the ff command and then allows you to fully auto complete
function _complete_fh
{
	complete -W "$(_auto_complete_fh $hidden)" fh
}

# (needs a recent version of egrep)
function f()
{
    OPTIND=1
    local case=""
    local usage="fstr: find string in files.
Usage: f [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
        i) case="-i " ;;
        *) echo "$usage"; return;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    find . -type f -name "${2:-*}" -print0 | \
    xargs -0 egrep --color=always -sn ${case} "$1" | egrep -v ".svn" 2>&-
}

complete -W "$(echo $(grep '^ssh ' ~/.bash_history | sort -u | sed 's/^ssh //'))" ssh

