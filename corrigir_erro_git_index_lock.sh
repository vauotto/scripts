#!/bin/bash

# esse script corrige o erro: Another git process seems to be running in this repository
# Another git process seems to be running in this repository, e.g. an editor opened by 'git commit'. 
# Please make sure all processes are terminated then try again. If it still fails, a git process may
# have crashed in this repository earlier: remove the file manually to continue.

PATH_TO_REPO="/c/HTML5/gitprojects/tasy"

cd $PATH_TO_REPO
rm -f .git/index.lock