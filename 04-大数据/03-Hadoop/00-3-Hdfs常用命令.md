[TOC]

# Hdfs常用命令

## 1 创建文件夹-mkdir

```shell
# 创建一层文件
hdfs dfs -mkdir /user/hadoop

# 创建多层文件
hdfs dfs -mkdir -p /user/hadoop

# 删除
hdfs dfs -rmdir
```

## 2 本地文件上传-put

```shell
# 最终文件上传到hdfs为： /user/hadoop/test.txt
hdfs dfs -put /test.txt /user/hadoop

# 如果文件存在则覆盖
hdfs dfs -put -f /test.txt /user/hadoop
```

## 3 查看文件内容-cat/tail

```shell
hdfs dfs -cat /user/anna/input/wc.input
hdfs dfs -tail /user/anna/input/wc.input
```

## 4 文件下载-get

```shell
hadoop fs -get /user/anna/input/wc.input /opt/module/hadoop

# 批量下载
hadoop fs -get /user/anna/input/* /opt/module/hadoop
```

## 5 删除-rm

```shell
hdfs dfs -rm -r /user/anna/output

# 删除时不放入缓存
hdfs dfs -rm -r -skipTrash /user/anna/output
```

## 6 移动文件-cp

```shell
hadoop fs -cp /user/anna/input/wc.input /user/anna/test
```

## 7 目录/文件是否存在-test -e

```shell
    # 查看hdfs上文件分区目录是否创建，如果创建就删去
    hdfs dfs -test -e ${HDFS_LOCATION_PARTITION}
    if [[ $? -eq 0 ]]; then
        echo "###hdfs目录已存在，删除目录###"${HDFS_LOCATION_PARTITION}
    else
        echo "###hdfs目录不存在###"${HDFS_LOCATION_PARTITION}
    fi
```

## 8 列出文件-ls

```shell
hdfs dfs -ls /user/hadoop
```

## 9 统计文件大小-du

```shell
hdfs dfs -du -h /user/hadoop

# 总量查看（summary）
hdfs dfs -du -h -s /user/hadoop
```

