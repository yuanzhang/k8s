# 软件flanneld安装脚本

## 步骤

安装master节点
- cd bin
- sh add_flannel_config_in_etcd.sh
- sh install.sh 'https:\/\/172.17.77.90:2379,https:\/\/172.17.181.176:2379,https:\/\/172.17.181.177:2379' # 参数为etcd集群服务器

安装node节点
- cd bin
- sh install.sh 'https:\/\/172.17.77.90:2379,https:\/\/172.17.181.176:2379,https:\/\/172.17.181.177:2379' # 参数为etcd集群服务器
