#!/bin/bash

if [[ $# < 1 ]] 
then
	echo "run as: sh install.sh 'https:\/\/192.168.50.55:2379,https:\/\/192.168.50.56:2379,https:\/\/192.168.50.57:2379' "
	echo "params 1: etcd endpoints"
	exit
fi


yum remove -y flannel
yum install -y flannel

ETCD_PREFIX="/k8s/network"
ETCD_ENDPOINTS=$1
LOCAL_IP=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
fn=flanneld
TMP_DIR=perm_tmp
FLANNEL_CNF=flannel.cnf
K8S_KEY_DIR=../../../k8s/key
FLANNEL_OPTIONS="-etcd-cafile=/etc/kubernetes/ssl/ca.pem -etcd-certfile=/etc/kubernetes/ssl/flanneld.pem -etcd-keyfile=/etc/kubernetes/ssl/flanneld.key"
FLANNEL_CONFIG=/etc/sysconfig/flanneld

rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}
cd ${TMP_DIR}
cp ../../etc/${FLANNEL_CNF} .
cp ${K8S_KEY_DIR}/ca.pem .
cp ${K8S_KEY_DIR}/ca.key .
sed -i "s/{\$LOCAL_IP}/${LOCAL_IP}/g" ${FLANNEL_CNF}

openssl genrsa -out $fn.key 3072
openssl req -new -key $fn.key -out $fn.csr -subj "/CN=flanneld/OU=System/C=CN/ST=Shanghai/L=Shanghai/O=k8s" -config flannel.cnf
openssl x509 -req -CA ca.pem -CAkey ca.key -CAcreateserial -in $fn.csr -out $fn.pem -days 1095 -extfile flannel.cnf -extensions v3_req

sed -i "s/http:\/\/127.0.0.1:2379/${ETCD_ENDPOINTS}/g"  ${FLANNEL_CONFIG}
sed -i "s/atomic.io/k8s/g"  ${FLANNEL_CONFIG}
echo FLANNEL_OPTIONS="${FLANNEL_OPTIONS}" >> ${FLANNEL_CONFIG}

cp $fn.key $fn.pem /etc/kubernetes/ssl -f

cd ..
rm -rf ${TMP_DIR}

systemctl daemon-reload
systemctl start flanneld
systemctl enable flanneld
systemctl status flanneld -l
