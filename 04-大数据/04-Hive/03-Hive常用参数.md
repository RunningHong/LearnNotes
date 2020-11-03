# hive常用参数

```sql
-- 设置job名称
set mapred.job.name=pp_xxx_hongzh_zhang;

-- 动态分区相关
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.max.dynamic.partitions=100000;
set hive.exec.max.dynamic.partitions.pernode=100000;

-- mapreduce内存相关
set mapreduce.map.memory.mb=8192;
set mapreduce.map.java.opts=-Xmx5734M;
set mapreduce.reduce.memory.mb=8192;
set mapreduce.reduce.java.opts=-Xmx5734M;


-- 启动map最大的切片大小设置为256M
set mapreduce.input.fileinputformat.split.maxsize=268435456;
-- 一个节点上启动map最小的切片大小设置为32M
set mapreduce.input.fileinputformat.split.minsize.per.node=33554432;
-- 一个交换机下启动map最小的切片大小设置为32M
set mapreduce.input.fileinputformat.split.minsize.per.rack=33554432;



-- 手动控制mapper的个数-需要开启压缩
set mapreduce.map.output.compress=true;
set mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;
set hive.exec.compress.intermediate=true;
-- 执行前进行小文件合并
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
-- 设置map切片大小最大为256M
set mapred.max.split.size=268435456;
-- 一个节点上切片大小至少为50M
set mapred.min.split.size.per.node=52428800;
-- 一个交换机下split的至少的大小(这个值决定了多个交换机上的文件是否需要合并)
set mapred.min.split.size.per.rack=268435456;


set mapreduce.reduce.input.buffer.percent=1;
-- 禁止并行执行
set hive.exec.parallel=false;
-- 在map端中会做部分聚集操作，效率更高但需要更多的内存
set hive.map.aggr=true；


-- 设置reduce处理的大小为256M,会根据这个来计算reduce个数
set hive.exec.reducers.bytes.per.reducer=268435456;
-- group by操作是否支持倾斜数据负载均衡。思想:先打散再聚合
-- 注意：只能对单个字段聚合。
-- 控制生成两个MR Job,第一个MR Job Map的输出结果随机分配到reduce中减少某些key值条数过多某些key条数过小造成的数据倾斜问题。
-- 在第一个 MapReduce 中，map 的输出结果集合会随机分布到 reduce 中，每个reduce 做部分聚合操作，并输出结果。
-- 这样处理的结果是，相同的 Group By Key 有可能分发到不同的reduce中，从而达到负载均衡的目的；
-- 第二个 MapReduce 任务再根据预处理的数据结果按照 Group By Key 分布到 reduce 中（这个过程可以保证相同的Group By Key分布到同一个reduce 中），最后完成最终的聚合操作。
set hive.groupby.skewindata=true；


-- 判断数据倾斜的阈值，如果在join中发现同样的key超过该值则认为是该key是倾斜的join key，默认是100000；
hive.skewjoin.key
-- hive操作执行时的模式，默认是nonstrict非严格模式，如果是strict模式，很多有风险的查询会被禁止运行，比如笛卡尔积的join和动态分区；
hive.mapred.mode
-- 直接指定reduce大小为8
mapreduce.job.reduces=8
-- 设置reduce的个数，一般不用，如果集群资源不足，造成程序运行出现OOM(内存溢出不足)，可以根据推定的reduce个数手动增加数量
mapred.reduce.tasks = 15
-- 根据输入文件的大小决定是否将普通join转换为mapjoin的一种优化，默认不开启false；
hive.auto.convert.join
-- UDTF执行时hive是否发送进度信息到TaskTracker，默认是false；
hive.udtf.auto.progress
-- 当动态分区启用时，如果数据列里包含null或者空字符串的话，数据会被插入到这个分区，默认名字是HIVE_DEFAULT_PARTITION；
hive.exec.default.partition.name
-- 数据仓库的位置，默认是/user/hive/warehouse；
hive.metastroe.warehouse.dir
-- 设置一行最大的读取长度（默认是Integer.maxvalue）-当压缩包里有非法数据（一条数据过长的时候）
-- 超长行会导致内存溢出, 设置该参数可以确保 recordreader 跳过超长行
mapreduce.input.linerecordreader.line.maxlength
```

