#!/bin/bash

# 卸载旧版本
sudo yum remove docker  docker-common docker-selinux docker-engine

# 依赖包
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 设置源
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 查找所有docker版本
yum list docker-ce --showduplicates | sort -r

# 安装
sudo yum install docker-ce
#sudo yum install docker-ce-17.12.0.ce

# 启动
sudo systemctl start docker
sudo systemctl enable docker
