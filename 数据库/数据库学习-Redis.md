[TOC]



# Redis

Redis是一款基于内存的且支持持久化、高性能的Key-Value NoSQL 数据库，其支持丰富数据类型(string，list，set，sorted set，hash)，常被用作缓存的解决方案。Redis具有以下显著特点：

- 速度快，因为数据存在内存中，类似于HashMap，HashMap的优势就是查找和操作的时间复杂度都是O(1)；
- 支持丰富数据类型，支持string，list，set，sorted set，hash；
- 支持事务，操作都是原子性，所谓的原子性就是对数据的更改要么全部执行，要么全部不执行；
- 丰富的特性：可用于缓存，消息，按key设置过期时间，过期后将会自动删除。

------

Redis作查询缓存需要注意考虑以下几个问题，包括防止脏读、序列化查询结果、为查询结果生成一个标识和怎么使用四个问题，具体如下：

## 1  防止脏读

　　对一张表的查询结果放在一个哈希结构里，当对这个表进行修改、删除或者更新时，删除该哈希结构。对这张表所有的操作方法，使用注解进行标记，例如：

```text
Hash   KEY(表名)  k(查询结果标识) : v()   k:v   k:v   k:v   k:v1
// 表示该方法需要执行 (缓存是否命中 ? 返回缓存并阻止方法调用 : 执行方法并缓存结果)的缓存逻辑
@RedisCache(type = JobPostModel.class)
JobPostModel selectByPrimaryKey(Integer id);

// 表示该方法需要执行清除缓存逻辑
@RedisEvict(type = JobPostModel.class)
int deleteByPrimaryKey(Integer id);1234567
```

　　我们缓存了查询结果，那么一旦数据库中的数据发生变化，缓存的结果就不可用了。为了实现这一保证，可以在执行相关表的更新查询(update,delete,insert)查询前，让相关的缓存过期。这样下一次查询时程序就会重新从数据库中读取新数据缓存到redis中。那么问题来了，在执行一条insert前我怎么知道应该让哪些缓存过期呢？对于Redis，我们可以使用Hash结构，让一张表对应一个Hash，所有在这张表上的查询都保存到该Hash下。这样当表数据发生变动时，直接让Set过期即可。我们可以自定义一个注解，在数据库查询方法上通过注解的属性注明这个操作与哪些表相关，这样在执行过期操作时，就能直接从注解中得知应该让哪些Set过期了。

------

## 2 序列化查询结果

　　利用JDK自带的ObjectInputStream/ObjectOutputStream将查询结果序列化成字节序列，即需要考虑Redis的实际存储问题。

------

### 3 为查询结果生成一个标识

　　被调用的方法所在的类名，被调用的方法的方法名，该方法的参数三者共同标识一条查询结果。也就是说，如果两次查询调用的类名、方法名和参数值相同，我们就可以确定这两次查询结果一定是相同的（在数据没有变动的前提下）。因此，我们可以将这三个元素组合成一个字符串做为key，就解决了标识问题。

------

#### 4 以 AOP 方式使用Redis

- 方法被调用之前，根据类名、方法名和参数值生成Key；
- 通过Key向Redis发起查询；
- 如果缓存命中，则将缓存结果反序列化作为方法调用的返回值 ，并将其直接返回；
- 如果缓存未命中，则继续向数据库中查询，并将查询结果序列化存入redis中，同时将查询结果返回。

------

　　例如，插入删除缓存逻辑如下：

```java
/**
     * 在方法调用前清除缓存，然后调用业务方法
     * @param jp
     * @return
     * @throws Throwable
     */
    @Around("execution(* com.fh.taolijie.dao.mapper.JobPostModelMapper.insert*(..))" +
            "|| execution(* com.fh.taolijie.dao.mapper.JobPostModelMapper.update*(..))" +
            "|| execution(* com.fh.taolijie.dao.mapper.JobPostModelMapper.delete*(..))" +
            "|| execution(* com.fh.taolijie.dao.mapper.JobPostModelMapper.increase*(..))" +
            "|| execution(* com.fh.taolijie.dao.mapper.JobPostModelMapper.decrease*(..))" +
            "|| execution(* com.fh.taolijie.dao.mapper.JobPostModelMapper.complaint(..))" +
            "|| execution(* com.fh.taolijie.dao.mapper.JobPostModelMapper.set*(..))")
    public Object evictCache(ProceedingJoinPoint jp) throws Throwable {}
```

