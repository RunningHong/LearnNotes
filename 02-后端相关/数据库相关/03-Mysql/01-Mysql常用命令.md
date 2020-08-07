[TOC]

## Mysql常用命令

## 1 DML(Data Manipulation Language)

适用范围：对数据库中的数据进行一些简单操作，如insert,delete,update,select等.

### 1.1 新增-insert

```sql
-- 指定字段
INSERT INTO emp(ename, hiredate, sal, deptno) VALUES('zzx1', '2000-01-01', '2000', 1);

-- 一次多个值
insert into joke (gid,name)values(0,"joker"),(1,"jhj");

-- 不指定字段(values后面的顺序应该和字段的排列顺序一致)
INSERT INTO emp VALUES('zzx1', '2000-01-01', '2000', 1);
```

insert into select

```mysql
-- 语法
INSERT INTO table2(column_name(s))
SELECT column_name(s) FROM table1;

-- 如：
insert into user_tmp(user_id, user_name)
select
	user_id,
	user_name
from user
```

### 1.2 删除-delete

```
delete from xxx where xxx

如： delete from user where user_id='1'
```

### 1.3 修改-update

```
UPDATE emp SET sal=400 WHERE ename='zzx1';
```

### 1.4 查询-select

## 2 DDL(Data Definition Language)

适用范围：对数据库中的某些对象(例如，database,table)进行管理，如Create,Alter和Drop.

### 2.1 数据库相关

```
查看数据库
1：show databases;

打开数据库
2：use databaseName;             

创建数据库
3：create database databaseName default charset=utf8       
   drop database dbname
   
查看当前选中的数据库
4：select database()      

查看当前数据库版本
5：select version()              

查看建库语句
6：show create database databaseName   
```

### 2.2 表相关

```mysql
CREATE TABLE orders( 
    `id` INT UNSIGNED AUTO_INCREMENT, 
    `orders_title` VARCHAR(100) NOT NULL, 
    `orders_price` DOUBLE NOT NULL, 
    `create_date` DATE, 
    PRIMARY KEY ( `id` ) 
)ENGINE=InnoDB DEFAULT CHARSET=utf8 comment 'ddd';

-- 表重命名表名 RENAME TABLE 原表名 TO 新表名;
Rename table old_name to new_name;

-- 新增列
ALTER TABLE xxx ADD COLUMN xxx VARCHAR(100) NOT NULL COMMENT 'xxx';

-- 给表增加注释
alter table xxx comment = 'xxx';

-- 删除列
alter table xxx drop column xxx

-- 修改列名 Alter table 表名 change 列名 新列名 类型;
alter table xxx change old_col_name new_col_name varchar(10) comment 'xxx'

-- 修改列类型1 Alter table 表名 change 列名 列名 类型;
alter table xxx change col_name col_name char(4) 

-- 修改列类型 Alter table 表名 modify 列名 新类型;
alter table xxx modify name varchar(20)
```

## 3 数据导入&导出

### 3.1 导入-load

```
  load data  [low_priority] [local] infile 'file_name txt' [replace | ignore]
      into table tbl_name
      [fields
      [terminated by'\t']
      [OPTIONALLY] enclosed by '']
      [escaped by'\' ]]
      [lines terminated by'\n']
      [ignore number xxx lines]
      [(col_name1, col_name2)]


    LOAD DATA INFILE ... [REPLACE|IGNORE] INTO TABLE xxx terminated by ','： replace into 表示如果导入过程中有唯一性约束，直接覆盖；ignore into 则跳过。
    可以指定字段： LOAD DATA INFILE xxxx INTO TABLE xxx (col1,col2,...) terminated by ','
    可以设定值： LOAD DATA LOCAL INFILE xxx REPLACE INTO TABLE xxx (a,b,c,d,e,f) set g=11,h='xxx';


    load data local infile '${path}' replace into table ${mysql_table} \
    FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
```

### 3.2 导出

```
    > select * from e into outfile "/data/mysql/e.sql" fields terminated by ',';
    # cat /data/mysql/e.sql
    1669,Jim,Smith
    337,Mary,Jones
    2005,Linda,Black
    
    
    # 或者使用
    mysql -e xxx > file.tsv
    
    # 不导出表头
    mysql -N -e xxx > file.tsv
```

