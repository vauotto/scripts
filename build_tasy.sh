#!/bin/bash

tasy="/c/HTML5/gitprojects/tasy"

cd $tasy 

echo "Using node version 14"
nvm use 14

echo "Building tasy"
npm run build && npm run war 
