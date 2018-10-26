# 软件etcd安装脚本

## 步骤

安装master节点
- cd bin; sh install {params1} {params2} {params3}
  - params1: etcd1 | etcd2 | etcd3 | ..
  - params2: 0|1  1:master节点, 0:其他节点
  - params3: 'etcd1=https:\/\/xx.xx.xx.xx:2380' 第一个节点参数 | 'etcd1=https:\/\/xx.xx.xx.xx:2380,etcd2=https:\/\/xx.xx.xx.xx:2380' 安装第二个节点参数 | 'etcd1=http:\/\/xx.xx.xx.xx:2380,etcd2=http:\/\/xx.xx.xx.xx:2380,etcd3=http:\/\/xx.xx.xx.xx:2380' 安装第三个节点参数. xx.xx.xx.xx 代表本机ip

安装node节点
- 执行脚本前先在master节点执行 sh etcd_cmd.sh 'member add {节点名称，如etcd2} https://{node ip}:2380', 增加node节点到etcd库，
- 同master节点执行install.sh脚本
