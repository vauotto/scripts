#!/bin/bash

# Constants
VERSIONS_FILE=~/versions.txt

# Functions

generateTableHeader() {
    echo "|**tool**|**version**|"
}

generateImageTable() {
    generateTableHeader

    versionCommands=(
        "$(git --version | awk '{print "| " $1 " | " $3 " |"; exit}')"
        "$(gh --version | awk '{print "| " $1 " | " $3 " |"; exit}')"
        "$(pwsh --version | awk '{print "| " $1 " | " $2 " |"; exit}')"
        "$(curl --version | awk '{print "| " $1 " | " $2 " |"; exit}')"
        "$(unzip | awk '{print "| " $1 " | " $2 " |"; exit}')"
        "$(nano --version | awk '{print "| " "nano" " | " $4 " |"; exit}')"
        "$(pyenv --version | awk '{print "| " $1 " | " $2 " |"; exit}')"
        "$(nvm --version > /dev/null && echo "| nvm | $(nvm --version) |")"
        "$(jabba --version > /dev/null && echo "| jabba | $(jabba --version) |")"
    )

    for command in "${versionCommands[@]}"; do 
        if [[ -n $command && $command != "||" ]]; then 
            echo "$command"
        fi
    done 
}

main () {
    rm -f $VERSIONS_FILE 2> /dev/null
    touch $VERSIONS_FILE

    generateImageTable 2> /dev/null

    exit 0
}

# run main 
main 