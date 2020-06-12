[TOC]

# HIVE学习笔记

## 1 基本概念

### 1.1 hive

Hive 是基于 Hadoop 的一个数据仓库工具，实质就是一款基于 HDFS 的 MapReduce 计算框架，对存储在 HDFS 中的数据进行分析和管理。

### 1.2 HDFS

Hadoop分布式文件系统(HDFS)被设计成适合运行在通用硬件(commodity hardware)上的分布式文件系统。它和现有的分布式文件系统有很多共同点。但同时，它和其他的分布式文件系统的区别也是很明显的。HDFS是一个具有高度容错性的系统，适合部署在廉价的机器上。HDFS能提供高吞吐量的数据访问，非常适合大规模数据集上的应用。HDFS放宽了一部分POSIX约束，来实现流式读取文件系统数据的目的。HDFS在最开始是作为Apache Nutch搜索引擎项目的基础架构而开发的。HDFS是Apache Hadoop Core项目的一部分。

### 1.3 MapReduce

MapReduce是一种编程模型，用于大规模数据集（大于1TB）的并行运算。概念"Map（映射）"和"Reduce（归约）"，是它们的主要思想，都是从函数式编程语言里借来的，还有从矢量编程语言里借来的特性。它极大地方便了编程人员在不会分布式并行编程的情况下，将自己的程序运行在分布式系统上。 当前的软件实现是指定一个Map（映射）函数，用来把一组键值对映射成一组新的键值对，指定并发的Reduce（归约）函数，用来保证所有映射的键值对中的每一个共享相同的键组。

## 2 hive优缺点

优点：

​    1、可扩展性,横向扩展，Hive 可以自由的扩展集群的规模，一般情况下不需要重启服务 横向扩展：通过分担压力的方式扩展集群的规模 纵向扩展：一台服务器cpu i7-6700k 4核心8线程，8核心16线程，内存64G => 128G
​    2、延展性，Hive 支持自定义函数，用户可以根据自己的需求来实现自己的函数
​    3、良好的容错性，可以保障即使有节点出现问题，SQL 语句仍可完成执行

缺点：
    1、Hive 不支持记录级别的增删改操作，但是用户可以通过查询生成新表或者将查询结 果导入到文件中（当前选择的 hive-2.3.2 的版本支持记录级别的插入操作）
    2、Hive 的查询延时很严重，因为 MapReduce Job 的启动过程消耗很长时间，所以不能 用在交互查询系统中。
    3、Hive 不支持事务（因为没有增删改，所以主要用来做 OLAP（联机分析处理），而不是 OLTP（联机事务处理），这就是数据处理的两大级别）。

## 3 基本语法

### 3.1 创建表


【例子1】

创建表：

```sql
create table test_table(
    viewTime INT, userid BIGINT,
    page_name STRING, ip STRING comment 'ip address')
comment 'this is a test table'
PARTITIONED BY(dt STRING, country STRING)
STORED AS SEQUENCEFILE;
```

------

【例子2】
指定字段之间的分隔符，使用ascll的1来分隔

```sql
create table page_view(
    viewTime INT, userid INT,
    page_url STRING, referrer_url STRING,
    ip STRING comment 'this is ip address')
comment 'this is a test table'
PARTITIONED BY(dt STRING, country STRING)
ROW FROMAT DELIMITED FIELDS TERMINATED BY '1'
STORED AS SEQUENCEFILE;
```

------

【例子3】
对表的指定列进行分桶，是一个好的方法，它可以[有效地对数据集进行抽样查询]
如果没有分桶，则会进行随机抽样，由于在查询的时候，需要扫描所有数据，因此，效率不高。
例子通过一个userid的哈希函数，表被分成32个桶，在每个桶中数据是按照viewTime进行升序排序的，

```sql
create table page_view(
    viewTime INT, userid BIGINT,
    page_url STRING, referrer_url STRING,
    ip STRING comment 'this is ip address')
PARTITIONED BY(dt STRING, country STRING)
CLUSTERED BY(userid) SORTED BY(viewTime) INTO 32 BUCKETS
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '1'
    COLLECTION ITEMS TERMINATED BY '2'
    MAP KEYS TERMINATED BY '3'
STORED AS SEQUENCEFILE;
```

------

【例子4】

array结构，map结构，分桶

```sql
create table page_view(
    viewTime INT, userid BIGINT,
    friends ARRAY<BIGINT>, properties MAP<STRING, STRING>,
    ip STRING comment 'this is ip address')
comment 'this is a test table'
PARTITIONED BY(dt STRING, country STRING)
CLUSTERED BY(userid) STORED BY(viewTime) INTO 32 BUCKETS
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '1'
    COLLECTION ITEMS TERMINATED BY '2'
    MAP KEYS TERMINATED BY '3'
STORED as SEQUENCEFILE;
```

### 3.2 浏览表和分区

浏览所有表:

```sql
show tables;
```

------

以正则来浏览你指定的表[以page开头的表]

```sql
show tables 'pages.*';
```

------

列出分区，如果没有分区则抛出错误.

```sql
show partitioneds page_view;
```

------

展示表的列和列类型

```sql
describe page_view;
```

------

显示表的创建语句

```sql
show create table page_view;
```

### 3.3 修改表

重命名表：

```sql
alter table old_table_name rename to new_table_name;
```

------

对表的列名进行重命名

```sql
alter table old_table_name replace column (col1 type, ...);
```

------

增加列

```sql
alter table table_name add columns(c1 STRING, c2 INT, ...);
```

### 3.4 删除表和分区

删除表

```sql
drop table table_name;
```

------

删除分区

```sql
alter table table_name drop parition(ds='2016-04-04');
```

### 3.5 加载数据

通过创建一个“外部表”来指向一个特定的HDFS路径，再使用HDFS的put或者copy命令，复制文件到指定的位置，并附上相应的行格式信息创建一个表指定位置。一旦完成用户就可以转换数据和插入

```sql
CREATE EXTERNAL TABLE page_view_stg(viewTime INT, userid BIGINT,
                page_url STRING, referrer_url STRING,
                ip STRING COMMENT 'IP Address of the User',
                country STRING COMMENT 'country of origination')
COMMENT 'This is the staging page view table'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '44' LINES TERMINATED BY '12'
STORED AS TEXTFILE
LOCATION '/user/data/staging/page_view';

hadoop dfs -put /tmp/pv_2016-06-08.txt /user/data/staging/page_view

FROM page_view_stg pvs
INSERT OVERWRITE TABLE page_view PARTITION(dt='2016-06-08', country='US')
SELECT pvs.viewTime, pvs.userid, pvs.page_url, pvs.referrer_url, null, null, pvs.ip
WHERE pvs.country = 'US';
```

## 4 partition的作用和使用方法

在hive中select查询一般会扫描整个表内容，会消耗很多时间，有时只需要扫描表中关心的一部分数据，因此建表时引入了partition概念。

使用分区后每个分区以文件夹的形式单独存在文件夹的目录下，表和列名不区分大小写，分区是以字段形式在表结构中存在，通过`describe table` 可以查看字段的存在，但改字段不存放实际的数据内容，仅仅是分区表示

总的说来partition就是辅助查询，缩小查询范围，加快数据的检索速度和对数据按照一定的规格和条件进行管理。

实现方为把每一个分区都以分区文件夹的形式单独存放在文件夹目录下(所以在load数据的时候就需要指定分区)。

```sql
-- 数据加载进分区表中语法：
LOAD DATA [LOCAL] INPATH 'filepath' [OVERWRITE] INTO TABLE tablename [PARTITION (partcol1=val1, partcol2=val2 ...)]
-- 例：
LOAD DATA INPATH '/user/pv.txt' INTO TABLE day_hour_table PARTITION(dt='2008-08- 08', hour='08'); LOAD DATA local INPATH '/user/hua/*' INTO TABLE day_hour partition(dt='2010-07- 07');
-- 当数据被加载至表中时，不会对数据进行任何转换。Load操作只是将数据复制至Hive表对应的位置。数据加载时在表下自动创建一个目录，文件存放在该分区下。

-- 基于分区的查询的语句：
SELECT day_table.* FROM day_table WHERE day_table.dt>= '2008-08-08';

-- 查看分区语句：
hive> show partitions day_hour_table; OK dt=2008-08-08/hour=08 dt=2008-08-08/hour=09 dt=2008-08-09/hour=09
```

## 5 【Hive】毫秒时间戳格式化

```sql
-- 方法一
select from_unixtime(cast(server_time/1000 as bigint), 'yyyy-MM-dd') date
from access_log;

-- 方法二
select from_unixtime(cast(substring(server_time, 1, 10) as bigint),'yyyy-MM-dd HH') date
from access_log;

-- 完整时分秒
from_unixtime(cast(t2.oper_time/1000 as bigint), 'yyyy-MM-dd HH:mm:ss')
```

## 6 hive中decode url

```sql
# 方法1
# url为待decode的字段，这边是使用反射的方式，来进行解码
select reflect('java.net.URLDecoder', 'decode',url, 'UTF-8')

# 方法2
# 手动的写解码,url为待decode的字段
select
    regexp_replace(
        regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        url, '\%7B', '{'
                    ), '\%22', '"'
                ), '\%3A', ':'
            ), '\%2C', ','
        ), '\%7D', '}'
    )
```

## 7 hive表关联查询，如何解决数据倾斜的问题?

倾斜原因：

map输出数据按key Hash的分配到reduce中，由于key分布不均匀、业务数据本身的特、建表时考虑不周、等原因造成的reduce 上的数据量差异过大。

1)、key分布不均匀;

2)、业务数据本身的特性;

3)、建表时考虑不周;

4)、某些SQL语句本身就有数据倾斜;

如何避免：对于key为空产生的数据倾斜，可以对其赋予一个随机值。

解决方案

1>.参数调节：

hive.map.aggr = true

hive.groupby.skewindata=true

有数据倾斜的时候进行负载均衡，当选项设定位true,生成的查询计划会有两个MR Job。第一个MR Job中，Map的输出结果集合会随机分布到Reduce中，每个Reduce做部分聚合操作，并输出结果，这样处理的结果是相同的Group By Key有可能被分发到不同的Reduce中，从而达到负载均衡的目的；第二个MR Job再根据预处理的数据结果按照Group By Key 分布到 Reduce 中（这个过程可以保证相同的 Group By Key 被分布到同一个Reduce中），最后完成最终的聚合操作。

2>.SQL 语句调节：

1)、选用join key分布最均匀的表作为驱动表。做好列裁剪和filter操作，以达到两表做join 的时候，数据量相对变小的效果。

2)、大小表Join：

使用map join让小的维度表（1000 条以下的记录条数）先进内存。在map端完成reduce.

4)、大表Join大表：

把空值的key变成一个字符串加上随机数，把倾斜的数据分到不同的reduce上，由于null 值关联不上，处理后并不影响最终结果。

5)、count distinct大量相同特殊值:

count distinct 时，将值为空的情况单独处理，如果是计算count distinct，可以不用处理，直接过滤，在最后结果中加1。如果还有其他计算，需要进行group by，可以先将值为空的记录单独处理，再和其他计算结果进行union。

## 8 hive中 Sort By，Order By，Cluster By，Distrbute By各代表什么意思

order by：会对输入做全局排序，因此只有一个reducer（多个reducer无法保证全局有序）。只有一个reducer，会导致当输入规模较大时，需要较长的计算时间。

sort by：不是全局排序，其在数据进入reducer前完成排序。

distribute by：按照指定的字段对数据进行划分输出到不同的reduce中。

cluster by：除了具有 distribute by 的功能外还兼具 sort by 的功能。

## 9 hive 常用的参数设置

```
set mapred.job.name=pp_xxx_hongzh_zhang; -- 设置job名称
    set hive.exec.dynamic.partition.mode=nonstrict;
    set hive.exec.dynamic.partition=true;
    set hive.exec.max.dynamic.partitions=100000;
    set hive.exec.max.dynamic.partitions.pernode=100000;
    set mapreduce.map.memory.mb=8192;
    set mapreduce.map.java.opts=-Xmx5734M;
    set mapreduce.reduce.memory.mb=8192;
    set mapreduce.reduce.java.opts=-Xmx5734M;

    -- 这里的参数是启动时的大小
    set mapreduce.input.fileinputformat.split.maxsize=268435456; -- 启动map最大的切片大小设置为256M
    set mapreduce.input.fileinputformat.split.minsize.per.node=33554432; -- 一个节点上启动map最小的切片大小设置为32M
    set mapreduce.input.fileinputformat.split.minsize.per.rack=33554432; -- 一个交换机下启动map最小的切片大小设置为32M

    -- 手动控制mapper的个数-需要开启压缩
    set mapreduce.map.output.compress=true;
    set mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;
    set hive.exec.compress.intermediate=true;
    set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat; -- 执行前 进行小文件合并
    set mapred.max.split.size=268435456; -- 设置map切片大小最大为256M
    set mapred.min.split.size.per.node=52428800; -- 一个节点上切片大小至少为50M
    set mapred.min.split.size.per.rack=268435456; -- 一个交换机下split的至少的大小(这个值决定了多个交换机上的文件是否需要合并) ，

    set mapreduce.reduce.input.buffer.percent=1;
    set hive.exec.parallel=false; -- 禁止并行执行
    set hive.map.aggr=true；-- 在map端中会做部分聚集操作，效率更高但需要更多的内存

    set hive.exec.reducers.bytes.per.reducer=268435456; -- 设置reduce处理的大小为256M,会根据这个来计算reduce个数
    set hive.groupby.skewindata=true；-- group by操作是否支持倾斜数据负载均衡。思想:先打散再聚合
    注意：只能对单个字段聚合。
    控制生成两个MR Job,第一个MR Job Map的输出结果随机分配到reduce中减少某些key值条数过多某些key条数过小造成的数据倾斜问题。
    在第一个 MapReduce 中，map 的输出结果集合会随机分布到 reduce 中，每个reduce 做部分聚合操作，并输出结果。这样处理的结果是，相同的 Group By Key 有可能分发到不同的reduce中，从而达到负载均衡的目的；
    第二个 MapReduce 任务再根据预处理的数据结果按照 Group By Key 分布到 reduce 中（这个过程可以保证相同的 Group By Key 分布到同一个 reduce 中），最后完成最终的聚合操作。

    hive.skewjoin.key：判断数据倾斜的阈值，如果在join中发现同样的key超过该值则认为是该key是倾斜的join key，默认是100000；
    hive.mapred.mode：hive操作执行时的模式，默认是nonstrict非严格模式，如果是strict模式，很多有风险的查询会被禁止运行，比如笛卡尔积的join和动态分区；
    mapreduce.job.reduces=8 ：直接指定reduce大小为8
    mapred.reduce.tasks = 15 ： 设置reduce的个数，一般不用，如果集群资源不足，造成程序运行出现OOM(内存溢出不足)，可以根据推定的reduce个数手动增加数量
    hive.auto.convert.join：根据输入文件的大小决定是否将普通join转换为mapjoin的一种优化，默认不开启false；
    hive.udtf.auto.progress：UDTF执行时hive是否发送进度信息到TaskTracker，默认是false；
    hive.exec.default.partition.name：当动态分区启用时，如果数据列里包含null或者空字符串的话，数据会被插入到这个分区，默认名字是HIVE_DEFAULT_PARTITION；
    hive.metastroe.warehouse.dir：数据仓库的位置，默认是/user/hive/warehouse；
```

## 10 