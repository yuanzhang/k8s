#!/bin/bash

yum remove -y vim
yum install -y vim

cp ../etc/vimrc ~/.vimrc

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "alias vi='vim'" >> ~/.bashrc

#:PluginInstall
