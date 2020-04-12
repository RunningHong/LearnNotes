[TOC]

# 常用命令

## 1 基础

1. 启动ZK服务:    sh bin/zkServer.sh start
2. 查看ZK服务状态: sh bin/zkServer.sh status
3. 停止ZK服务:    sh bin/zkServer.sh stop
4. 重启ZK服务:    sh bin/zkServer.sh restart
5. 启动后使用help查看帮助命令
6. 启动ZK客户端：sh bin/zkCli.sh

## 2 显示目录

```shell
# 显示指定目录（使用 ls 命令来查看当前 ZooKeeper 中所包含的内容）
# ls 目录
如: ls /hong


# 查看当前节点数据并能看到更新次数等数据
# ls2 目录
如：ls2 /hong
```

## 3 创建znode

```shell
# 创建一个新的znode节点zk以及与它关联的字符串test
# 创建znode必须指定字符串内容
# create [-s][-e] 结点名称 “结点字符串”
# -s 代表是否有序号
# -e 代表是否为临时结点
如：create /hong "test"
```

## 4 查看znode字符串内容

```shell
# get 结点名称
如：get /hong
```

## 5 修改znode字符串内容

```shell
# set 结点名称 “新内容”
如：set /hong "hong2"
```

## 6 删除znode

```shell
# 删除znode
# delete 结点路径
如：delete /hong


# 递归删除zonode
# rmr 结点名称
如： rmr /hong
```

