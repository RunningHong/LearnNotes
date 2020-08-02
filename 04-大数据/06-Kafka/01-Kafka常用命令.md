[TOC]

# kafka常用命令

## 1 创建topic

```shell
# 创建一个topic，在node02机器上，topic名为first，分区数为2，副本数为2
bin/kafka-topics.sh --create --zookeeper node02:2181 --topic first --partitions 2 --replication-factor 2
```

## 2 查看topic

```shell
# 查看node02上的topic
bin/kafka-topics.sh --list --zookeeper node02:2181
```

## 3 删除topic

```
# 删除node02上的名叫first的topic
bin/kafka-topics.sh --delete --zookeeper node02:2181 --topic first
```

## 4 查看topic的基础描述

```
# 查看node01上名叫first的描述
bin/kafka-topics.sh --describe --topic first --zookeeper node01:2181
```

