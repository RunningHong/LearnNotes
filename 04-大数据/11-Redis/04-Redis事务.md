[toc]

# Redis事务

## 1 事务基础

Redis 事务可以一次执行多个命令， 并且带有以下三个重要的保证：

- 批量操作在发送 EXEC 命令前被放入队列缓存。
- 收到 EXEC 命令后进入事务执行，**事务中任意命令执行失败，其余的命令依然被执行**。
- 在事务执行过程，其他客户端提交的命令请求不会插入到事务执行命令序列中。

一个事务从开始到执行会经历以下三个阶段：

1. 开始事务。
2. 命令入队。
3. 执行事务。

一个队列中，一次性、顺序性、排他性的执行一系列命令。 

Redis事务没有隔离级别的概念，所有的命令并不是直接执行，而是先放到队列中，只有最后执行事务的时候才会执行

## 2 事务特性

- **单独的隔离操作**：事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中，不会被其他客户端发送来的命令请求所打断。
- **没有隔离级别的概念**：队列中的命令没有提交之前都不会实际的被执行，因为事务提交前任何指令都不会被实际执行， 也就不存在”事务内的查询要看到事务里的更新，在事务外查询不能看到”这个让人万分头痛的问题
- **不保证原子性**：redis同一个事务中如果有一条命令执行失败，其后的命令仍然会被执行，没有回滚

不遵循传统的ACID中的AI

## 3 常用CLI命令

| 命令                | 描述                                                         |
| ------------------- | ------------------------------------------------------------ |
| DISCARD             | 取消事务，放弃执行事务块内的所有命令。                       |
| EXEC                | 执行所有事务块内的命令。                                     |
| MULTI               | 标记一个事务块的开始。                                       |
| UNWATCH             | 取消 WATCH 命令对所有 key 的监视。                           |
| WATCH key [key ...] | 监视一个(或多个) key ，如果在事务执行之前这个(或这些) key 被其他命令所改动，那么事务将被打断。 |

```shell
redis 127.0.0.1:6379> MULTI # 开启事务
OK

redis 127.0.0.1:6379> SET book-name "Mastering C++ in 21 days"
QUEUED

redis 127.0.0.1:6379> GET book-name
QUEUED

redis 127.0.0.1:6379> SADD tag "C++" "Programming" "Mastering Series"
QUEUED

redis 127.0.0.1:6379> SMEMBERS tag
QUEUED

redis 127.0.0.1:6379> EXEC # 执行事务
1) OK
2) "Mastering C++ in 21 days"
3) (integer) 3
4) 1) "Mastering Series"
   2) "C++"
   3) "Programming"
```

```shell
localhost:6379> multi # 开启事务
OK
localhost:6379(TX)> set k1 v1
QUEUED
localhost:6379(TX)> set k2 v2
QUEUED
localhost:6379(TX)> incr k1 # 此处对k1的值进行自增，因为值不是数字类型所以会报错
QUEUED
localhost:6379(TX)> set k3 v3
QUEUED
localhost:6379(TX)> exec # 执行事务
1) OK
2) OK
3) (error) ERR value is not an integer or out of range
4) OK
localhost:6379> get k2 # 虽然事务中有报错但是其他指令也执行成功了
"v2"
localhost:6379> get k3 # 虽然事务中有报错但是其他指令也执行成功了
"v3"
```

## 4 事务watch监控

- 悲观锁
    - 悲观锁(Pessimistic Lock), 顾名思义，就是很悲观，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会block直到它拿到锁。传统的关系型数据库里边就用到了很多这种锁机制，比如行锁，表锁等，读锁，写锁等，都是在做操作之前先上锁。
- 乐观锁
    - 乐观锁(Optimistic Lock), 顾名思义，就是很乐观，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用版本号等机制。乐观锁适用于多读的应用类型，这样可以提高吞吐量。
    - 乐观锁策略:提交版本必须大于记录当前版本才能执行更新
- CAS

 witch的特点

- Watch指令，类似乐观锁，事务提交时，如果Key的值已被别的客户端改变， 比如某个list已被别的客户端push/pop过了，整个事务队列都不会被执行
- 通过WATCH命令在事务执行之前监控了多个Keys，倘若在WATCH之后有任何Key的值发生了变化， EXEC命令执行的事务都将被放弃，同时返回Nullmulti-bulk应答以通知调用者事务执行失败

```shell
#### 正常情况，监视money途中没有其他一组命令对money进行修改
localhost:6379> watch money # 监视money
OK
localhost:6379> multi
OK
localhost:6379(TX)> decrby money 20
QUEUED
localhost:6379(TX)> decrby money 30
QUEUED
localhost:6379(TX)> exec
1) (integer) -20
2) (integer) -50


### 异常情况，监视money途中有其他一组命令对money进行修改
localhost:6379> flushdb
OK
localhost:6379> watch money # 监视money
OK
localhost:6379> multi
OK
localhost:6379(TX)> incrby money 10
QUEUED
localhost:6379(TX)> incrby money 30
QUEUED
# xxxxx # 此时有一组操作对money进行赋值 set money 1000
localhost:6379(TX)> exec # 监视期间其他一组操作有对money进行修改，事务失败
(nil)
localhost:6379> unwatch # 取消监控，解锁
OK
```

