[toc]

# map个数-切片&小文件合并

## 1 决定map个数的因素&举例

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

## 2 是不是map数越多越好？

答案是否定的。

如果一个任务有很多小文件（远远小于块大小128M），则每个小文件也会被当做一个块，用一个map任务来完成，
而一个map任务启动和初始化的时间远远大于逻辑处理的时间，就会造成很大的资源浪费。
而且，同时可执行的map数是受限的。

## 3 是不是保证每个map处理接近块大小就是最好的

答案也是不一定。

比如有一个127M的文件，正常会用一个map去完成，但这个文件只有一个或者两个小字段，却有几百万的记录，如果map处理的逻辑比较复杂，用一个map任务去做相关的逻辑，肯定也比较耗时。

## 4 源码中计算切片大小的公式

文件大小达到一个值才会进行切分，

文件进行切分的大小值=`Math.max(minSize, Math.min(maxSize,blockSize))`

- `mapreduce.input.fileinputformat.split.minsize`（默认值为1）
- `mapreduce.input.fileinputformat.split.maxsize` （默认值`Long.MAXValue`）

切片大小设置：

- `maxsize(切片最大值)<blockSize`，则会让切片变小，而且就等于配置的这个参数的值
- `minsize(切片最小值)>blockSize`，则可以让切片变得比blockSize还大

## 5 常用参数

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

