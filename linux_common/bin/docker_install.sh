#!/bin/bash

yum -y remove docker docker-common docker-selinux docker-engine docker-engine-selinux container-selinux docker-ce

rm -rf /var/lib/docker

yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#yum list installed | grep docker
yum install -y docker-ce-18.06.0.ce

service docker start
