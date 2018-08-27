#!/bin/bash 
# author: harman dhunna
# local mac .bash_profile

function title() {
    if [ "$1" ]
    then
        unset PROMPT_COMMAND
        echo -ne "\033]0;${*}\007"
    else
        export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'
    fi
}
title

function slack(){
    echo "Opening Nordstrom.slack"
    open -a "/Applications/Google Chrome.app" https://nordstrom.slack.com/
    echo "Opening postcsse.slack"
    open -a "/Applications/Google Chrome.app" https://postcsse.slack.com/
}

function mkcd() {
    mkdir -p $1 && cd $1
}


###########################################################
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
alias sb="source ~/profile/bash_profile"
alias resetgit='echo "moving idea directory" && mv .idea ../ && echo "resetting and cleaning" && git reset --hard && git clean -f -d && echo "returning idea" && mv ../.idea .'
alias kec='echo -e "                               development  test        staging    prod4      prod3      prod2      production";knife environment compare development test staging prod4 prod3 prod2 production | grep $1'
alias switch_chefdk='ruby ~/code/switch_ruby/switch_chef.rb'
alias kl='kitchen list'
alias lk='list_kitchen'
alias kr='kd && kco && kv'
alias vgs='vagrant global-status'
alias sbp='subl ~/profile/bash_profile'
alias dal='dawslogin'
alias galias='git config --get-regexp alias'
#-----------END-----------

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

######DOCKER SHORT CUTS ##########
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
        echo "Please enter container name."
    else
        container=`docker ps | grep -e "$1" | cut -d ' ' -f1 | head -n 1`
        echo "container name: $1 : CONTAINER ID: $container"
        docker exec -it $container /bin/bash
    fi
}

function dkill() {
    docker ps | egrep -v -e 'jetbridge|IMAGE' | cut -d ' ' -f1 | xargs -L 1 docker stop $1
    docker images | egrep -e 'none' | cut -d ' ' -f 3  
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

function sherlock_lan() {
    user_not_found='User not found'
    user=$1
    ldap_search_coomand='ldapsearch -x -W -D"CN=Dhunna\\, Harman,OU=Users,OU=Accounts,DC=nordstrom,DC=net" -H ldaps://10.1.82.144:636 -b"dc=nordstrom,dc=net" -s sub "(&(objectClass=user)(samaccountname=$user))"'
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

function getTeamID() {
    ruby ~/profile/getTeamLANID.rb
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

#-------Crypto tools------
#source ~/bin/java8-crypto-tools/install-crypto.sh
#-----------END-----------

HISTFILESIZE=10000000
HISTSIZE=10000000

source ~/profile/lscolors

export PATH=$PATH:/Users/aexd/bin:/Users/aexd/bin/apache-maven-3.3.9/bin:Documents/mongodb-osx-x86_64-enterprise-3.2.9/bin/:/usr/local/go/bin:/usr/bin/:/Library/Frameworks/Python.framework/Versions/3.6/bin:/Users/aexd/.chefdk/gem/ruby/current


source ~/.git-prompt.sh

function color_my_prompt() {
    local __user_and_host="\[\033[01;32m\]\u@\h"
    local __cur_location="\[\033[01;34m\]\w"
    local __git_branch_color="\[\033[31m\]"
    local __git_branch='$(__git_ps1 " (%s)")'
    local __prompt_tail="\[\033[35m\]$"
    local __last_color="\[\033[00m\]"
    export PS1="$__user_and_host $__cur_location $__git_branch_color$__git_branch\n$__prompt_tail$__last_color "
}
color_my_prompt


#SET DOCKER HOST:
export DOCKER_HOST=unix:///var/run/docker.sock

#--------JAVA HOME--------
# when java is updated set the path
export JDK_VERSION=`java -version 2>&1 |grep java | cut -f2 -d'"'`
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk${JDK_VERSION}.jdk/Contents/Home"
#-----------END-----------

#------bash_completion----
if [ -f /Users/aexd/.git-completion.bash ]; then
    . /Users/aexd/.git-completion.bash
fi
#-----------END-----------


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
