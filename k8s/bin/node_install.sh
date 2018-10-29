#!/bin/bash
set -e
set -x

if [[ $# < 2  ]] 
then
    echo "run as: sh node_install.sh {master_ip} {https:\/\/172.17.77.90:2379,https:\/\/172.17.181.176:2379,https:\/\/172.17.181.177:2379} "
    echo "params 1: etcd servers"
    exit
fi

## 停止服务
for k in kube-apiserver \
    kube-controller-manager \
    kube-scheduler \
    kubelet \
    kube-proxy 
do  
	systemctl stop  $k; 
done

## 拷贝配置文件
              
ETCD_SERVERS=$2
MASTER_IP=$1

HOSTNAME=`hostname`
LOCAL_IP=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
ETC=../etc/etc-kubernetes
KUBERNETES_ETC=../etc/kubernetes
TMP_DIR=node_tmp

KUBELET=${ETC}/kubelet
TMP_KUBELET=${TMP_DIR}/kubelet
PROXY=${ETC}/proxy
TMP_PROXY=${TMP_DIR}/proxy
CONFIG=${ETC}/config
TMP_CONFIG=${TMP_DIR}/config

rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}
cp ${KUBELET} ${TMP_DIR}/
cp ${PROXY} ${TMP_DIR}/
cp ${CONFIG} ${TMP_DIR}/

sed -i "s/{\$HOSTNAME}/${HOSTNAME}/g" ${TMP_KUBELET}
sed -i "s/{\$BIND_ADDRESS}/${LOCAL_IP}/g" ${TMP_PROXY}
sed -i "s/{\$MASTER_IP}/${MASTER_IP}/g" ${TMP_CONFIG}

cp ${TMP_DIR}/* /etc/kubernetes/ -rf
cp ${KUBERNETES_ETC}/* /etc/kubernetes/ -rf

## key文件
KEY_DIR=../key
cp ${KEY_DIR}/* /etc/kubernetes/ssl/ -rf


## systemctl配置
SYSTEMCTL_DIR=../etc/systemctl/
SYSTEM_DIR=/usr/lib/systemd/system/
cp ${SYSTEMCTL_DIR}/kube-proxy.service ${SYSTEM_DIR}
cp ${SYSTEMCTL_DIR}/kubelet.service ${SYSTEM_DIR}


## 后续设置
sh install/tail_install.sh
sh install/tools_install.sh

rm -rf ${TMP_DIR}

## 启动服务
systemctl daemon-reload

systemctl stop kubelet
systemctl start kubelet
systemctl enable kubelet
systemctl status kubelet -l

systemctl stop kube-proxy
systemctl start kube-proxy
systemctl enable kube-proxy
systemctl status kube-proxy -l

