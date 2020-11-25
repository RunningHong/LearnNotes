[toc]

# Kafka-事务

Kafka事务特性是指一系列的生产者生产消息和消费者提交偏移量的操作在一个事务中，或者说是一个原子操作，生产消息和提交偏移量同时成功或者失败。

## 1 Kafka事务的使用

Kafka中的事务特性主要用于以下两种场景：

- **生产者发送多条消息可以封装在一个事务中，形成一个原子操作。**多条消息要么都发送成功，要么都发送失败。
- **read-process-write模式：将消息消费和生产封装在一个事务中，形成一个原子操作。**在一个流式处理的应用中，常常一个服务需要从上游接收消息，然后经过处理后送达到下游，这就对应着消息的消费和生成。

Kafka producer API提供了以下接口用于事务操作：

```java
    /**
     * 初始化事务
     */
    public void initTransactions();
 
    /**
     * 开启事务
     */
    public void beginTransaction() throws ProducerFencedException ;
 
    /**
     * 在事务内提交已经消费的偏移量
     */
    public void sendOffsetsToTransaction(Map<TopicPartition, OffsetAndMetadata> offsets, 
                                         String consumerGroupId) throws ProducerFencedException ;
 
    /**
     * 提交事务
     */
    public void commitTransaction() throws ProducerFencedException;
 
    /**
     * 丢弃事务
     */
    public void abortTransaction() throws ProducerFencedException ;
```

下面是使用Kafka事务特性的例子，这段代码Producer开启了一个事务，然后在这个事务中发送了两条消息。这两条消息要么都发送成功，要么都失败。

```java
KafkaProducer producer = createKafkaProducer(
  "bootstrap.servers", "localhost:9092",
  "transactional.id”, “my-transactional-id");

producer.initTransactions();
producer.beginTransaction();
producer.send("outputTopic", "message1");
producer.send("outputTopic", "message2");
producer.commitTransaction();
```

## 2 Producer 事务

对于Producer，需要设置`transactional.id`属性。设置了`transactional.id`属性后，`enable.idempotence`(幂等)属性会自动设置为true。

为了实现跨分区跨会话的事务，需要引入一个全局唯一的 Transaction ID，并将 Producer 获得的PID 和Transaction ID 绑定。这样当Producer 重启后就可以通过正在进行的 TransactionID 获得原来的 PID。

为了管理 Transaction， Kafka 引入了一个新的组件 Transaction Coordinator。 Producer 就是通过和 Transaction Coordinator 交互获得 Transaction ID 对应的任务状态。 Transaction Coordinator 还负责将事务所有写入 Kafka 的一个内部 Topic，这样即使整个服务重启，由于事务状态得到保存，进行中的事务状态可以得到恢复，从而继续进行。

## 3 Consumer 事务

对于Consumer，需要设置`isolation.level = read_committed`，这样Consumer只会读取已经提交了事务的消息。另外，需要设置`enable.auto.commit = false`来关闭自动提交Offset功能。

上述事务机制主要是从 Producer 方面考虑，对于 Consumer 而言，事务的保证就会相对较弱，尤其时无法保证 Commit 的信息被精确消费。这是由于 Consumer 可以通过 offset 访问任意信息，而且不同的 Segment File 生命周期不同，同一事务的消息可能会出现重启后被删除的情况。

## 4 Kafka事务特性

Kafka的事务特性本质上代表了三个功能：**原子写操作**，**拒绝僵尸实例（Zombie fencing）和读事务消息**。

### 4 1 原子写

Kafka的事务特性本质上是支持了Kafka跨分区和Topic的原子写操作。在同一个事务中的消息要么同时写入成功，要么同时写入失败。我们知道，Kafka中的Offset信息存储在一个名为_consumed_offsets的Topic中，因此read-process-write模式，除了向目标Topic写入消息，还会向_consumed_offsets中写入已经消费的Offsets数据。因此read-process-write本质上就是跨分区和Topic的原子写操作。**Kafka的事务特性就是要确保跨分区的多个写操作的原子性。**

### 4.2 拒绝僵尸实例（Zombie fencing）

在分布式系统中，一个instance的宕机或失联，集群往往会自动启动一个新的实例来代替它的工作。此时若原实例恢复了，那么集群中就产生了两个具有相同职责的实例，此时前一个instance就被称为“僵尸实例（Zombie Instance）”。在Kafka中，两个相同的producer同时处理消息并生产出重复的消息（read-process-write模式），这样就严重违反了Exactly Once Processing的语义。这就是僵尸实例问题。

**Kafka事务特性通过`transaction-id`属性来解决僵尸实例问题。所有具有相同`transaction-id`的Producer都会被分配相同的pid，同时每一个Producer还会被分配一个递增的epoch。Kafka收到事务提交请求时，如果检查当前事务提交者的epoch不是最新的，那么就会拒绝该Producer的请求。从而达成拒绝僵尸实例的目标。**

### 4.3 读事务消息

为了保证事务特性，Consumer如果设置了`isolation.level = read_committed`，那么它只会读取已经提交了的消息。在Producer成功提交事务后，Kafka会将所有该事务中的消息的`Transaction Marker`从`uncommitted`标记为`committed`状态，从而所有的Consumer都能够消费。

## 5 Kafka事务原理

原理见：[Kafka事务特性讲解](https://www.jianshu.com/p/64c93065473e) 中4. Kafka事务原理

## ps-相关资料

[Kafka学习笔记](https://my.oschina.net/jallenkwong/blog/4449224)

[Kafka事务特性讲解](https://www.jianshu.com/p/64c93065473e)