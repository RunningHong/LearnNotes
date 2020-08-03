[TOC]

# Hive常用

## 1 基本语法

### 1.1 创建表


【例子1】普通创建表：

```sql
create table test_table(
    viewTime INT, userid BIGINT,
    page_name STRING, ip STRING comment 'ip address'
) comment 'this is a test table'
PARTITIONED BY(dt STRING, country STRING)
STORED AS SEQUENCEFILE;
```

------

【例子2】指定字段之间的分隔符，使用ascll的1来分隔

```sql
create table page_view(
    viewTime INT, userid INT,
    page_url STRING, referrer_url STRING,
    ip STRING comment 'this is ip address'
) comment 'this is a test table'
PARTITIONED BY(dt STRING, country STRING)
ROW FROMAT DELIMITED FIELDS TERMINATED BY '1'
STORED AS SEQUENCEFILE;
```

------

【例子3】分桶表
对表的指定列进行分桶，是一个好的方法，它可以[有效地对数据集进行抽样查询]
如果没有分桶，则会进行随机抽样，由于在查询的时候，需要扫描所有数据，因此，效率不高。
例子通过一个userid的哈希函数，表被分成32个桶，在每个桶中数据是按照viewTime进行升序排序的，

```sql
create table page_view(
    viewTime INT, userid BIGINT,
    page_url STRING, referrer_url STRING,
    ip STRING comment 'this is ip address'
) comment 'bucket table'
PARTITIONED BY(dt STRING, country STRING)
CLUSTERED BY(userid) SORTED BY(viewTime) INTO 32 BUCKETS
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '1'
    COLLECTION ITEMS TERMINATED BY '2'
    MAP KEYS TERMINATED BY '3'
STORED AS SEQUENCEFILE;
```

------

【例子4】复杂结构

Array结构，Map结构，分桶

```sql
create table page_view(
    viewTime INT, userid BIGINT,
    friends ARRAY<BIGINT>, properties MAP<STRING, STRING>,
    ip STRING comment 'this is ip address'
) comment 'this is a test table'
PARTITIONED BY(
    dt STRING, 
    country STRING
)
CLUSTERED BY(userid) 
STORED BY(viewTime) INTO 32 BUCKETS
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '1'
    COLLECTION ITEMS TERMINATED BY '2'
    MAP KEYS TERMINATED BY '3'
STORED as SEQUENCEFILE;
```

### 1.2 浏览表和分区

```sql
-- 浏览所有表:
show tables;

-- 以正则来浏览你指定的表[以page开头的表]
show tables 'pages.*';

-- 列出分区，如果没有分区则抛出错误.
show partitiones page_view;

-- 展示表的列和列类型
desc page_view;

-- 显示表的创建语句
show create table page_view;

-- 查看分区详细信息
desc formatted table partition(dt='20191101');
```

### 1.3 修改表

```sql
-- 重命名表：
alter table old_table_name rename to new_table_name;

-- 对表的列名进行重命名
alter table old_table_name replace column (col1 type, ...);

-- 增加列
alter table table_name add columns(c1 STRING, c2 INT, ...);

-- hive修改表名备注
ALTER TABLE 数据库名.表名 SET TBLPROPERTIES('comment' = '新的表备注');
```

### 1.4 删除表和分区

```sql
-- 删除表
drop table table_name;

-- 删除分区
alter table table_name drop partition(ds='2016-04-04');

-- 批量删除分区
alter table xxx drop partition(dt<='2019-10-30');
```

### 1.5 加载数据

通过创建一个“外部表”来指向一个特定的HDFS路径，再使用HDFS的put或者copy命令，复制文件到指定的位置，并附上相应的行格式信息创建一个表指定位置。一旦完成用户就可以转换数据和插入

```sql
CREATE EXTERNAL TABLE page_view_stg(
    viewTime INT, userid BIGINT,
    page_url STRING, referrer_url STRING,
    ip STRING COMMENT 'IP Address of the User',
    country STRING COMMENT 'country of origination'
) COMMENT 'This is the staging page view table'
ROW FORMAT DELIMITED 
	FIELDS TERMINATED BY '44' 
	LINES TERMINATED BY '12'
STORED AS TEXTFILE
LOCATION '/user/data/staging/page_view';


hadoop dfs -put /tmp/pv_2016-06-08.txt /user/data/staging/page_view


INSERT OVERWRITE TABLE page_view PARTITION(dt='2016-06-08', country='US')
SELECT 
	pvs.viewTime, pvs.userid, 
	pvs.page_url, pvs.referrer_url, 
	null, null, pvs.ip
FROM page_view_stg pvs
WHERE pvs.country = 'US';
```

## 3 Hive时间戳转换

```sql
-- hive单个标准时间转化（10位unix）：
select unix_timestamp(cast('2017-08-30 10:36:15' as timestamp)) -> 1504060575
select unix_timestamp('20190811','yyyyMMdd') -> 1565452800

-- hive单个毫秒时间转化（自动转为10位unix）：
select unix_timestamp(cast('2017-12-01 16:42:08.771' as timestamp)) -> 1512117728


-- hive单个10位unix（变为标准格式）：
select from_unixtime(1510284058,'yyyy-MM-dd HH:mm:ss') -> 2017-11-10 11:20:58

-- hive单个13位unix（毫秒格式）：手动截取10位
select from_unixtime(cast(substr(1323308943123,1,10) as int),'yyyy-MM-dd HH:mm:ss') -> 2011-12-08 09:49:03


select from_unixtime( unix_timestamp('20190811','yyyyMMdd'), 'yyyy-MM-dd' )  -> 2019-08-11
select from_unixtime( unix_timestamp('2019-08-11','yyyy-MM-dd'), 'yyyyMMdd' )  -> 20190811
```

## 4 Hive中decode url

```sql
-- 方法1
-- url为待decode的字段，这边是使用反射的方式，来进行解码
select reflect('java.net.URLDecoder', 'decode',url, 'UTF-8')

-- 方法2
-- 手动的写解码,url为待decode的字段
select
    regexp_replace(
        regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        url, '\%7B', '{'
                    ), '\%22', '"'
                ), '\%3A', ':'
            ), '\%2C', ','
        ), '\%7D', '}'
    )
```

## 5 coalesce 函数

    coalesce()解释：返回参数中的第一个非空表达式（从左向右）
    如：select coalesce(a,b,c);
## 6 json解析

```
select get_json_object('[{"name":"王二","sex":"男","age":"25"}]', '$.[0].age') -> 25
select get_json_object('{"name":"王二","sex":"男","age":"25"}', '$.name') -> 王二
```

## 7 使用create table xxx as创建表

```
create table table_name as
select xxx from xxx
```

## 8 hive解析json数组-侧视图-表生成

```sql
-- 方法1：
-- 从里面往外面读代码（备注:在hive中可以直接运行，如果需要放到shell对于转义的部分需要多加一个\）
select
    get_json_object(item_json, '$.release_type') as release_type,
    get_json_object(item_json, '$.vid') as vid,
    get_json_object(item_json, '$.build_time') as build_time,
    platform
from ods_pp_release_history_2
LATERAL VIEW  explode(
    -- 分隔json里面的数组
    split(
        -- 将'},{',转换为'}###{'（注意此处需要替换的地方不要使用;可能语法会解析为结束）
        regexp_replace(
            -- 去掉最前和最后面的[]
            -- 也可以使用substr(release_data, 2, length(release_data)-1)这种方式
            regexp_replace(
                release_data,
                '\\\[|\\\]' ,
                ''
            ),
            '\\},\\{',
            '}###{'
        ),
        '###'
    )
) t1 AS item_json

-- 方法2：
-- 使用get_json_object得到json数组解析后的格式（如["张三", "李四"]），
-- 再使用表生成函数explode得到（如["张三"）
-- 再使用regexp_replace替换掉不需要的引号和中括号
select
    regexp_replace(guest_name, '(\\[|\\]|\\")', '') as guest_name
from (
        select
            get_json_object(json,'$.base.user.userName') username,
            get_json_object(json,'$.product.guests.name') guest_name_array,
            lower(order_no) as order_no
        from dw_pp_order_common
        where substr(order_create_time,1,10)>='2018-10-01'
            and substr(order_create_time,1,10)<'2019-12-01'
) t1
lateral view explode(split(guest_name_array, ',')) t3 as guest_name
```

## 9 窗口函数（lag/lead）

    LAG(col,n,DEFAULT) 用于统计窗口内往上第n行值
    参数1为列名，参数2为往上第n行（可选，默认为1），参数3为默认值（当往上第n行为NULL时候，取默认值，如不指定，则为NULL）
    
    LEAD(col,n,DEFAULT) 用于统计窗口内往下第n行值
    参数1为列名，参数2为往下第n行（可选，默认为1），参数3为默认值（当往下第n行为NULL时候，取默认值，如不指定，则为NULL）
    
    举例：
    lag(jump_type, 1) over(partition by cuid order by valtime) lag_jump_type, // 向上1位的值
    jump_type, // 原始值
    lead(jump_type, 1) over(partition by cuid order by valtime) lead_jump_type, // 向下1位的值
## 10 hive临时表

```sql
-- 创建为临时表的表仅对当前会话可见。数据将存储在用户的暂存目录中，并在会话结束时删除。
CREATE TEMPORARY TABLE list_bucket_multiple (col1 STRING, col2 int, col3 STRING);
```
## 11 hive随机取数-rand函数

```sql
select distinct a.* from tripdata a order by rand(12345)
```

## 12 hive cli 中查看方法

```
    show functions; 查看所有方法
    desc function xxxx
```

## 13 left semi join

    left semi join举例：
    select a.id from a left semi join b on a.id=b.id
    等价于
    select a.id from a left join b on a.id=b.id where b.id is not null
    
    解释：返回a表id在b表出现过的数据