[TOC]

# hive数据倾斜

## 1 数据倾斜原因



## 2 数据倾斜解决



https://www.cnblogs.com/qingyunzong/p/8847597.html







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