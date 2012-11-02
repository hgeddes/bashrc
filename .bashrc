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

export HISTCONTROL=ignoreboth

# data

KILOBYTE=1024

KILOBYTE_SUFFIX="kB"
MEGABYTE_SUFFIX="MB"

TOTAL_PROC=`cat /proc/cpuinfo | grep processor | wc -l`
HARDWARE_ARCH=`uname -m`

# Prompt

#0.20 0.18 0.12 1/80 11206
#The first three columns measure CPU and IO utilization of the last one, five, and 10 minute periods. The fourth column shows the number of currently running processes and the total number of processes. The last column displays the last process ID used.

function my_command_prompt()
{
    #this is a local function for local variables.  We'll have no trouble here
    local LOAD_AVG=$(< /proc/loadavg)
    local LOAD_AVG_1=`echo $LOAD_AVG | awk '{print $1}'`
    local LOAD_AVG_5=`echo $LOAD_AVG | awk '{print $2}'`
    local LOAD_AVG_10=`echo $LOAD_AVG | awk '{print $3}'`
    
    local UPTIME=$(< /proc/uptime)
    local UPTIME=${UPTIME%%.*}
    local UP_SECONDS=$(( UPTIME%60 ))
    local UP_MINUTES=$(( UPTIME/60%60 ))
    local UP_HOURS=$(( UPTIME/60/60%24 ))
    local UP_DAYS=$(( UPTIME/60/60/24 ))

    local FREE_MEM=$(( `sed -nu "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/${KILOBYTE} ))
    local TOTAL_MEM=$(( `sed -nu "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/${KILOBYTE} ))
    local MEM_PERCENT=`echo $FREE_MEM $TOTAL_MEM | awk '{printf "%d",($1/$2)*100}'`

    if [ $MEM_PERCENT -ge "90" ] ; then
        MEM_COLOR=$Red
    elif [ $MEM_PERCENT -ge "75" ] ; then
        MEM_COLOR=$Yellow
    else
        MEM_COLOR=$Blue
    fi

    if [ $(expr $LOAD_AVG_1 \> $TOTAL_PROC) -eq "1" ]; then
        local LOAD_1_COLOR=$Red
    elif [ $(expr $LOAD_AVG_1 \> $(echo $TOTAL_PROC | awk '{printf "%d",($1*0.75)}') ) -eq "1" ]; then
        local LOAD_1_COLOR=$Yellow
    else
        local LOAD_1_COLOR=$Blue
    fi

    if [ $(expr $LOAD_AVG_5 \> $TOTAL_PROC) -eq "1" ]; then
        local LOAD_5_COLOR=$Red
    elif [ $(expr $LOAD_AVG_5 \> $(echo $TOTAL_PROC | awk '{printf "%d",($1*0.75)}') ) -eq "1" ]; then
        local LOAD_5_COLOR=$Yellow
    else
        local LOAD_5_COLOR=$Blue
    fi

    if [ $(expr $LOAD_AVG_10 \> $TOTAL_PROC) -eq "1" ]; then
        local LOAD_10_COLOR=$Red
    elif [ $(expr $LOAD_AVG_10 \> $(echo $TOTAL_PROC | awk '{printf "%d",($1*0.75)}') ) -eq "1" ]; then
        local LOAD_10_COLOR=$Yellow
    else
        local LOAD_10_COLOR=$Blue
    fi

    history -a
    echo -en "\n${UGreen}Mem${Green}: ${MEM_COLOR}[$MEM_PERCENT%] ${Green}[${Blue}$FREE_MEM/$TOTAL_MEM$MEGABYTE_SUFFIX${Green}]\t${UGreen}Load${Green}: [${LOAD_1_COLOR}$LOAD_AVG_1 ${LOAD_5_COLOR}$LOAD_AVG_5 ${LOAD_10_COLOR}$LOAD_AVG_10${Green}]\t${UGreen}Sys${Green}: [${Blue}$KERNEL_V $HARDWARE_ARCH $TOTAL_PROC $UP_DAYS:$UP_HOURS:$UP_MINUTES:$UP_SECONDS${Green}]"
}

# Linux version 2.6.21.7-2.fc8xen (mockbuild@xenbuilder4.fedora.phx.redhat.com) (gcc version 4.1.2 20070925 (Red Hat 4.1.2-33)) #1 SMP Fri Feb 15 12:34:28 EST 2008
KERNEL_V=`cat /proc/version | awk '{print $3}'`

UPTIME=$(< /proc/uptime)
UPTIME=${UPTIME%%.*}
UP_SECONDS=$(( UPTIME%60 ))
UP_MINUTES=$(( UPTIME/60%60 ))
UP_HOURS=$(( UPTIME/60/60%24 ))
UP_DAYS=$(( UPTIME/60/60/24 ))
LOAD_AVG=$(< /proc/loadavg)
LOAD_AVG_1=`echo $LOAD_AVG | awk '{print $1}'`
LOAD_AVG_5=`echo $LOAD_AVG | awk '{print $2}'`
LOAD_AVG_10=`echo $LOAD_AVG | awk '{print $3}'`

FREE_MEM=$(( `sed -nu "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/${KILOBYTE} ))
TOTAL_MEM=$(( `sed -nu "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/${KILOBYTE} ))
MEM_PERCENT=`echo $FREE_MEM $TOTAL_MEM | awk '{printf "%d",($1/$2)*100}'`

SYSTEM='history -a; echo -en "\n${Color_Off}${Green}[Mem: ${MEM_COLOR}[$MEM_PERCENT%] ${Purple}$FREE_MEM/$TOTAL_MEM MB ${Green}]\t[Load: ${LOAD_1_COLOR}$LOAD_AVG_1 ${LOAD_5_COLOR}$LOAD_AVG_5 ${LOAD_10_COLOR}$LOAD_AVG_10${Green}]${Color_Off}\t[Hardware: ${Purple}$KERNEL_V $TOTAL_PROC $HARDWARE_ARCH $UP_DAYS:$UP_HOURS:$UP_MINUTES:$UP_SECONDS${Green}]\n${Color_Off}"'
#PROMPT_COMMAND='history -a;echo -en "\n\033[m\033[38;5;2m"$(( `sed -nu "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/1024))"\033[38;5;22m/"$((`sed -nu "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/1024 ))MB"\t\033[m\033[38;5;55m$(< /proc/loadavg)\033[m"'
PROMPT_COMMAND=my_command_prompt

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

PS1="\n\[${Red}\]\u@\h: \w\n\[${Blue}\]>>\[${Color_Off}\] "
export PS1

# User specific aliases and functions

ERROR_LOG_LOC="/home/hgeddes/httpd_logs/*error*"
ACCESS_LOG_LOC="/home/hgeddes/httpd_logs/*access*"

alias elog=my_error_log
alias alog=my_access_log
alias gohome='USER=`whoami`;cd /home/$USER'
alias rstart='sudo /etc/init.d/httpd restart'
alias size='du -kh --max-depth=1'

alias sys="echo $SYSTEM"
alias system="echo $SYSTEM"

alias stage_log="tail -f /var/log/httpd/*error*"
alias prod_log="tail -f /var/log/httpd/*error*"

#alias myst="svn st | grep -v '^X' | sed -e 's/^\?.*$/$Green\0$Color_Off/g' -e 's/^!.*$/$Blue\0$Color_Off/g' -e 's/^A.*$/${Blue}\0${Color_Off}/g' -e 's/^M.*$/${Yellow}\0${Color_off}/g' -e 's/^D.*$/${Red}\0${Color_off}/g'"

alias st="svn st | \
perl -pe 's/^M.*$/${Yellow}$&${Color_Off}/g' | \
perl -pe 's/^A.*$/${IPurple}$&${Color_Off}/g' | \
perl -pe 's/^C.*$/${Red}$&${Color_Off}/g' | \
perl -pe 's/^\?.*$/${Blue}$&${Color_Off}/g' | \
perl -pe 's/^D.*$/${BRed}$&${Color_Off}/g'"

#git config --global alias.lg "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

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

function my_error_log()
{
    tail -f $ERROR_LOG_LOC | sed 's/\\n/\n/g; s/, referer: .*$//g'
}

function my_access_log()
{
    tail -f $ACCESS_LOG_LOC
}

# find files of arg skipping files with svn in the name
function ff() 
{ 
    find . -type f -iname '*'$*'*' | grep -v svn ; 
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

