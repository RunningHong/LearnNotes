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

作用：相同的key发送到同一个reduce中（想想hash算法）

## 3 sort by

作用：ort by能保证局部有序（每个reducer出来的数据是有序的，但是不能保证所有的数据是有序的，除非只有一个reducer）

sort by 的数据在进入reduce前就完成排序。

排序的次序依赖于排序列的类型，如果列是数值类型，那么排序按照数值排序，如果列式字符串类型，那么排序将按照字典排序。

## 4 cluster by

cluster by A 等同于 distribute by A sort by A

除了具有 distribute by 的功能外还兼具 sort by 的功能。

distribute by 和 sort by 合用就相当于cluster by，**但是cluster by 不能指定排序规则为asc或 desc** ，只能是**升序**排列。

## 5 比较

### 5.1 distribute by和group by的区别

都是按key值划分数据 都使用reduce操作唯一不同的是，

distribute by只是单纯的分散数据，distribute by col – 按照col列把数据分散到不同的reduce。

而group by把相同key的数据聚集到一起，后续必须是聚合操作。

### 5.2 order by和sort by的区别

order by是全局排序 sort by只是确保每个reduce上面输出的数据有序。

如果只有一个reduce时，和order by作用一样。

