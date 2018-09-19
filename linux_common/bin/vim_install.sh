#!/bin/bash

CUR_DIR=`pwd`

yum remove -y vim
yum install ncurses-devel -y
yum install -y python-devel
cd /usr/local/src/
wget https://codeload.github.com/vim/vim/tar.gz/v8.0.0134
tar zxf v8.0.0134
cd vim-8.0.0134/
./configure --with-features=huge -enable-pythoninterp=yes
make && make install

cp ${CUR_DIR}
cp ../etc/vimrc ~/.vimrc

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "alias vi='/usr/local/bin/vim'" >> ~/.bashrc
source ~/.bashrc

#:PluginInstall
