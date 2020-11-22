[TOC]

# kafka常用命令

## 1 topic相关

### 1.1 创建topic

```shell
# 创建一个topic，在zk使用node02，主题名为first，分区数为2，副本数为2
bin/kafka-topics.sh --create --zookeeper node02:2181 --topic first --partitions 2 --replication-factor 2
```

### 1.2 查看topic列表

```shell
# 查看zk中node02上的主题列表
bin/kafka-topics.sh --list --zookeeper node02:2181
```

### 1.3 删除topic

```shell
# 删除zk中node02上的名叫first的主题（需要在kafka配置文件中打开可删除topic,否则即使删除也不起作用）
bin/kafka-topics.sh --delete --zookeeper node02:2181 --topic first
```

### 1.4 查看topic的基础描述

```shell
# 查看zk中node02上名叫first的主题的详细描述
bin/kafka-topics.sh --describe --zookeeper node01:2181 --topic first
```

### 1.5 修改topic分区数

```shell
# 修改first的topic的分区数为6
bin/kafka-topics.sh --zookeeper node01:2181 --alter --topic first --partitions 6
```

## 2 producer相关

```shell
# 启动控制台生产者（阻塞进程）向kafka机器node01:9092中的first主题发送列出的消息
bin/kafka-console-producer.sh --broker-list node01:9092 --topic first

> hello
> world
```

## 3 consumer相关

```shell
# 启动控制台消费者（阻塞进程）从kafka机器node01:9092中的first主题消费消息
# --from-beginning代表从最头开始消费（offset=0），如果没有就从启动时开始消费(这个topic的最新的offset)
bin/kafka-console-cosumer.sh --bootstrap-server node01:9092 --topic first --from-beginning

hello
world
```

