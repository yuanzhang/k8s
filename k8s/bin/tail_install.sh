#!/bin/bash

groupadd -g 200 kube
useradd -g kube kube -u 200 -d / -s /sbin/nologin -M

mkdir /var/lib/kubelet
chown kube:kube /var/lib/kubelet
chcon -u system_u -t svirt_sandbox_file_t /var/lib/kubelet
setfacl -m u:kube:r /etc/kubernetes/*.kubeconfig
