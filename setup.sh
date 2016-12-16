#!/bin/bash

RESTORE='\e[0m'
YELLOW='\e[00;33m'

dotfilesDirectory=$(dirname $0)
dotfilesDirectory="`( cd \"$dotfilesDirectory\" && pwd )`"
files=`find $dotfilesDirectory -maxdepth 1 -type f -printf "%f\n" | egrep '^\.'`

for file in $files; do
    echo -e $YELLOW"Creating symlink for $file"$RESTORE
    ln -sf $dotfilesDirectory/$file ~/$file
done

#cd vim
#./setup.sh

echo -e "\nNow you have to run 'source ~/.bashrc'"
