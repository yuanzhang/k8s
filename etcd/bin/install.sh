#!/bin/bash

# init
TMP_DIR=etcd_perm_tmp
rm -rf $TMP_DIR
mkdir $TMP_DIR
cd $TMP_DIR

ETCD_CNF=etcd.cnf
LOCAL_IP=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
ETCD_CONF=etcd.conf
ETCD_FULL_CONF=../../etc/${ETCD_CONF}
ETCD_SERVICE=etcd.service
ETCD_FULL_SERVICE=../../etc/${ETCD_SERVICE}
K8S_KEY_DIR=../../../k8s/key


# 安装etcd
yum install -y etcd

# etcd 证书
cp ../../etc/${ETCD_CNF} .
sed -i "s/{\$ip1}/${LOCAL_IP}/g" $ETCD_CNF
cp ${K8S_KEY_DIR}/ca.pem .
cp ${K8S_KEY_DIR}/ca.key .
openssl genrsa -out etcd.key 3072
openssl req -new -key etcd.key -out etcd.csr -subj "/CN=etcd/OU=System/C=CN/ST=Shanghai/L=Shanghai/O=k8s" -config etcd.cnf
openssl x509 -req -in etcd.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out etcd.pem -days 1095 -extfile etcd.cnf -extensions v3_req
mkdir -p /etc/etcd/ssl
mkdir -p /etc/kubernetes/ssl
cp etcd.key etcd.pem /etc/etcd/ssl
cp ca.pem /etc/kubernetes/ssl

# etcd 服务配置
cp ${ETCD_FULL_CONF} .
sed -i "s/{\$LOCAL_IP}/${LOCAL_IP}/g" $ETCD_CONF
cp ${ETCD_CONF} /etc/etcd/
cp ${ETCD_FULL_SERVICE} /usr/lib/systemd/system/

systemctl daemon-reload
systemctl start etcd
systemctl enable etcd
