#!/bin/bash
# 创建鉴权证书

TMP_DIR=perm_tmp
KEY_DIR=../key
KEY_DIR_BACKUP=../key_backup

rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}
cd ${TMP_DIR}

########## ca 证书 ##########
cp ../../etc/certificate/ca.cnf .
# 创建ca key
openssl genrsa -out ca.key 3072
# 签发ca key
openssl req -x509 -new -nodes -key ca.key -days 1095 -out ca.pem -subj \
        "/CN=kubernetes/OU=System/C=CN/ST=Shanghai/L=Shanghai/O=k8s" \
        -config ca.cnf -extensions v3_req


########## apiserver 证书 ##########
cp ../../etc/certificate/apiserver.cnf .
cp ../../etc/certificate/apiserver_perm.cnf .
openssl genrsa -out apiserver.key 3072
# 生成证书请求
openssl req -new -key apiserver.key -out apiserver.csr -subj \
        "/CN=kubernetes/OU=System/C=CN/ST=Shanghai/L=Shanghai/O=k8s" \
        -config apiserver.cnf
# 签发证书
openssl x509 -req -in apiserver.csr -CA ca.pem \
        -CAkey ca.key -CAcreateserial \
        -out apiserver.pem -days 1095 \
        -extfile apiserver_perm.cnf -extensions v3_req



########## kubelet 证书 ##########
cp ../../etc/certificate/kubelet.cnf .
name=kubelet
conf=kubelet.cnf
openssl genrsa -out $name.key 3072
openssl req -new -key $name.key -out $name.csr -subj \
        "/CN=admin/OU=System/C=CN/ST=Shanghai/L=Shanghai/O=system:masters" \
        -config $conf
openssl x509 -req -in $name.csr -CA ca.pem \
        -CAkey ca.key -CAcreateserial -out $name.pem \
        -days 1095 -extfile $conf -extensions v3_req



########## kubeproxy 证书 ##########
cp ../../etc/certificate/kube-proxy.cnf .
name=kube-proxy
conf=kube-proxy.cnf
openssl genrsa -out $name.key 3072
openssl req -new -key $name.key -out $name.csr -subj \
        "/CN=system:kube-proxy/OU=System/C=CN/ST=Shanghai/L=Shanghai/O=k8s" \
        -config $conf
openssl x509 -req -in $name.csr \
        -CA ca.pem -CAkey ca.key -CAcreateserial \
        -out $name.pem -days 1095 \
        -extfile $conf -extensions v3_req


rm -rf *.cnf
cd ..
rm -rf ${KEY_DIR_BACKUP}
mv ${KEY_DIR} ${KEY_DIR_BACKUP}
mv -rf ${TMP_DIR} ${KEY_DIR}

# 拷贝配置到/etc/kubernetes/
cp ${KEY_DIR}/* /etc/kubernetes/ssl/ -rf
