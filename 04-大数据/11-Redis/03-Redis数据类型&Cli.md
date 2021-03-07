[toc]

# Redis数据类型

## 1 String-KV模式

String类型key的value可以是字符串、数字

String的使用场景：

- 计数器
- 粉丝数
- 对象缓存存储

| 命令                             | 描述                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| SET key value                    | 设置指定 key 的值                                            |
| GET key                          | 获取指定 key 的值。                                          |
| GETRANGE key start end           | 返回 key 中字符串值的子字符                                  |
| GETSET key value                 | 将给定 key 的值设为 value ，并返回 key 的旧值(old value)。   |
| GETBIT key offset                | 对 key 所储存的字符串值，获取指定偏移量上的位(bit)。         |
| MGET key1 [key2..]               | 获取所有(一个或多个)给定 key 的值。                          |
| SETBIT key offset value          | 对 key 所储存的字符串值，设置或清除指定偏移量上的位(bit)。   |
| SETEX key seconds value          | 将值 value 关联到 key ，并将 key 的过期时间设为 seconds (以秒为单位)。 |
| SETNX key value                  | 只有在 key 不存在时设置 key 的值。                           |
| SETRANGE key offset value        | 用 value 参数覆写给定 key 所储存的字符串值，从偏移量 offset 开始。 |
| STRLEN key                       | 返回 key 所储存的字符串值的长度。                            |
| MSET key value [key value ...]   | 同时设置一个或多个 key-value 对。                            |
| MSETNX key value [key value ...] | 同时设置一个或多个 key-value 对，当且仅当所有给定 key 都不存在。 |
| PSETEX key milliseconds value    | 这个命令和 SETEX 命令相似，但它以毫秒为单位设置 key 的生存时间，而不是像 SETEX 命令那样，以秒为单位。 |
| INCR key                         | 将 key 中储存的数字值增一。                                  |
| INCRBY key increment             | 将 key 所储存的值加上给定的增量值（increment） 。            |
| INCRBYFLOAT key increment        | 将 key 所储存的值加上给定的浮点增量值（increment） 。        |
| DECR key                         | 将 key 中储存的数字值减一。                                  |
| DECRBY key decrement             | key 所储存的值减去给定的减量值（decrement） 。               |
| APPEND key value                 | 如果 key 已经存在并且是一个字符串， APPEND 命令将指定的 value 追加到该 key 原来值（value）的末尾。 |

```shell
##############字符串基础命令
127.0.0.1:6379[3]> set key1 v1 # 设置值
OK
127.0.0.1:6379[3]> get key1 # 获取key的值
"v1"
127.0.0.1:6379[3]> append key1 "hello" # 追加字符串，如果key不存在相当于set
(integer) 7
127.0.0.1:6379[3]> get key1
"v1hello"
127.0.0.1:6379[3]> strlen key1 # 获取字符串长度
(integer) 7


##############字符串-数字基础命令
127.0.0.1:6379[3]> set views 0
OK
127.0.0.1:6379[3]> get views
"0"
127.0.0.1:6379[3]> type views
string
127.0.0.1:6379[3]> incr views # 自增1（需要key是integer类型的）
(integer) 1
127.0.0.1:6379[3]> get views
"1"
127.0.0.1:6379[3]> incr views
(integer) 2
127.0.0.1:6379[3]> get views
"2"
127.0.0.1:6379[3]> decr views # 自减1（需要key是integer类型的）
(integer) 1
127.0.0.1:6379[3]> get views
"1"
127.0.0.1:6379[3]> incrby views 10 # 设置自增步长为10
(integer) 11
127.0.0.1:6379[3]> get views
"11"


##############字符串-字符串截取
127.0.0.1:6379[3]> set key1 "hello,1234"
OK
127.0.0.1:6379[3]> get key1
"hello,1234"
127.0.0.1:6379[3]> getrange key1 0 3 # 截取字符串[0,3]
"hell"
127.0.0.1:6379[3]> getrange key1 0 -1 # 截取全部字符串相当于get key
"hello,1234"


##############字符串-字符串替换
127.0.0.1:6379[3]> set key1 abcdefg
OK
127.0.0.1:6379[3]> setrange key1 1 xx # 替换指定位置开始的字符串
(integer) 7
127.0.0.1:6379[3]> get key1
"axxdefg"


##############字符串-字符串创建以及过期
# setex (set with exprie) # 设置过期时间
# setnx (set if not exists) # 不存在设置（在分布式锁中常使用）
127.0.0.1:6379[3]> setex key3 30 "hello" # 设置key3的值为hello,并且在30s后过期
OK
127.0.0.1:6379[3]> ttl key3
(integer) 26
127.0.0.1:6379[3]> setnx mykey "redis" # 如果mykey不存在，创建mykey，如果存在就创建失败(不会改变原有的值)
(integer) 0
127.0.0.1:6379[3]> get mykey
"redis"


##############字符串-同时设置与获取多个值
127.0.0.1:6379[3]> mset k1 v1 k2 v2 k3 v3
OK
127.0.0.1:6379[3]> keys *
1) "k1"
2) "k3"
3) "k2"
127.0.0.1:6379[3]> mget k1 k2 k3
1) "v1"
2) "v2"
3) "v3"
127.0.0.1:6379[3]> msetnx k1 v1 k4 v4 # msetnx是一个原子性操作，这里由于k1已存在所以这条命令不会成功
(integer) 0
127.0.0.1:6379[3]> get k4 # 由于上一条指令失败，k4未设置成功
(nil)


##############字符串-先get再set
127.0.0.1:6379[3]> getset db redis # 不存在则返回nil
(nil)
127.0.0.1:6379[3]> get db
"redis"
127.0.0.1:6379[3]> getset db redis2 # 如果存在获取原来的值并设置行的值
"redis"
127.0.0.1:6379[3]> get db
"redis2"
```

## 2 List

在redis里可以把list当成栈、队列、阻塞队列

所有的list命令都是l开头的

| 命令                                  | 描述                                                         |
| ------------------------------------- | ------------------------------------------------------------ |
| BLPOP key1 [key2 ] timeout            | 移出并获取列表的第一个元素， 如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止。 |
| BRPOP key1 [key2 ] timeout            | 移出并获取列表的最后一个元素， 如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止。 |
| BRPOPLPUSH source destination timeout | 从列表中弹出一个值，将弹出的元素插入到另外一个列表中并返回它； 如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止。 |
| LINDEX key index                      | 通过索引获取列表中的元素                                     |
| LINSERT key BEFORE/AFTER pivot value  | 在列表的元素前或者后插入元素                                 |
| LLEN key                              | 获取列表长度                                                 |
| LPOP key                              | 移出并获取列表的第一个元素                                   |
| LPUSH key value1 [value2]             | 将一个或多个值插入到列表头部                                 |
| LPUSHX key value                      | 将一个值插入到已存在的列表头部                               |
| LRANGE key start stop                 | 获取列表指定范围内的元素                                     |
| LREM key count value                  | 移除列表元素                                                 |
| LSET key index value                  | 通过索引设置列表元素的值                                     |
| LTRIM key start stop                  | 对一个列表进行修剪(trim)，就是说，让列表只保留指定区间内的元素，不在指定区间之内的元素都将被删除。 |
| RPOP key                              | 移除列表的最后一个元素，返回值为移除的元素。                 |
| RPOPLPUSH source destination          | 移除列表的最后一个元素，并将该元素添加到另一个列表并返回     |
| RPUSH key value1 [value2]             | 在列表中添加一个或多个值                                     |
| RPUSHX key value                      | 为已存在的列表添加值                                         |

```shell
##############list-插入命令
127.0.0.1:6379[3]> lpush list one # 将值插入列表头部（左侧）
(integer) 1
127.0.0.1:6379[3]> lpush list two
(integer) 2
127.0.0.1:6379[3]> lrange list 0 -1 # 获取list的所有值
1) "two"
2) "one"
127.0.0.1:6379[3]> lrange list 0 1
1) "two"
2) "one"
127.0.0.1:6379[3]> rpush list 3 # 将值插入列表尾部（右侧）
(integer) 3
127.0.0.1:6379[3]> lrange list 0 -1
1) "two"
2) "one"
3) "3"


##############list-移除命令
127.0.0.1:6379[3]> lrange list 0 -1 # 移除列表的头部（第一个）
1) "two"
2) "one"
3) "3"
127.0.0.1:6379[3]> lpop list
"two"
127.0.0.1:6379[3]> lrange list 0 -1
1) "one"
2) "3"
127.0.0.1:6379[3]> rpop list # 移除列表的尾部（最后一个）
"3"
127.0.0.1:6379[3]> lrange list 0 -1
1) "one"


##############list-获取指定下标值命令
127.0.0.1:6379[3]> lrange list 0 -1
1) "one"
2) "2"
127.0.0.1:6379[3]> lindex list 0
"one"
127.0.0.1:6379[3]> lindex list 1
"2"


##############list-列表长度
127.0.0.1:6379[3]> rpush list 1
(integer) 1
127.0.0.1:6379[3]> rpush list 2
(integer) 2
127.0.0.1:6379[3]> rpush list 3
(integer) 3
127.0.0.1:6379[3]> lrange list 0 -1
1) "1"
2) "2"
3) "3"
127.0.0.1:6379[3]> llen list # 返回列表长度
(integer) 3


##############list-移除指定的值
127.0.0.1:6379[3]> lrange list 0 -1
1) "1"
2) "2"
3) "3"
4) "1"
127.0.0.1:6379[3]> lrem list 2 "1" # 移除list集合中指定个数(2个)的value
(integer) 2
127.0.0.1:6379[3]> lrange list 0 -1
1) "2"
2) "3"



##############list-截取list
127.0.0.1:6379[3]> lrange list 0 -1
1) "1"
2) "2"
3) "3"
4) "4"
127.0.0.1:6379[3]> ltrim list 1 2 # 通过下标截取指定的长度，list会被修改
OK
127.0.0.1:6379[3]> lrange list 0 -1
1) "2"
2) "3"


##############list-复杂操作
# rpoplpush 移除列表中的最后一个元素到新的列表中
127.0.0.1:6379[3]> lrange list 0 -1
1) "1"
2) "2"
3) "3"
127.0.0.1:6379[3]> 
127.0.0.1:6379[3]> 
127.0.0.1:6379[3]> 
127.0.0.1:6379[3]> rpoplpush list list2
"3"
127.0.0.1:6379[3]> lrange list 0 -1
1) "1"
2) "2"
127.0.0.1:6379[3]> lrange list2 0 -1
1) "3"

```

## 3 Set

Redis 的 Set 是 String 类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。

Redis 中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是 O(1)。

集合中最大的成员数为 232 - 1 (4294967295, 每个集合可存储40多亿个成员)。

| 命令                                           | 描述                                                |
| ---------------------------------------------- | --------------------------------------------------- |
| sadd key member1 [member2]                     | 向集合添加一个或多个成员                            |
| scard key                                      | 获取集合的成员数                                    |
| sdiff key1 [key2]                              | 返回给定所有集合的差集                              |
| sdiffstore destination key1 [key2]             | 返回给定所有集合的差集并存储在 destination 中       |
| sinter key1 [key2]                             | 返回给定所有集合的交集                              |
| SINTERSTORE destination key1 [key2]            | 返回给定所有集合的交集并存储在 destination 中       |
| SISMEMBER key member                           | 判断 member 元素是否是集合 key 的成员               |
| SMEMBERS key                                   | 返回集合中的所有成员                                |
| SMOVE source destination member                | 将 member 元素从 source 集合移动到 destination 集合 |
| SPOP key                                       | 移除并返回集合中的一个随机元素                      |
| SRANDMEMBER key [count]                        | 返回集合中一个或多个随机数                          |
| SREM key member1 [member2]                     | 移除集合中一个或多个成员                            |
| SUNION key1 [key2]                             | 返回所有给定集合的并集                              |
| SUNIONSTORE destination key1 [key2]            | 所有给定集合的并集存储在 destination 集合中         |
| SSCAN key cursor [MATCH pattern] [COUNT count] | 迭代集合中的元素                                    |

## 4 Hash-KV模式不变，但V是一个键值对 

Redis hash 是一个 string 类型的 field（字段） 和 value（值） 的映射表，hash 特别适合用于存储对象。

Redis 中每个 hash 可以存储 232 - 1 键值对（40多亿）。

hash应用：

- hash存储变更的数据，如user的变更信息，hmset tom age 12 level 3

| 命令                                           | 描述                                                     |
| ---------------------------------------------- | -------------------------------------------------------- |
| HDEL key field1 [field2]                       | 删除一个或多个哈希表字段                                 |
| HEXISTS key field                              | 查看哈希表 key 中，指定的字段是否存在。                  |
| HGET key field                                 | 获取存储在哈希表中指定字段的值。                         |
| HGETALL key                                    | 获取在哈希表中指定 key 的所有字段和值                    |
| HINCRBY key field increment                    | 为哈希表 key 中的指定字段的整数值加上增量 increment 。   |
| HINCRBYFLOAT key field increment               | 为哈希表 key 中的指定字段的浮点数值加上增量 increment 。 |
| HKEYS key                                      | 获取所有哈希表中的字段                                   |
| HLEN key                                       | 获取哈希表中字段的数量                                   |
| HMGET key field1 [field2]                      | 获取所有给定字段的值                                     |
| HMSET key field1 value1 [field2 value2 ]       | 同时将多个 field-value (域-值)对设置到哈希表 key 中。    |
| HSET key field value                           | 将哈希表 key 中的字段 field 的值设为 value 。            |
| HSETNX key field value                         | 只有在字段 field 不存在时，设置哈希表字段的值。          |
| HVALS key                                      | 获取哈希表中所有值。                                     |
| HSCAN key cursor [MATCH pattern] [COUNT count] | 迭代哈希表中的键值对。                                   |

## 5 Zset

在set基础上，加一个score值。 之前set是k1 v1 v2 v3， 现在zset是k1 score1 v1 score2 v2 

| 命令                                           | 描述                                                         |
| ---------------------------------------------- | ------------------------------------------------------------ |
| ZADD key score1 member1 [score2 member2]       | 向有序集合添加一个或多个成员，或者更新已存在成员的分数       |
| ZCARD key                                      | 获取有序集合的成员数                                         |
| ZCOUNT key min max                             | 计算在有序集合中指定区间分数的成员数                         |
| ZINCRBY key increment member                   | 有序集合中对指定成员的分数加上增量 increment                 |
| ZINTERSTORE destination numkeys key [key ...]  | 计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合 key 中 |
| ZLEXCOUNT key min max                          | 在有序集合中计算指定字典区间内成员数量                       |
| ZRANGE key start stop [WITHSCORES]             | 通过索引区间返回有序集合指定区间内的成员                     |
| ZRANGEBYLEX key min max [LIMIT offset count]   | 通过字典区间返回有序集合的成员                               |
| ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT] | 通过分数返回有序集合指定区间内的成员                         |
| ZRANK key member                               | 返回有序集合中指定成员的索引                                 |
| ZREM key member [member ...]                   | 移除有序集合中的一个或多个成员                               |
| ZREMRANGEBYLEX key min max                     | 移除有序集合中给定的字典区间的所有成员                       |
| ZREMRANGEBYRANK key start stop                 | 移除有序集合中给定的排名区间的所有成员                       |
| ZREMRANGEBYSCORE key min max                   | 移除有序集合中给定的分数区间的所有成员                       |
| ZREVRANGE key start stop [WITHSCORES]          | 返回有序集中指定区间内的成员，通过索引，分数从高到低         |
| ZREVRANGEBYSCORE key max min [WITHSCORES]      | 返回有序集中指定分数区间内的成员，分数从高到低排序           |
| ZREVRANK key member                            | 返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序 |
| ZSCORE key member                              | 返回有序集中，成员的分数值                                   |
| ZUNIONSTORE destination numkeys key [key ...]  | 计算给定的一个或多个有序集的并集，并存储在新的 key 中        |
| ZSCAN key cursor [MATCH pattern] [COUNT count] | 迭代有序集合中的元素（包括元素成员和元素分值）               |

