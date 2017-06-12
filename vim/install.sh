#!/bin/bash

rsync -av --delete vim "$HOME"/.vim || exit
cp -r vimrc "$HOME"/.vimrc
