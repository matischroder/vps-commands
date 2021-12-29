#!/bin/bash

#RED='\033[1;31m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
normal=$(tput sgr0)
. ~/.nvm/nvm.sh

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}
testvercomp() {
    vercomp "$1" "$2"
    case $? in
    0) op='=' ;;
    1) op='>' ;;
    2) op='<' ;;
    esac
    if [[ $op != $3 ]]
     then
        echo "FAIL Expected '$3', Actual '$op', Arg1 '$1', Arg2 '$2'"
        bool=1
    else
        echo "Pass '$1 $op $2'"
        bool=0
    fi
    return "$bool"
}

export GO_VERSION=$(echo $(go version | grep -Po '(?<=version go)[^ ]+'))
export NVM_VERSION=$(echo $(nvm --version))
export NODE_VERSION=$(echo $(node --version | grep -Po '(?<=v)[^ ]+'))
export PYTHON_VERSION=$(echo $(python3 -c 'import sys; print(sys.version)' | awk 'NR==1{print $1}'))

bool=$?

testvercomp $GO_VERSION 1.17 \>
if [ $bool = 0 ]
then
    printf "${GREEN}Go version $GO_VERSION is up to date\n${normal}...\n"
else
    printf "${BLUE}Go version $GO_VERSION is outdated. Installing requiered version\n${normal}...\n"
    wget -N https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
    sudo su -c ./go-update.sh root
    export PATH=$PATH:/usr/local/go/bin
    printf "${GREEN}Go version: $(go version)\n${normal}...\n"
fi

testvercomp $NVM_VERSION 0.1.0 \>
if [ $bool = 0 ]
then
    printf "${GREEN}NVM version $NVM_VERSION is up to date\n${normal}...\n"
else
    printf "${BLUE}NVM version $NVM_VERSION is outdated. Installing requiered version\n${normal}...\n"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    source ~/.bashrc
    printf "${GREEN}NVM version: $(nvm --version)\n${normal}...\n"
fi

testvercomp $NODE_VERSION 12.22 \>
if [ $bool = 0 ]
then
    printf "${GREEN}NODE version $NPM_VERSION is up to date\n${normal}...\n"
else
    printf "${BLUE}NODE version $NPM_VERSION is outdated. Installing requiered version\n${normal}...\n"
    nvm install 12.22 && nvm use 12.22
    printf "${GREEN}NODE version: $(node --version)\n${normal}...\n"
fi

testvercomp $PYTHON_VERSION 3 \>
if [ $bool = 0 ]
then
    printf "${GREEN}Python version $PYTHON_VERSION is up to date\n${normal}...\n"
else
    printf "${BLUE}Python version $PYTHON_VERSION is outdated. Installing requiered version\n${normal}...\n"
    sudo apt update
    sudo apt install software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install python3.8
    printf "${GREEN}Python version: $(python3 --version)\n${normal}...\n"
fi