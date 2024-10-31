#!/bin/bash

function starting () {
    echo "$1 …"
}

function isdone () {
   echo " … done!"
   echo ""
}

function warn () {
    level="W"

    local caller_info=$(caller 0)
    if [[ $caller_info == *"die"* ]]; then
       level="E"
    fi

    echo "[$level] $1" 1>&2
}

function die () {
    warn "$1"
    exit -1
}

function ensure_git () {
    starting "Ensuring git repo"

    git --version
    if [ "$?" -ne 0 ]; then
        die "Install \`git\` and try again"
    fi

    if [ -d ~/.vim/pack/github/start/copilot.vim ]; then
        git -C ~/.vim/pack/github/start/copilot.vim pull
    else
        git clone https://github.com/github/copilot.vim.git ~/.vim/pack/github/start/copilot.vim
    fi

    # https://github.com/github/copilot.vim/pull/44 womp womp
    if [ ! -s ~/.vim/pack/github/start/copilot.vim/vim-copilot-setup.vim ]; then
        echo "Ensuring ~/.vim/pack/github/start/copilot.vim/vim-copilot-setup.vim"
        echo "Copilot setup" > ~/.vim/pack/github/start/copilot.vim/vim-copilot-setup.vim
    fi

    isdone
}

function check_prereq () {
    starting "Checking prereqs"

    min_vim=9
    min_node=18

    vim_ver=$(vim --version | head -n 1 | awk '{print $5}')
    if [[ $(echo "$vim_ver < $min_vim" | bc -l) -eq 1 ]]; then
       die "need vim version $min_vim or newer"
    fi

    node_ver=$(node -v | awk -F. '{print $1}' | sed 's/^v//')
    if [[ "$node_ver" -lt "$min_node" ]]; then
        die "need node version $min_node or newer"
    fi

    isdone
}

function do_setup () {
    starting "Initializing set up"

    vim -S ~/.vim/pack/github/start/copilot.vim/vim-copilot-setup.vim

    isdone
}

function run () {
    ensure_git
    check_prereq
    do_setup # or only do first time (if cloned) or when given --setup?

    echo "For more info:"
    echo "  * \`cat ~/.vim/pack/github/start/copilot.vim/doc/copilot.txt\`"
    echo "  * \`:help copilot\` for more information."
}

run
