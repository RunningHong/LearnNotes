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
```

## 2 动态分区相关

```sql
-- 动态分区相关
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.max.dynamic.partitions=100000;
set hive.exec.max.dynamic.partitions.pernode=100000;
```

## 3 MR内存相关

```sql
-- 每个Map任务分配的内存使用量，单位mb
set mapreduce.map.memory.mb=8192;
-- 对map中对jvm child设置最大的堆大小
set mapreduce.map.java.opts='-Xmx8192M';


-- 每个reduce任务分配的内存使用量，单位mb
set mapreduce.reduce.memory.mb=8192;
-- 对reduce中对jvm child设置最大的堆大小
set mapreduce.reduce.java.opts='-Xmx8192M';
```

## 4 map个数-切片&小文件合并

### 4.1 决定map个数的因素&举例

通常情况下，作业会通过input的目录产生一个或者多个map任务。 
决定map个数主要的决定因素有：

- input的文件总个数
- input的文件大小
- 文件是否可split(如gz文件不可以切分)
- 集群设置的文件块大小（set dfs.block.size;查看）

举例（前提：默认集群文件块大小为128M）： 

1. 假设input目录下有1个文件(大小为780M)，那么hadoop会将该文件分隔成7个块（6个128M的块和1个12M的块），从而产生7个map数。
2. 假设input目录下有3个文件a,b,c,大小分别为10m，20m，130m，那么hadoop会分隔成4个块（10m,20m,128m,2m）,从而产生4个map数，即如果文件大于块大小，那么会拆分，如果小于块大小，则把该文件当成一个块。
3. 假设有一个大小为300M的gz文件，由于gz不可切分，所以这里map数为1。

### 4.2 是不是map数越多越好？

答案是否定的。

如果一个任务有很多小文件（远远小于块大小128M），则每个小文件也会被当做一个块，用一个map任务来完成，
而一个map任务启动和初始化的时间远远大于逻辑处理的时间，就会造成很大的资源浪费。
而且，同时可执行的map数是受限的。

### 4.3 是不是保证每个map处理接近块大小就是最好的

答案也是不一定。

比如有一个127M的文件，正常会用一个map去完成，但这个文件只有一个或者两个小字段，却有几百万的记录，如果map处理的逻辑比较复杂，用一个map任务去做相关的逻辑，肯定也比较耗时。

### 4.4 源码中计算切片大小的公式

文件大小达到一个值才会进行切分，

文件进行切分的大小值=`Math.max(minSize, Math.min(maxSize,blockSize))`

- `mapreduce.input.fileinputformat.split.minsize`（默认值为1）
- `mapreduce.input.fileinputformat.split.maxsize` （默认值`Long.MAXValue`）

切片大小设置：

- `maxsize(切片最大值)<blockSize`，则会让切片变小，而且就等于配置的这个参数的值
- `minsize(切片最小值)>blockSize`，则可以让切片变得比blockSize还大

### 4.5 相关参数

```sql
-- 启动map最大的切片大小设置为256M(详见4.4中分片大小的计算公式)
set mapreduce.input.fileinputformat.split.maxsize=268435456;

-- 执行前进行小文件合并（生成的合并文件最小size见下面两个参数）
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
-- 一个node上启动map最小的切片大小设置为32M
set mapreduce.input.fileinputformat.split.minsize.per.node=33554432;
-- 一个交换机下启动map最小的切片大小设置为32M
set mapreduce.input.fileinputformat.split.minsize.per.rack=33554432;



-- 其他不常用参数
-- 每个nodemanager节点上可运行的最大map任务数，默认值2，可根据实际值调整为10~100；
set mapreduce.tasktracker.map.tasks.maximum=30; 
-- 每个nodemanager节点上可运行的最大reduce任务数，默认值2，可根据实际值调整为10~100；
set mapreduce.tasktracker.reduce.tasks.maximum=30; 


-- 以下是旧版本的参数，已弃用（建议用前面新版本的参数值）
-- 设置map切片大小最大为256M
set mapred.max.split.size=268435456;
-- 一个节点上切片大小至少为50M
set mapred.min.split.size.per.node=52428800;
-- 一个交换机下split的至少的大小(这个值决定了多个交换机上的文件是否需要合并)
set mapred.min.split.size.per.rack=268435456;
```

## 5 reduce个数

reduce个数并不是越多越好，同map一样，启动和初始化reduce也会消耗时间和资源；
另外，有多少个reduce,就会有多少个输出文件，如果生成了很多个小文件，那么如果这些小文件作为下一个任务的输入，则也会出现小文件过多的问题。

当有以下情况的时候只有1个reduce(参数设置不会生效)

1. 使用order by，为了保证顺序只能在一个reduce中排序
2. 有笛卡尔积，使用join没带关联条件就会发生笛卡尔积,改善方法是加上on条件,注意hive的join on中只能用and而不能用or
3. count(distinct xxx)

```sql
-- 方式1：根据map输入大小确定reduce个数
-- 设置reduce处理的大小为256M, 会根据这个来计算reduce个数
set hive.exec.reducers.bytes.per.reducer=268435456;

-- 方式2：直接指定reduce个数
set mapred.reduce.tasks=15;
```



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











```sql




-- 根据输入文件的大小决定是否将普通join转换为mapjoin的一种优化，默认不开启false；
-- 注意：如果为left join 需要大表关联小表--hive没优化顺序， 反之right join需要小表关联大表，官网解释full join需要流化两张表所以不支持mapjoin
set hive.auto.convert.join=true;
-- 表文件的大小作为开启和关闭MapJoin的阈值(默认25000000约25M)
set hive.mapjoin.smalltable.filesize=25000000;


set mapreduce.reduce.input.buffer.percent=1;
-- 禁止并行执行
set hive.exec.parallel=false;

-- 在map端中会做部分聚集操作，效率更高但需要更多的内存
set hive.map.aggr=true；




-- group by操作是否支持倾斜数据负载均衡。思想:先打散再聚合
-- ！！！注意：只能对单个字段聚合（当启用时如果要在查询语句中对多个字段进行去重统计时会报错）。
-- 控制生成两个MR Job,第一个MR Job Map的输出结果随机分配到reduce中减少某些key值条数过多某些key条数过小造成的数据倾斜问题。
-- 在第一个 MapReduce 中，map 的输出结果集合会随机分布到 reduce 中，每个reduce 做部分聚合操作，并输出结果。
-- 这样处理的结果是，相同的 Group By Key 有可能分发到不同的reduce中，从而达到负载均衡的目的；
-- 第二个 MapReduce 任务再根据预处理的数据结果按照 Group By Key 分布到 reduce 中（这个过程可以保证相同的Group By Key分布到同一个reduce 中），最后完成最终的聚合操作。
set hive.groupby.skewindata=true；

-- 判断数据倾斜的阈值，如果在join中发现同样的key超过该值则认为是该key是倾斜的join key，默认是100000；
set hive.skewjoin.key=100000;

-- hive操作执行时的模式，默认是nonstrict非严格模式，如果是strict模式，很多有风险的查询会被禁止运行，比如笛卡尔积的join和动态分区；
hive.mapred.mode

-- 直接指定reduce大小为8
mapreduce.job.reduces=8
-- 设置reduce的个数，一般不用，如果集群资源不足，造成程序运行出现OOM(内存溢出不足)，可以根据推定的reduce个数手动增加数量
mapred.reduce.tasks = 15



-- UDTF执行时hive是否发送进度信息到TaskTracker，默认是false；
hive.udtf.auto.progress

-- 当动态分区启用时，如果数据列里包含null或者空字符串的话，数据会被插入到这个分区，默认名字是__HIVE_DEFAULT_PARTITION__
set hive.exec.default.partition.name=__HIVE_DEFAULT_PARTITION__;



-- 设置一行最大的读取长度（默认是Integer.maxvalue）-当压缩包里有非法数据（一条数据过长的时候）
-- 超长行会导致内存溢出, 设置该参数可以确保 recordreader 跳过超长行
mapreduce.input.linerecordreader.line.maxlength
```

