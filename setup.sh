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

if [ -d "`eval echo '~/.vim'`" ]; then
    echo -e $YELLOW"Pulling vim colorschemes"$RESTORE
    git -C ~/.vim pull
else
    echo -e $YELLOW"Cloning vim colorschemes"$RESTORE
    git clone https://github.com/flazz/vim-colorschemes.git ~/.vim
fi

echo -e "\nNow you have to run 'source ~/.bashrc'"
