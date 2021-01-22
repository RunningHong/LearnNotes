[TOC]

# hive数据倾斜

## 1 数据倾斜原因

map输出数据按key Hash的分配到reduce中，由于key分布不均匀、业务数据本身的特性、建表时考虑不周、等原因造成的reduce 上的数据量差异过大。

## 2 主要表现

reduce任务进度长时间卡在 99%或者 100%的附近，查看任务监控页面，发现只有少量 reduce 子任务未完成。主要是某几个 reduce 处理的数据量和平均数据相差太大，导致这几个reduce需要花费更多的时间。

## 3 容易数据倾斜的情况

1. key过于集中：如1千万的uid中有500万的uid为空，这样500万的数都会进入一个reduce
2. count(distinct xxx)时key的值过于集中：因为 count(distinct)是按 group by 字段分组，按 distinct 字段排序

## 4 数据倾斜解决

如何避免：对于key为空产生的数据倾斜，可以对其赋予一个随机值。

### 4.1 参数调节

```shell
#在map端中会做部分聚集操作，效率更高但需要更多的内存
hive.map.aggr = true;

#注意：只能对单个字段聚合。
#控制生成两个MR Job,第一个MR Job Map的输出结果随机分配到reduce中减少某些key值条数过多某些key条数过小造成的数据倾斜问题。
#在第一个 MapReduce 中，map 的输出结果集合会随机分布到 reduce 中，每个reduce 做部分聚合操作，并输出结果。这样处理的结果是，相同的 Group By Key 有可能分发到不同的reduce中，从而达到负载均衡的目的；
#第二个 MapReduce 任务再根据预处理的数据结果按照 Group By Key 分布到 reduce 中（这个过程可以保证相同的 Group By Key 分布到同一个 reduce 中），最后完成最终的聚合操作。
hive.groupby.skewindata=true;

# 判断数据倾斜的阈值，如果在join中发现同样的key超过该值则认为是该key是倾斜的join key，默认是100000；
hive.skewjoin.key=xxxxxx;
```

- `hive.groupby.skewindata=true;`控制生成两个MR Job
- 在第一个MR中，map 的输出结果集合会随机分布到 reduce 中，每个reduce 做部分聚合操作，并输出结果。这样处理的结果是，相同的 Group By Key 有可能分发到不同的reduce中，从而达到负载均衡的目的；
- 第二个MR任务再根据预处理的数据结果按照 Group By Key 分布到 reduce 中（这个过程可以保证相同的Group By Key分布到同一个reduce 中），最后完成最终的聚合操作。

### 4.2  语句优化

- 选用join key分布最均匀的表作为驱动表。做好列裁剪和filter操作，以达到两表做join 的时候，数据量相对变小的效果。
- 大小表Join：
    使用map join让小的维度表（1000 条以下的记录条数）先进内存。在map端完成reduce.
- 大表Join大表：
    把空值的key变成一个字符串加上随机数，把倾斜的数据分到不同的reduce上，由于null 值关联不上，处理后并不影响最终结果。
- count distinct大量相同特殊值:
    count distinct 时，将值为空的情况单独处理，如果是计算count distinct，可以不用处理，直接过滤，在最后结果中加1。如果还有其他计算，需要进行group by，可以先将值为空的记录单独处理，再和其他计算结果进行union。

## ps-相关资料

参考博客：https://www.cnblogs.com/qingyunzong/p/8847597.html