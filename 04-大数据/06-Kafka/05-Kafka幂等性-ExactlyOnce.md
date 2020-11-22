[toc]

# Kafka幂等性-ExactlyOnce

## 1 ExactlyOnce

- ACK=-1(all)：可以保证 Producer 到 Server 之间不会丢失数据，即 **At Least Once** 语义。
- ACK=0 ：可以保证生产者每条消息只会被发送一次，即 **At Most Once** 语义。

At Least Once 可以保证数据不丢失，但是不能保证数据不重复；相对的， At Most Once可以保证数据不重复，但是不能保证数据不丢失。 但是，对于一些非常重要的信息，比如说**交易数据**，下游数据消费者要求数据既不重复也不丢失，即 **Exactly Once** 语义。

在 0.11 版本以前的 Kafka，对此是无能为力的，只能保证数据不丢失，再在下游消费者对数据做全局去重。对于多个下游应用的情况，每个都需要单独做**全局去重**，这就对性能造成了很大影响。

0.11 版本的 Kafka，引入了一项重大特性：**幂等性**。**所谓的幂等性就是指 Producer 不论向 Server 发送多少次重复数据， Server 端都只会持久化一条**。幂等性结合 At Least Once 语义，就构成了 Kafka 的 Exactly Once 语义。即：

 `Exactly Once = At Least Once + 幂等性  `

## 2 幂等性

要启用幂等性，只需要将 Producer 的参数中 `enable.idempotence` 设置为 true 即可。 Kafka的幂等性实现其实就是将原来下游需要做的去重放在了数据上游。开启幂等性的 Producer 在初始化的时候会被分配一个 PID，发往同一 Partition 的消息会附带 Sequence Number。而Broker 端会对` <PID, Partition, SeqNumber> `做缓存，当具有相同主键的消息提交时， Broker 只会持久化一条。 

但是 PID 重启就会变化，同时不同的 Partition 也具有不同主键，**所以幂等性无法保证跨分区跨会话的 Exactly Once。** 

[官网原话:](http://kafka.apache.org/0110/documentation/#producerconfigs)

```html
enable.idempotence

DESCRIPTION:When set to 'true', the producer will ensure that exactly one copy of each message is written in the stream. If 'false', producer retries due to broker failures, etc., may write duplicates of the retried message in the stream. This is set to 'false' by default. Note that enabling idempotence requires max.in.flight.requests.per.connection to be set to 1 and retries cannot be zero. Additionally acks must be set to 'all'. If these values are left at their defaults, we will override the default to be suitable. If the values are set to something incompatible with the idempotent producer, a ConfigException will be thrown.

TYPE:boolean

DEFAULT:false
```

## ps-相关资料

[Kafka学习笔记](https://my.oschina.net/jallenkwong/blog/4449224)

