#!/bin/bash

# install kube-dns
ETC=../etc/
BIN=`pwd`

for conf in `find ${ETC} -name 'kubedns*'`
do
    kubectl create -f ${conf}
done

echo 'sleep 10s ..'

sleep 10

# 项目使用了jq命令，需要安装jq程序
rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install jq

# 安装coredns
./coredns_deploy.sh -i 10.128.0.2 | kubectl apply -f -

# 工具安装
yum -y install conntrack-tools
