#!/bin/bash

yum remove -y vim
yum install -y vim

cp ../etc/vimrc ~/.vimrc

