#!/bin/bash
set -e

if [[ $# < 1  ]] 
then
    echo "run as: sh master_install.sh  'https:\/\/172.17.77.90:2379,https:\/\/172.17.181.176:2379,https:\/\/172.17.181.177:2379' "
    echo "params 1: etcd servers"
    exit
fi


## 生成配置文件
sh install/config_install.sh


## 拷贝配置到/etc/kubernetes
ETCD_SERVERS=$1
HOSENAME=`hostname`
LOCAL_IP=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
MASTER_IP=${LOCAL_IP}
ETC=../etc/etc-kubernetes
TMP_DIR=master_tmp

API_SERVER=${ETC}/apiserver
TMP_API_SERVER=${TMP_DIR}/apiserver
CONTROLLER_MAN=${ETC}/controller-manager
TMP_CONTROLLER_MAN=${TMP_DIR}/controller-manager
KUBELET=${ETC}/kubelet
TMP_KUBELET=${TMP_DIR}/kubelet
PROXY=${ETC}/proxy
TMP_PROXY=${TMP_DIR}/proxy
SCHEDULER=${ETC}/scheduler
TMP_SCHEDULER=${TMP_DIR}/scheduler
CONFIG=${ETC}/config
TMP_CONFIG=${TMP_DIR}/config

rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}
cp ${API_SERVER} ${TMP_DIR}/
cp ${CONTROLLER_MAN} ${TMP_DIR}/
cp ${KUBELET} ${TMP_DIR}/
cp ${PROXY} ${TMP_DIR}/
cp ${SCHEDULER} ${TMP_DIR}/
cp ${CONFIG} ${TMP_DIR}/

sed -i "s/{\$BIND_ADDRESS}/${LOCAL_IP}/g" ${TMP_API_SERVER}
sed -i "s/{\$ETCD_SERVERS}/${ETCD_SERVERS}/g" ${TMP_API_SERVER}
sed -i "s/{\$MASTER}/${MASTER_IP}/g" ${TMP_CONTROLLER_MAN}
sed -i "s/{\$HOSTNAME}/${HOSTNAME}/g" ${TMP_KUBELET}
sed -i "s/{\$BIND_ADDRESS}/${LOCAL_IP}/g" ${TMP_PROXY}
sed -i "s/{\$MASTER_IP}/${MASTER_IP}/g" ${TMP_CONFIG}

cp ${TMP_DIR}/* /etc/kubernetes/ -rf
rm -rf ${TMP_DIR}



## key文件
KEY_DIR=../key
cp ${KEY_DIR}/* /etc/kubernetes/ssl/ -rf


## 后续设置
sh install/tail_install.sh
sh install/tools_install.sh


## systemctl配置
SYSTEMCTL_DIR=../etc/systemctl/
SYSTEM_DIR=/usr/lib/systemd/system/
cp ${SYSTEMCTL_DIR}/kube-apiserver.service ${SYSTEM_DIR}
cp ${SYSTEMCTL_DIR}/kube-controller-manager.service ${SYSTEM_DIR}
cp ${SYSTEMCTL_DIR}/kube-proxy.service ${SYSTEM_DIR}
cp ${SYSTEMCTL_DIR}/kube-scheduler.service ${SYSTEM_DIR}
cp ${SYSTEMCTL_DIR}/kubelet.service ${SYSTEM_DIR}


## 启动服务
systemctl daemon-reload
for k in kube-apiserver \
    kube-controller-manager \
    kube-scheduler \
    kubelet \
    kube-proxy 
do  systemctl start  $k; 
    systemctl enable $k;
    systemctl status $k -l;
done

