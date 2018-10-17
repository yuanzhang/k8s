#!/bin/bash

TMP_DIR=config_tmp
KEY_DIR=../key
KEY_DIR_BACKUP=../key_backup
MASTER_IP=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
MASTER_IP=172.17.77.90
KUBERNETES_CONF=../etc/kubernetes/
TOKEN=token.csv

rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}
cd ${TMP_DIR}

########## 生成Token文件##########
echo "`head -c 16 /dev/urandom | od -An -t x | tr -d ' '`,kubelet-bootstrap,10001,\"system:kubelet-bootstrap\"" > ${TOKEN}


########## 生成kubectl的kubeconfig文件 ##########
# 设置集群参数
kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/ssl/ca.pem \
    --server=https://${MASTER_IP}:6443
# 设置客户端认证参数
kubectl config set-credentials admin \
    --client-certificate=/etc/kubernetes/ssl/kubelet.pem \
    --client-key=/etc/kubernetes/ssl/kubelet.key
# 设置上下文参数
kubectl config set-context kubernetes \
    --cluster=kubernetes \
    --user=admin
kubectl config use-context kubernetes


##########  生成kubelet的bootstrapping kubeconfig文件 ##########
# 生成kubelet的bootstrapping kubeconfig文件
kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/ssl/ca.pem \
    --server=https://${MASTER_IP}:6443 \
    --kubeconfig=bootstrap.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
    --token=`awk -F ',' '{print $1}' token.csv` \
    --kubeconfig=bootstrap.kubeconfig
# 生成默认上下文参数
kubectl config set-context default \
    --cluster=kubernetes \
    --user=kubelet-bootstrap \
    --kubeconfig=bootstrap.kubeconfig

# 切换默认上下文
kubectl config use-context default \
    --kubeconfig=bootstrap.kubeconfig


########## 生成kubelet的 kubeconfig 文件 ##########
# 生成kubelet的 kubeconfig 文件
# 设置集群参数
kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/ssl/ca.pem \
    --server=https://${MASTER_IP}:6443 \
    --kubeconfig=kubelet.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kubelet \
    --client-certificate=/etc/kubernetes/ssl/kubelet.pem \
    --client-key=/etc/kubernetes/ssl/kubelet.key \
    --kubeconfig=kubelet.kubeconfig
# 生成上下文参数
kubectl config set-context default \
    --cluster=kubernetes \
    --user=kubelet \
    --kubeconfig=kubelet.kubeconfig
# 切换默认上下文
kubectl config use-context default \
    --kubeconfig=kubelet.kubeconfig

########## 生成kube-proxy的 kubeconfig 文件 ##########
# 设置集群参数
kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/ssl/ca.pem \
    --server=https://${MASTER_IP}:6443 \
    --kubeconfig=kube-proxy.kubeconfig  
# 设置客户端认证参数
kubectl config set-credentials kube-proxy \
    --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
    --client-key=/etc/kubernetes/ssl/kube-proxy.key \
    --kubeconfig=kube-proxy.kubeconfig
# 生成上下文参数
kubectl config set-context default \
    --cluster=kubernetes \
    --user=kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig
# 切换默认上下文
kubectl config use-context default \
    --kubeconfig=kube-proxy.kubeconfig


cp kubelet.kubeconfig bootstrap.kubeconfig kube-proxy.kubeconfig /etc/kubernetes/
cp kubelet.kubeconfig bootstrap.kubeconfig kube-proxy.kubeconfig ../${KUBERNETES_CONF}
cp ${TOKEN} /etc/kubernetes/

cd ../
rm -rf ${TMP_DIR}
