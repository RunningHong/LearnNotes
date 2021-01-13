[TOC]

# Hive优化

## 1 Hadoop 框架计算特性

1、数据量大不是问题，数据倾斜是个问题

2、jobs 数比较多的作业运行效率相对比较低，比如即使有几百行的表，如果多次关联多次 汇总，产生十几个 jobs，耗时很长。原因是 map reduce 作业初始化的时间是比较长的

3、sum,count,max,min 等 UDAF，不怕数据倾斜问题，hadoop 在 map 端的汇总合并优化，使 数据倾斜不成问题

4、count(distinct userid)，在数据量大的情况下，效率较低，如果是多 count(distinct userid,month)效率更低，因为 count(distinct)是按 group by 字段分组，按 distinct 字段排序， 一般这种分布方式是很

倾斜的，比如 PV 数据，淘宝一天 30 亿的 pv，如果按性别分组，分 配 2 个 reduce，每个 reduce 期望处理 15 亿数据，但现实必定是男少女多

## 2 优化常用手段

1、好的模型设计事半功倍

2、解决数据倾斜问题

3、减少 job 数

4、设置合理的 MapReduce 的 task 数，能有效提升性能。(比如，10w+级别的计算，用 160个 reduce，那是相当的浪费，1 个足够)

5、了解数据分布，自己动手解决数据倾斜问题是个不错的选择。这是通用的算法优化，但 算法优化有时不能适应特定业务背景，开发人员了解业务，了解数据，可以通过业务逻辑精 确有效的解决数据倾斜问题

6、数据量较大的情况下，慎用 count(distinct)，group by 容易产生倾斜问题

7、对小文件进行合并，是行之有效的提高调度效率的方法，假如所有的作业设置合理的文 件数，对云梯的整体调度效率也会产生积极的正向影响

8、优化时把握整体，单个作业最优不如整体最优

## 3 排序选择

**cluster by**：对同一字段分桶并排序，不能和 sort by 连用

**distribute by + sort by**：分桶，保证同一字段值只存在一个结果文件当中，结合 sort by 保证 每个 reduceTask 结果有序

**sort by**：单机排序，单个 reduce 结果有序

**order by**：全局排序，缺陷是只能使用一个 reduce

**一定要区分这四种排序的使用方式和适用场景**















## ps-相关资料

https://www.cnblogs.com/qingyunzong/p/8847775.html

