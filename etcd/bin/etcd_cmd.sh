#!/bin/bash

CMD="member list"
LOCAL_IP=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

if [[ $# > 0  ]]
then
    CMD=$1
fi

etcdctl --endpoints=https://${LOCAL_IP}:2379  \
        --ca-file=/etc/kubernetes/ssl/ca.pem   \
        --cert-file=/etc/etcd/ssl/etcd.pem     \
        --key-file=/etc/etcd/ssl/etcd.key      \
        ${CMD}
