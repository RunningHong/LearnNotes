[toc]

# Redis简介&安装

## 1 NoSQL

### 1.1 什么是NoSQL

NoSQL(NoSQL = Not Only SQL)，意即“不仅仅是SQL”，**泛指非关系型的数据库**。 

### 1.2 NoSQL的优点

#### 易扩展

NoSQL数据库种类繁多，但是一个共同的特点都是去掉关系数据库的关系型特性。数据之间无关系，这样就非常容易扩展。也无形之间，在架构的层面上带来了可扩展的能力。

#### 大数据量高性能

NoSQL数据库都具有非常高的读写性能，尤其在大数据量下，同样表现优秀。

这得益于它的无关系性，数据库的结构简单。

一般MySQL使用Query Cache，每次表的更新Cache就失效，是一种大粒度的Cache，在针对web2.0的交互频繁的应用，Cache性能不高。

而NoSQL的Cache是记录级的，是一种细粒度的Cache，所以NoSQL在这个层面上来说就要性能高很多了。

#### 多样灵活的数据模型

NoSQL无需事先为要存储的数据建立字段，随时可以存储自定义的数据格式。

而在关系数据库里，增删字段是一件非常麻烦的事情。如果是非常大数据量的表，增加字段简直就是一个噩梦。

### 1.3 代表的NoSQL

#### 1.3.1 KV键值对型

- Redis
- Tair
- Memecache

#### 1.3.2 文档型

- MongoDB

#### 1.3.3 列式

- HBase

#### 1.3.4 图关系型

- Neo4j
- InfoGrid

![1615021007215](picture/1615021007215.png)

## 2 Redis介绍

### 2.1 概述

Redis（Remote Dictionary Server )，即远程字典服务，是一个开源的使用ANSI [C语言](https://baike.baidu.com/item/C语言)编写、支持网络、可基于内存亦可持久化的日志型、Key-Value[数据库](https://baike.baidu.com/item/数据库/103728)，并提供多种语言的API。 

### 2.2 Redis作用

- 内存存储和持久化：redis支持异步将内存中的数据写到硬盘上，同时不影响继续服务
- 取最新N个数据的操作，如：可以将最新的10条评论的ID放在Redis的List集合里面
- 模拟类似于HttpSession这种需要设定过期时间的功能
- 发布、订阅消息系统
- 定时器、计数器（如浏览量）

### 2.3 安装与启动

1. 下载对应的gz包
2. 解压到指定的文件夹内（如/opt/sxt/redis-6.2.1）
3. 安装c++环境
    - yum install gcc-c++
    - make
    - make install
4. 更改配置，开启守护线程允许后台运行
    - 将redis.conf中的daemonize no改为daemonize yes
5. 通过配置文件启动服务
    - `redis-server /opt/sxt/redis-6.2.1/redis.conf`
    - 备注：redis-server在/usr/local/bin下
6. Cli连接本地redis
    - `redis-cli -h localhost -p 6379`
7. 测试一下是否成功
    - ping 后返回 PONG
8. 关闭服务并退出
    - 在cli中先shutdown，再exit退出

### 2.3 Redis性能测试

通过redis-benchmark可以测试

详见：[Redis性能测试]( https://www.runoob.com/redis/redis-benchmarks.html )

## ps-相关资料

[Redis笔记]( https://my.oschina.net/jallenkwong/blog/4411044 )

[Redis性能测试]( https://www.runoob.com/redis/redis-benchmarks.html )

[Redis视频-狂神-Redis最新超详细版教程通俗易懂](https://www.bilibili.com/video/BV1S54y1R7SB?p=4&spm_id_from=pageDriver )

