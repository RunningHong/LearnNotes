[toc]

# hive常用参数

## 1 基础参数

```sql
-- 设置job名称
set mapred.job.name=pp_xxx_hongzh_zhang;

-- 查看集群设置的文件块大小
-- 根据版本而定，新版的默认是256M
set dfs.block.size; 

-- 数据仓库的位置，默认是/user/hive/warehouse；
set hive.metastroe.warehouse.dir;

-- hive操作执行时的模式，默认是nonstrict非严格模式，
-- 如果是strict模式，很多有风险的查询会被禁止运行，比如笛卡尔积的join和动态分区；
set hive.mapred.mode=nonstrict;

-- 让CLI打印出字段名称
set hive.cli.print.header=true;
```

## 2 动态分区相关

```sql
-- 动态分区相关
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
-- 所有执行MR的节点上，最大一共可以创建多少个动态分区。
set hive.exec.max.dynamic.partitions=100000;
-- 在每个执行MR的节点上，最大可以创建多少个动态分区
set hive.exec.max.dynamic.partitions.pernode=100000;

-- 整个MR Job中，最大可以创建多少个HDFS文件。
-- 在linux系统当中，每个linux用户最多可以开启1024个进程，每一个进程最多可以打开2048个文件，即持有2048个文件句柄，下面这个值越大，就可以打开文件句柄越大
set hive.exec.max.created.files=100000;

-- 当动态分区启用时，如果数据列里包含null或者空字符串的话，数据会被插入到这个分区，默认名字是__HIVE_DEFAULT_PARTITION__
set hive.exec.default.partition.name=__HIVE_DEFAULT_PARTITION__;
```

## 3 MR内存相关

```sql
-- 设置map堆最大大小为6554M
set mapred.child.map.java.opts=-Xmx6554M;
-- 设置reduce堆最大大小6554M
set mapred.child.reduce.java.opts=-Xmx6554M;



-- container的内存-每个Map任务分配的内存使用量，单位mb
set mapreduce.map.memory.mb=8192;
-- 对map中对jvm设置最大的堆大小
set mapreduce.map.java.opts='-Xmx8192M';

-- container的内存-每个reduce任务分配的内存使用量，单位mb
set mapreduce.reduce.memory.mb=8192;
-- 对reduce中对jvm设置最大的堆大小
set mapreduce.reduce.java.opts='-Xmx8192M';
```

`mapred.map.child.java.opts`和`mapreduce.map.memeory.mb`的区别：

- `mapreduce.map.memory.mb`是向ResourceManager申请的内存资源大小，这些资源可用用于各种程序语言编写的程序
- `mapred.map.child.java.opts` 一般只用于配置JVM参数

## 4 map个数-切片&小文件合并

```sql
-- 启动map最大的切片大小设置为256M(详见4.4中分片大小的计算公式)
set mapreduce.input.fileinputformat.split.maxsize=268435456;

-- 执行前进行小文件合并（生成的合并文件最小size见下面两个参数）
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
-- 一个node上启动map最小的切片大小设置为32M
set mapreduce.input.fileinputformat.split.minsize.per.node=33554432;
-- 一个交换机下启动map最小的切片大小设置为32M
set mapreduce.input.fileinputformat.split.minsize.per.rack=33554432;



-- 其他不常用参数，一般不改动
-- 每个nodemanager节点上可运行的最大map任务数，默认值2，可根据实际值调整为10~100；
set mapreduce.tasktracker.map.tasks.maximum=30; 
-- 每个nodemanager节点上可运行的最大reduce任务数，默认值2，可根据实际值调整为10~100；
set mapreduce.tasktracker.reduce.tasks.maximum=30; 


-- 以下是旧版本的参数，已弃用！！（建议用前面新版本的参数值）
-- 设置map切片大小最大为256M
-- set mapred.max.split.size=268435456;
-- 一个节点上切片大小至少为50M
-- set mapred.min.split.size.per.node=52428800;
-- 一个交换机下split的至少的大小(这个值决定了多个交换机上的文件是否需要合并)
-- set mapred.min.split.size.per.rack=268435456;
```

## 5 reduce个数

```sql
-- 方式1：根据map输入大小确定reduce个数
-- 设置reduce处理的大小为256M, 会根据这个来计算reduce个数
set hive.exec.reducers.bytes.per.reducer=268435456;

-- 方式2：直接指定reduce个数(不建议使用)
-- 一般不用，如果集群资源不足，造成程序运行出现OOM(内存溢出不足)，可以根据推定的reduce个数手动增加数量
set mapred.reduce.tasks=15;
```

reduce个数并不是越多越好，同map一样，启动和初始化reduce也会消耗时间和资源；
另外，有多少个reduce,就会有多少个输出文件，如果生成了很多个小文件，那么如果这些小文件作为下一个任务的输入，则也会出现小文件过多的问题。

当有以下情况的时候只有1个reduce(参数设置不会生效)

1. 使用order by，为了保证顺序只能在一个reduce中排序
2. 有笛卡尔积，使用join没带关联条件就会发生笛卡尔积,改善方法是加上on条件,注意hive的join on中只能用and而不能用or
3. count(distinct xxx)

## 6 map输出压缩&reduce输出时合并小文件

```sql
-- map输出结果是否进行压缩
-- 如果压缩就会多耗cpu，但是减少传输时间，如果不压缩，就需要较多的传输带宽。
set mapreduce.map.output.compress=true;
set mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;
set hive.exec.compress.intermediate=true;


-- 在Map-only的任务结束时合并小文件
set hive.merge.mapfiles=true; 
-- 在Map-Reduce的任务结束时合并小文件（mr任务用这个参数）,会增加一个MR
set hive.merge.mapredfiles=true;         
-- 合并后文件的大小为128M
set hive.merge.size.per.task=128000000;        
-- 当输出文件的平均大小小于128M时，启动一个独立的map-reduce任务进行文件merge
set hive.merge.smallfiles.avgsize=128000000;   
```

## 7 map join优化

map join原理见./07-Join原理 中的的第二节

```sql
-- 根据输入文件的大小决定是否将普通join转换为mapjoin的一种优化，默认不开启false；
-- 注意：如果为left join 需要大表关联小表--hive没优化顺序， 反之right join需要小表关联大表，官网解释full join需要流化两张表所以不支持mapjoin
set hive.auto.convert.join=true;
-- 表文件的大小作为开启和关闭MapJoin的阈值(默认25000000约25M)
set hive.mapjoin.smalltable.filesize=25000000;
```

## 8 数据倾斜优化

```sql
-- group by操作是否支持倾斜数据负载均衡。思想:先打散再聚合
set hive.groupby.skewindata=true；

-- 判断数据倾斜的阈值，如果在join中发现同样的key超过该值则认为是该key是倾斜的join key，默认是100000；
set hive.skewjoin.key=100000;
```

`set hive.groupby.skewindata=true；`

思想：先打散再聚合
注意：只能对单个字段聚合（当启用时如果要在查询语句中对多个字段进行去重统计时会报错）。

- 控制生成两个MR Job
- 在第一个MR中，map 的输出结果集合会随机分布到 reduce 中，每个reduce 做部分聚合操作，并输出结果。这样处理的结果是，相同的 Group By Key 有可能分发到不同的reduce中，从而达到负载均衡的目的；
- 第二个MR任务再根据预处理的数据结果按照 Group By Key 分布到 reduce 中（这个过程可以保证相同的Group By Key分布到同一个reduce 中），最后完成最终的聚合操作。

总结：

- 它使计算变成了两个MR，先在第一个中在 shuffle 过程 partition 时随机给 key 打标记，使每个key 随机均匀分布到各个 reduce 上计算，但是这样只能完成部分计算，因为相同key没有分配到相同reduce上。
- 所以需要第二次的MR,这次就回归正常 shuffle，但是数据分布不均匀的问题在第一次MR已经有了很大的改善，因此基本解决数据倾斜。因为大量计算已经在第一次MR中随机分布到各个节点完成。

```shell
# 注意: 当set hive.groupby.skewindata=ture;时如果要在查询语句中对多个字段进行去重统计时会报错。
hive> set hive.groupby.skewindata=true;
hive> select count(distinct id),count(distinct x) from test;
FAILED: SemanticException [Error 10022]: DISTINCT on different columns not supported with skew in data


# 使用下面的方式是正确的
hive> select count(distinct id, x) from test; 
```

## 99 其他参数

```sql
-- 禁止并行执行
set hive.exec.parallel=false;
-- 同一个sql允许最大并行度，默认为8。
set hive.exec.parallel.thread.number=16; 


-- 开启map端combiner，在map端中会做部分聚集操作，效率更高但需要更多的内存
set hive.map.aggr=true；
-- 在Map端进行聚合操作的条目数目
set hive.groupby.mapaggr.checkinterval = 100000;


-- Hive某些情况的查询可以不必使用MapReduce计算。
-- 例如：SELECT * FROM test;
set hive.fetch.task.conversion=more;


-- 本地模式
-- 有时Hive的输入数据量是非常小，直接在本地运行速度会更快
set hive.exec.mode.local.auto=true;
-- job的输入数据大小必须小于参数(默认128MB)
set hive.exec.mode.local.auto.inputbytes.max;


-- 保存map输出文件的堆内存比例，默认0.0
-- 该参数可能会引起bug，建议使用默认值
set mapreduce.reduce.input.buffer.percent=1;

-- UDTF执行时hive是否发送进度信息到TaskTracker，默认是false；
set hive.udtf.auto.progress=false;

-- 设置一行最大的读取长度, 当压缩包里有非法数据（一条数据过长的时候）
-- 超长行会导致内存溢出, 设置该参数可以确保 recordreader 跳过超长行
set mapreduce.input.linerecordreader.line.maxlength=1000000;
```

