# k8s安装

## 简介

- 针对k8s集群服务，尽量脚本化部署

## 安装步骤
### 安装服务依赖
- 生成公用证书 cd bin; sh pre_install.sh (建议证书生成后push到自己的仓库，方便node脚本安装后续服务：依赖ca.pem)
- 安装etcd (https://github.com/wangzhenxing/shell/tree/master/etcd)
- 安装flannel（https://github.com/wangzhenxing/shell/tree/master/flannel）
- 安装docker（https://github.com/wangzhenxing/shell/tree/master/docker）

- 自行下载k8s二进制文件包
- 安装master节点(cd bin; sh master_install.sh)
  - a、生成公用配置文件 config_install.sh
  - b、修改api_server controller-manager scheduler kubelet kube-proxy配置和启动配置
  - c、启动以上服务
  - d、生成完的配置和证书统一push到git，供node节点使用
- 安装node节点 (cd bin; sh node_install.sh)
  - a、安装公共证书和配置文件
  - b、修改kubelet kube-proxy配置和启动配置
  - c、启动以上服务


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
