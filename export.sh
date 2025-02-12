#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "erro: passe um arquivo como entrada"
  exit 1
fi

mkdir -p ~/bin

file=$1

yes | cp -rf $file ~/bin