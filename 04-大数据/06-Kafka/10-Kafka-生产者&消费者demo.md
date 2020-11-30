[toc]

# 生产者消费者demo

## 1 生产者

```java
package com.hong.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.util.Properties;

/**
 * @author hongzh.zhang on 2020/11/29
 * 生产者demo
 */
public class MyProducer {

    public static void main(String[] args) {
        
        // 1、创建kafka生产者的配置信息
        Properties prop = new Properties();

        // kafka集群，broker-list
        // 指定连接的kafka集群
        // prop.put("bootstrap.servers", "node01:9092");
        prop.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "node01:9092");

        // ack应答级别
        // prop.put("acks", "all");
        prop.put(ProducerConfig.ACKS_CONFIG, "all");

        // 重试次数
        prop.put("retries", 3);

        // 批次大小数据
        prop.put("batch.size", 16384);

        // 等待时间
        prop.put("linger.ms", 1);

        // RecordAccumulator缓冲区大小
        prop.put("buffer.memory", 33554432);

        // key,value序列化类
        prop.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        prop.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        // 创建生产者对象
        KafkaProducer<String, String> producer = new KafkaProducer<>(prop);

        // cli创建主题：
        // bin/kafka-topics.sh --create --zookeeper node02:2181 --topic hong_1 --partitions 2 --replication-factor 2
        // cli启动消费者：
        // bin/kafka-console-consumer.sh --bootstrap-server node01:9092 --topic hong_1 --from-beginning

        // 循环发送消息
        for (int i = 0; i < 10; i++) {
            // 消息对象
            ProducerRecord<String, String> producerRecord = new ProducerRecord<>("hong_1", "MyProducer message:"+i);
            // 发送数据
            producer.send(producerRecord);
        }

        // 关闭资源
        producer.close();
    }
}

```

## 2 消费者

```java
package com.hong.kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;

/**
 * @author hongzh.zhang on 2020/11/29
 * consumer demo
 */
public class MyConsumer {
    public static void main(String[] args) {
        // 创建消费者配置信息
        Properties prop = new Properties();

        // 连接的集群
        prop.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "node01:9092");
        // 开启自动提交
        prop.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");
        // 自动提交的延时
        prop.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, "1000");
        // key value的反序列化
        prop.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
        prop.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
        // 消费者组
        prop.put(ConsumerConfig.GROUP_ID_CONFIG, "consumer_group_1");
        // 从头开始消费(需要设置该参数为earliest && 更改消费者组名)
        prop.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        // 创建消费者
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(prop);

        // 订阅主题
        consumer.subscribe(Arrays.asList("hong_1"));

        System.out.println("启动消费者");
        while (true) {
            // 获取数据
            //在100ms内等待Kafka的broker返回数据.超时参数指定poll在多久之后可以返回，不管有没有可用的数据都要返回
            ConsumerRecords<String, String> consumerRecords = consumer.poll(Duration.ofMillis(1000));

            // 解析并打印
            for (ConsumerRecord<String, String> consumerRecord : consumerRecords) {
                String key = consumerRecord.key();
                String value = consumerRecord.value();

                System.out.println("key: " + key + "  value: " + value);
            }
        }

    }
}

```

