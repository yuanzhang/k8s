#!/bin/bash

rm -rf perm_tmp
mkdir perm_tmp
cd perm_tmp

cp ../../etc/certificate/ca.cnf .


# 创建ca key
openssl genrsa -out ca.key 3072

# 签发key
openssl req -x509 -new -nodes -key ca.key -days 1095 -out ca.pem -subj \
        "/CN=kubernetes/OU=System/C=CN/ST=Shanghai/L=Shanghai/O=k8s" \
        -config ca.cnf -extensions v3_req
