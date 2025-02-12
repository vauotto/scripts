#!/bin/bash
PATH_TO_REPO="/c/HTML5/gitprojects/tasy"
BRANCH_TO_RESET="pre_main"

cd $PATH_TO_REPO

git checkout $BRANCH_TO_RESET
git fetch
git reset --hard origin/$BRANCH_TO_RESET