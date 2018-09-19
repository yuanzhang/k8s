#!/bin/bash

LOCAL_IP=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

etcdctl --endpoints=https://${LOCAL_IP}:2379 \
                        --ca-file=/etc/kubernetes/ssl/ca.pem \
                        --cert-file=/etc/etcd/ssl/etcd.pem \
                        --key-file=/etc/etcd/ssl/etcd.key \
                        mkdir /k8s/network


etcdctl --endpoints=https://${LOCAL_IP}:2379 \
                        --ca-file=/etc/kubernetes/ssl/ca.pem \
                        --cert-file=/etc/etcd/ssl/etcd.pem \
                        --key-file=/etc/etcd/ssl/etcd.key \
                        set /k8s/network/config '{"Network": "10.64.0.0/10","Backend": {"Type": "vxlan"}}'

etcdctl --endpoints=https://${LOCAL_IP}:2379 \
                        --ca-file=/etc/kubernetes/ssl/ca.pem \
                        --cert-file=/etc/etcd/ssl/etcd.pem \
                        --key-file=/etc/etcd/ssl/etcd.key \
			get /k8s/network/config


#设置 Kubernetes 集群网络为 10.64.0.0/10, 模式为 vxlan, 可用IP数量 4,194,304
