[toc]

# Jedis操作Redis

## 1 Jedis基础

Jedis是Redis官方推荐的java连接开发工具

```xml
<dependency>
	<groupId>redis.clients</groupId>
	<artifactId>jedis</artifactId>
	<version>3.2.0</version>
</dependency>
```

## 2 常用api

### 2.1 连接测试

```java
/**
 * @author hongzh.zhang on 2021/03/07
 * 连接测试
 * 修改redis.conf文件，将 bind 127.0.0.1这一行注释掉，
 * 或是将127.0.0.1修改为0.0.0.0（redis默认只支持本地连接，修改为0.0.0.0时，这样就可以支持外机连接了）
 */
public class R01ConnTest {

    public static void main(String[] args) {
        Jedis jedis = new Jedis("node01", 6379);
        // 输出PONG，redis连通成功
        System.out.println(jedis.ping());
    }
}

```

### 2.2 基础结构操作

```java
/**
 * @author hongzh.zhang on 2021/03/07
 */
public class R02CommonApi {

    public static void main(String[] args) {
        Jedis jedis = new Jedis("node01", 6379);

        System.out.println("清空数据" + jedis.flushDB());

        // key
        Set<String> keys = jedis.keys("*");
        for (Iterator iterator = keys.iterator(); iterator.hasNext();) {
            String key = (String) iterator.next();
            System.out.println(key);
        }
        System.out.println("jedis.exists====>" + jedis.exists("k2"));
        System.out.println(jedis.ttl("k1"));

        // String
        // jedis.append("k1","myreids");
        System.out.println(jedis.get("k1"));
        jedis.set("k4", "k4_redis");
        System.out.println("----------------------------------------");
        jedis.mset("str1", "v1", "str2", "v2", "str3", "v3");
        System.out.println(jedis.mget("str1", "str2", "str3"));


        // list
        System.out.println("----------------------------------------");
        // jedis.lpush("mylist","v1","v2","v3","v4","v5");
        List<String> list = jedis.lrange("mylist", 0, -1);
        for (String element : list) {
            System.out.println(element);
        }

        // set
        jedis.sadd("orders", "jd001");
        jedis.sadd("orders", "jd002");
        jedis.sadd("orders", "jd003");
        Set<String> set1 = jedis.smembers("orders");
        for (Iterator iterator = set1.iterator(); iterator.hasNext();) {
            String string = (String) iterator.next();
            System.out.println(string);
        }
        jedis.srem("orders", "jd002");
        System.out.println(jedis.smembers("orders").size());

        // hash
        jedis.hset("hash1", "userName", "lisi");
        System.out.println(jedis.hget("hash1", "userName"));
        Map<String, String> map = new HashMap<>();
        map.put("telphone", "138xxxxxxxx");
        map.put("address", "beijing");
        map.put("email", "abc@163.com");
        jedis.hmset("hash2", map);
        List<String> result = jedis.hmget("hash2", "telphone", "email");
        for (String element : result) {
            System.out.println(element);
        }

        // zset
        jedis.zadd("zset01", 60d, "v1");
        jedis.zadd("zset01", 70d, "v2");
        jedis.zadd("zset01", 80d, "v3");
        jedis.zadd("zset01", 90d, "v4");

        Set<String> s1 = jedis.zrange("zset01", 0, -1);
        for (Iterator iterator = s1.iterator(); iterator.hasNext();) {
            String string = (String) iterator.next();
            System.out.println(string);
        }
    }

```

### 2.3 事务

```java
/**
 * @author hongzh.zhang on 2021/03/07
 */
public class R03TransactionTest {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("node01", 6379);

        // 监控key，如果该动了事务就被放弃
        /*
         * 3 jedis.watch("serialNum");
         * jedis.set("serialNum","s#####################");
         * jedis.unwatch();
         */

        Transaction transaction = jedis.multi();// 被当作一个命令进行执行
        Response<String> response = transaction.get("serialNum");
        transaction.set("serialNum", "s002");
        response = transaction.get("serialNum");
        transaction.lpush("list3", "a");
        transaction.lpush("list3", "b");
        transaction.lpush("list3", "c");

        transaction.exec();
        // 2 transaction.discard();
        System.out.println("serialNum***********" + response.get());

    }

}
```

### 2.4 加锁

```java
package com.hong.redis;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.Transaction;

/**
 * @author hongzh.zhang on 2021/03/07
 * 通俗点讲，watch命令就是标记一个键，如果标记了一个键， 在提交事务前如果该键被别人修改过，那事务就会失败，这种情况通常可以在程序中 重新再尝试一次。
 * 首先标记了键balance，然后检查余额是否足够，不足就取消标记，并不做扣减； 足够的话，就启动事务进行更新操作，
 * 如果在此期间键balance被其它人修改， 那在提交事务（执行exec）时就会报错， 程序中通常可以捕获这类错误再重新执行一次，直到成功。
 */
public class R04LockTest {

    public boolean testLock() throws InterruptedException {
        Jedis jedis = new Jedis("node01", 6379);
        int balance;// 可用余额
        int debt;// 欠额
        int amtToSubtract = 10;// 实刷额度

        jedis.set("balance", "0");
        jedis.watch("balance");
        // jedis.set("balance","5");//此句不该出现
        Thread.sleep(7000);
        balance = Integer.parseInt(jedis.get("balance"));
        if (balance < amtToSubtract) {
            jedis.unwatch();
            System.out.println("modify");
            return false;
        } else {
            System.out.println("***********transaction");
            Transaction transaction = jedis.multi();
            transaction.decrBy("balance", amtToSubtract);
            transaction.incrBy("debt", amtToSubtract);
            transaction.exec();
            balance = Integer.parseInt(jedis.get("balance"));
            debt = Integer.parseInt(jedis.get("debt"));

            System.out.println("*******" + balance);
            System.out.println("*******" + debt);
            return true;
        }
    }

    public static void main(String[] args) throws InterruptedException {
        System.out.println(new R04LockTest().testLock());
    }
}

```

