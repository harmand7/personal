#!/bin/bash 
# author: harman dhunna
# local mac .bash_profile

# function title() {
#     if [ "$1" ]
#     then
#         unset PROMPT_COMMAND
#         echo -ne "\033]0;${*}\007"
#     else
#         export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'
#     fi
# }
# title

function slack(){
    echo "Opening Nordstrom.slack"
    open -a "/Applications/Google Chrome.app" https://nordstrom.slack.com/
    echo "Opening postcsse.slack"
    open -a "/Applications/Google Chrome.app" https://postcsse.slack.com/
}

function mkcd() {
    mkdir -p $1 && cd $1
}


#----------Amazon env variables----------------------------
export AWS_DEFAULT_REGION="us-west-2"
export AWS_PROFILE="nordstrom-federated"
export AWS_DEFAULT_PROFILE=$AWS_PROFILE
#----------------------------------------------------------
export GOPATH="/Users/aexd/code/go"
#----------------------------------------------------------

#----------ALIAS----------
alias http='which_http'
alias sherlock_name='sherlock_name'
alias sherlock_lan='sherlock_lan'
alias sherlock_group='sherlock_group'
alias gp='lazygit'
alias hgrep='hgrep'
alias egrep='/usr/bin/egrep --color=auto'
alias ll='ls -al'
alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
alias openJ='open /Applications/IntelliJ\ IDEA.app/'
alias goide='open /Applications/Gogland\ 1.0\ EAP.app/'
alias gitup="open /Applications/GitUp.app/"
alias sb="sb"
alias resetgit='echo "moving idea directory" && mv .idea ../ && echo "resetting and cleaning" && git reset --hard && git clean -f -d && echo "returning idea" && mv ../.idea .'
alias kec='echo -e "                               development  test        staging    prod4      prod3      prod2      production";knife environment compare development test staging prod4 prod3 prod2 production | grep $1'
alias switch_chefdk='ruby ~/code/switch_ruby/switch_chef.rb'
alias kl='kitchen list'
alias lk='list_kitchen'
alias kr='kd && kco && kv'
alias vgs='vagrant global-status'
alias sbp='subl ~/personal/bash_profile'
alias dal='dawslogin'
alias galias='git config --get-regexp alias'
alias giturl='git config --get remote.origin.url'
alias topc='top -o cpu'

alias dt='dockertest'
alias ct='containerTest'
#----------- END -----------

#----------- CHEF Kitchen -----------
function list_kitchen() {
    echo   $'\tkl = kitchen list
    \tkt    = kitchen test $@
    \tkc    = kitchen create $@
    \tkco   = kitchen converge $@
    \tkv    = kitchen verify $@
    \tkd    = kitchen destroy $@
    \tkr    = kithcen destroy $@ && kitchen converge $@
    \tvd    = vagrant destroy $@
    \tvgs   = vagrant global-status
    \tvdall = vgs | grep default | cut -d ' ' -f1 | xargs -L 1 vagrant destroy -f $1'
}

function sb() {
    source ~/personal/bash_profile
    source ~/.bash_profile 
}

function vdall() {
    vgs | grep default | cut -d ' ' -f1 | xargs -L 1 vagrant destroy -f $1
}

function kt() {
	kitchen test $@
}

function kr() {
	kithcen destroy $@ && kitchen converge $@
}

function kco() {
    kitchen converge $@
}

function kc() {
    kitchen create $@
}

function kd() {
	kitchen destroy $@
}

function vd() {
	vagrant destroy $@
}

function kv() {
    kitchen verify $@
}

function which_http() {
    curl -s https://httpstatuses.com/$1 | grep "title" | perl -pe 's/\<title\>(.*)\<\/title\>/$1/g'
}

function cb() {
    cd /Users/aexd/code/chef/$@
}

function gocd() {
    cd /Users/aexd/code/go/src/git.nordstrom.net/uis/$@
}

function ff() {
    foodcritic $@
}

function rc() {
    rubocop $@
}

function kns() {
    knife node show $1.nordstrom.net
}
#----------- END -----------

#----------- Docker Shortcuts -----------

function dockertest(){
    dkillall
    docker build -t datadog_bigip .
    docker run -d -v /var/run/docker.sock:/var/run/docker.sock:ro \
              -v /proc/:/host/proc/:ro \
              -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
              -e DD_API_KEY=e3304acd3aa1d64b7252f65a0ad8449c \
              datadog_bigip:latest
    # echo "Sleep 1"
    # sleep 1
    # echo "Sleep 2"
    # sleep 1
    # echo "Sleep 3"
    # sleep 1
    # containerTest
}

function containerTest(){
    container=`docker ps | grep -e "$1" | cut -d ' ' -f1 | head -2 | tail -1`
    docker exec -it $container /opt/datadog-agent/bin/agent/agent status
}

function dps(){
    docker ps
}

function dexec() {
    if [[ $# -ne 2 ]]; then
        echo "Please enter container name and command."
    else
        echo "$1"
        container=docker ps | grep $1 | cut -d ' ' -f1 
        docker exec -it $container $2
    fi
}

function dssh() {
    if [[ $# -ne 1 ]]; then
        echo "Please enter container image name."
    else
        container=`docker ps | grep -e "$1" | cut -d ' ' -f1 | head -n 1`
        echo "container image name: $1 : CONTAINER ID: $container"
        docker exec -it $container /bin/bash
    fi
}

function dsshl() {
    container=`docker ps | head -n 2 | tail -1 | awk '{print $1}'`
    name=`docker ps | head -n 2 | tail -1 | awk '{print $2}'`
    echo "container image name: $name : CONTAINER ID: $container"
    docker exec -it $container /bin/bash
}

function dkillexcept() {
    filter="$1|IMAGE"

    for container in $(docker ps | egrep -v -e $filter | cut -d ' ' -f1)
    do
        echo "Stopping container: $container"
        docker stop $container
    done
    # xargs -L 1 docker stop $1 
    # docker images | egrep -e 'none' | cut -d ' ' -f 3  
}

function dkillall() {
    docker ps | egrep -v -e 'IMAGE' | cut -d ' ' -f1 | xargs -L 1 docker stop $1
    # docker images | egrep -e 'none' | cut -d ' ' -f 3  
}

function dclean() {
   docker images | awk /'none/ {print 3}' | xargs -L 1 docker image rm -f $1
}

function dawslogin() {
    command=`aws ecr get-login --no-include-email --region us-west-2`
    resp=`$command`
    rc=$?; 
    if [[ $rc != 0 ]]; then 
        echo -e "\nFailed to log on to aws ecs docker registry" $rc; 
    else
        echo 'Logged into aws ecs docker registry.'
    fi
}
#----------- END -----------

function encrpt() {
    if [[ $# -lt 2 ]]; then
        outfile=$1.encrpt
    else
        outfile=$2
    fi
    echo "Encrypting file [$1] into [$outfile]"
    openssl aes-256-cbc -a -salt -in $1 -out $outfile
}

function decrypt() {
    if [[ $# -lt 2 ]]; then
        outfile=$1.decrypt
    else
        outfile=$2
    fi
    echo "Decrypting file [$1] into [$outfile]"
    openssl aes-256-cbc -d -a -in $1 -out $outfile
}

#-----------Sherlock Shortcuts-----------
function sherlock_lan() {
    user_not_found='User not found'
    user=$1
    # ldap_search_coomand='ldapsearch -x -W -D"CN=Dhunna\\, Harman,OU=Users,OU=Accounts,DC=nordstrom,DC=net" -H ldaps://10.1.82.144:636 -b"dc=nordstrom,dc=net" -s sub "(&(objectClass=user)(samaccountname=$user))"'
    if [[ $# -ne 1 ]]; then
        echo "Please enter user 4 letter lan id only."
    else
        result=$(curl -sk https://sherlock-api.nordstrom.net/api/v1/user/$user)
        # if [[ $result == *"$user_not_found"* ]]; then
        #     echo "User [" $user "] not found in sherlock-api. Checking ldap."
        #     result=$($ldap_search_coomand)
        # fi
        echo $result  | jq '.'
    fi
}

function sherlock_name() {
    local OPTIND n opt
    if [[ $# -lt 1 ]]; then
        echo "Please enter name."
    elif [[ -z "$2" ]]; then
        result=`curl -sk https://sherlock-api.nordstrom.net/api/v1/search/$1/`
    elif [[ -n "$2" ]]; then
        result=`curl -sk https://sherlock-api.nordstrom.net/api/v1/search/$1%20$2/`
    else
        echo "Command incorrect"
    fi
    echo $result | jq '.' 
    if [[ "${@: -1}" = '-n' ]]; then
        return
    fi

    read -p "Use the lan_id to get more info? (y/n) " more
    if [[ $more == [Yy]* ]]; then
        id=`echo $result | jq '.users[0].lanID' | sed 's/"//g'`
        sherlock_lan $id
    fi
}

function sherlock_group() {
    if [[ $# -lt 1 ]]; then
        echo "Please enter group name."
    else
    	group=$@
    	group=$( printf "%s\n" "$group" | sed 's/ /%20/g' )
        curl -sk https://sherlock-api.nordstrom.net/api/v1/group/$group | jq '.'
    fi
}

#----------- END -----------


function getTeamID() {
    ruby ~/personal/getTeamLANID.rb
}

function hgrep() {
	history | grep $1
}

function lazygit() {
    # current_branch=git branch | grep '\*' | cut -d ' ' -f2
    current_branch=`git rev-parse --abbrev-ref HEAD`
    git add .
    git commit -a -m "$1"
    git push origin $current_branch
    git status
}

complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | \
    sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh

#----------- END -----------


#-------Crypto tools------
#source ~/bin/java8-crypto-tools/install-crypto.sh
#----------- END -----------

HISTFILESIZE=10000000
HISTSIZE=10000000


export PATH=$PATH:$HOME/bin:\
$HOME/bin/apache-maven-3.3.9/bin:\
Documents/mongodb-osx-x86_64-enterprise-3.2.9/bin/:\
/usr/local/go/bin:\
/usr/bin/:\
/Library/Frameworks/Python.framework/Versions/3.6/bin:\
$HOME/.chefdk/gem/ruby/current\
$HOME/.rvm/bin

source ~/personal/lscolors
source ~/personal/.git-prompt.sh

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #
#                         P R O M P T                         #
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #

# function called every time the prompt needs to be rendered

function emoji_to_hex(){
    printf $1| hexdump -C | head -n 1 | cut -d' ' -f3 -f4 -f5 -f6 | sed -e 's/ /\\x/g'
}

function prompt_command() {

    # colors used in the prompt
    local   CYAN="\[\033[0;36m\]"
    local    RED="\[\033[0;31m\]"
    local PURPLE="\[\033[0;35m\]"
    local  GREEN="\[\033[0;32m\]"
    local  RESET="\[\033[;0m\]"

    local BRANCH
    local BRANCH_COL=$GREEN
    
    # if a git repo, add the current branch
    if git status &>/dev/null; then
        if git status -uno -s | grep -q . ; then
            BRANCH_COL=$RED
        fi
        BRANCH="[$(git branch | sed -n 's/* //p')] "
    fi

    PS1='$(if [[ $? == 0 ]]; then printf "\xf0\x9f\x8d\x91 "; else printf "\xf0\x9f\x8c\xb6  "; fi)\[\e[0m\]'

    # username
    PS1+="$RED\u"

    # only show '@host' if it's not my local machine
    if [[ "$HOSTNAME" != "M-C02X5A78JG5J"* ]]; then
        PS1+="$CYAN@$GREEN\h"
    fi
    # :DIRECTORY_HEAD [branch] >
    PS1+="$RED:$PURPLE\w $BRANCH_COL$BRANCH$RED> $RESET" 
    export PS1

    # local prmpt="$USER:${PWD##*/}"
    # local prmpt_len=${#prmpt}

    # local spaces=('%*s' "$prmpt_len" | tr ' ' "#")

    # multiline commands
    PS2="$spaces$RED ├─>$RESET "
    export PS2

}

# run the function prompt_command when building prompt
PROMPT_COMMAND='prompt_command'

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #

# GIT_PROMPT_ONLY_IN_REPO=1
# source ~/personal/bash-git-prompt/gitprompt.sh


#SET DOCKER HOST:
export DOCKER_HOST=unix:///var/run/docker.sock

#--------JAVA HOME--------
# when java is updated set the path
export JDK_VERSION=`java -version 2>&1 |grep java | cut -f2 -d'"'`
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk${JDK_VERSION}.jdk/Contents/Home"
#----------- END -----------

#------bash_completion----
if [ -f /Users/aexd/.git-completion.bash ]; then
    . /Users/aexd/.git-completion.bash
fi
#----------- END -----------

# GIT_PROMPT_ONLY_IN_REPO=1
# source ~/personal/bash-git-prompt/gitprompt.sh

# PERL Paths
PATH="/Users/aexd/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/aexd/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/aexd/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/aexd/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/aexd/perl5"; export PERL_MM_OPT;

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH
# eval "$(chef shell-init bash)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/aexd/Downloads/google-cloud-sdk/path.bash.inc' ]; then source '/Users/aexd/Downloads/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/aexd/Downloads/google-cloud-sdk/completion.bash.inc' ]; then source '/Users/aexd/Downloads/google-cloud-sdk/completion.bash.inc'; fi
