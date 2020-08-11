[TOC]

# Hive中的各种排序

## 1 order by

作用：对数据进行**全局排序**

- 好处：可以进行全局排序

- 坏处：数据量大的时候，数据拉到一个节点，效率会非常低

如果使用了order by那么所有的数据都会**进入一个reduce**进行处理，所以当数据量特别大的时候效率很低（所有的数据拉到单机节点进行处理）。建议在小的数据集中使用order by进行排序。

- 若选择strict，则order by 需要指定limit（若有分区还有指定哪个分区）
- 若为nostrict，则limit不是必需的

即使设置了mapreduce.job.reduces的值大于1, 使用order by,时Hive在运行MR程序时也会设置为1覆盖。

## 2 distribute by

作用：所有相同的key发送到同一个reduce中（想想hash算法）

## 3 sort by

sort by排序的行的排序操作发生在发送这些行到reduce之前。

作用：进入reduce前进行排序

排序的次序依赖于排序列的类型，如果列是数值类型，那么排序按照数值排序，如果列式字符串类型，那么排序将按照字典排序。

## 4 cluster by

cluster by A 等同于 distribute by A sort by A

除了具有 distribute by 的功能外还兼具 sort by 的功能。

