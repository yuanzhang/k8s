#!/bin/bash

# 创建serviceaccount账号
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

# 所有node节点安装socat
yum install socat -y

helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.11.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

sleep 10

helm install stable/nginx-ingress --set rbac.create=true

