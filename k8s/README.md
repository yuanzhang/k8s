# k8s安装

## 简介

- 针对k8s集群服务，尽量脚本化部署

## 软件依赖
- etcd
- flannel
- docker

## bin目录
- 脚本bin/master_install.sh
安装在master机器（兼作node机器，如果不作为node节点，可不启动kubelet和proxy服务）


- 脚本bin/node_install.sh
在node机器执行，需要2个参数，master节点ip和etcd部署情况


## etc目录
各类配置文件
- certificate 鉴权配置
- etc-kubernetes master和node服务配置文件
- kubernetes kubeconfig文件
- systemctl 启动配置


## key
生成的鉴权key文件，master生成好鉴权文件后，供node机器使用
