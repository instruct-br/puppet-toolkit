#!/bin/bash

rsync -av --delete plugins/ "$HOME"/.vim || exit
cp -r vimrc "$HOME"/.vimrc
