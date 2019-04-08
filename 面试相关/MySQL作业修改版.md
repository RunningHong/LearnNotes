# 数据库作业（命名为MySQL）

图书表 id book_id author_id book_name pages price press
奖项表 id book_id author_id cup_type cup_time
作者表 id author_id author_name content

**一、设计表，写出建表语句(我给出的字段内容、名称仅供参考，各位同学可以按照自己的设计建表) 考察点：对字段定义的掌握，对字段类型的选择掌握**

```sql
#导师，我再细想了一下，确实感觉设计有点问题。我原来的奖项想法（如矛盾文学奖下面还有金奖、银奖、一等奖、#二等奖、优秀奖...，即奖项的全称有矛盾文学金奖、矛盾文学银奖..，所以我认为在这会有冗余.）,在现实生活
#中图书的奖项应该就只有一种那就是矛盾文学奖。对现实场景忽略了。

# 图书表
# 说明:早期的ISBN一共有10位，现在扩展到了13位,所以为了兼容book_id设置为varchar(13)
create table book (
	id int(11) unsigned not null auto_increment comment '自增主键',
    book_id varchar(13) not null default '' comment '图书id,即ISBN',
    author_id int(11) not null default '0' comment '作者id',
    book_name varchar(100) not null default '' comment '图书名称',
    pages int(11) unsigned not null default '0' comment '页数',
    price decimal(5,2) unsigned not null default '0' comment '图书价格',
    press varchar(150) not null default '' comment '出版社',
    primary key (`id`)
) engine=InnoDB auto_increment=1 default CHARSET=utf8 COMMENT='图书表';

# 奖项表
create table cup (
    id int(11) unsigned not null auto_increment comment '自增主键',
    book_id varchar(13) not null default '' comment '图书id,即ISBN',
	author_id int(11) unsigned not null default '0' comment '作者id',
    cup_type varchar(20) not null default '' comment '奖项类型',
    cup_time datetime not null default '2019-01-01 00:00:00' comment '发奖时间',
    primary key (`id`)
) engine=InnoDB auto_increment=1 default CHARSET=utf8 COMMENT='奖项表';

# 作者表
create table author (
	id int(11) unsigned not null auto_increment comment '自增主键',
    author_id int(11) unsigned not null default '0' comment '作者id',
    author_name varchar(50) not null default '' comment '姓名',
    content varchar(1000) not null default '' comment '简介',
    primary key (`id`)
) engine=InnoDB auto_increment=1 default CHARSET=utf8 COMMENT='作者表';
```

**二、设计索引,写出创建索引的语句 考察点：对索引字段选择的掌握，对DDL合并技巧的掌握**

```sql
# book的索引
alter table book add index ind_book_id(book_id);
alter table book add index ind_author_id(author_id);

# cup的索引
alter table cup add index ind_book_id(book_id);
alter table cup add index ind_author_id(author_id);

# author的索引
alter table author add index ind_author_id(author_id);
```

```sql
# 模拟数据
insert into author(author_id, author_name, content) values
(1, '张三','这是张三'),
(2, '李四','这是李四'),
(3, '王五','这是王五');

insert into book(book_id,author_id,book_name,pages,price,press) values
("0000000001", "1","图书1","200",'88','出版社1'),
("0000000002", "2","图书2","120",'36','出版社2'),
("0000000003", "3","图书3","52",'45','出版社3'),
("0000000004", "1","图书4","123",'42','出版社3');

insert into cup(author_id,book_id,cup_type,cup_time) values
('1','0000000001','金奖','2019-02-02 12:00:000'),
('1','0000000002','银奖','2018-02-02 13:00:000'),
('2','0000000001','银奖','2019-03-02 11:00:000'),
('3','0000000004','金奖','2018-09-02 12:00:000'),
('1','0000000001','铜奖','2019-02-02 12:00:000');
```

**三、完成以下SQL**

图书表 id book_id author_id book_name pages price press
奖项表 id book_id author_id cup_type cup_time
作者表 id author_id author_name content

1. **查询姓王的作者有多少**

   ```sql
   select count(*) as author_num from author where author.author_name like '王%';
   ```

2. **查询获奖作者总人数**

   ```sql
   # 作者不重复
   select count(distinct author_id) as total_num from cup;
   ```

3. **查询同时获得过金奖、银奖的作者姓名**

   ```sql
   # 首先过滤只剩下金奖银奖的人，再通过group by以及having留下拥有两种类型奖项的人
   select 
   	author.author_name
   from cup
   left join author on cup.author_id = author.author_id
   where cup.cup_type='金奖' || cup.cup_type='银奖'
   group by author.author_id
   having count(cup.cup_type) = 2;
   ```

4. **查询获得过金奖的图书有多少本，银奖的有多少本**

   ```sql
   # 首先过滤只剩下金奖银奖，再利用count不统计null的特性对金奖银奖图书进行统计
   select
   	count(if(cup_type='金奖', id, null)) as goloden_num,
   	count(if(cup_type='银奖', id, null)) as silver_num
   from cup
   where cup.cup_type='金奖' || cup.cup_type='银奖';
   ```

5. **查询最近一年内获过奖的作者姓名**

   ```sql
   select 
   	author_name
   from author
   left join cup ON author.author_id = cup.author_id
   WHERE cup.cup_time >= date_sub(curdate(),interval 1 YEAR);
   ```

四、

1. 如何查看表的结构信息？如何查看索引选择性？

   ```sql
   # 查看表的结构信息 
   show create table `tableName`;
   
   #查看索引选择性 
   show index from `tableName`;
   ```

2. 联合索引中的字段顺序应该如何设计？

   ```
   将最常用，区分度高的字段放在最左边。
   ```

3. 以下查询应如何创建索引？ select * from tb1 where name='zww' order by create_time desc limit 10; select * from tb1 where create_time between '2016-08-01 0:00:00' and '2016-08-31 23:59:59';

   ```sql
   alter table tb1 ind_name(name);
   alter table tb1 ind_create_time(create_time);
   ```

4. int(10)和varchar(10)两个字段的(10)有什么区别？

   ```
   int(10)中的10表示显示宽度，不是实际的空间大小。
   varchar(10)中的10表示可容纳的最大字符数为10。
   ```

5. 在utf8字符集和utf8mb4字符集下，varchar(50)分别能存储多少字符？ 创建索引时，字符串长度分别为多少，才能成功创建完整索引（而不是前缀索引）

   ```txt
   varchar(50)代表可容纳的最大字符数为50，在utf8字符集下和utf8mb4字符集都能储存50字符，
   区别是utf8一个字符最多占3个字节，utf8mb4一个字符最多占4个字节。
   
   varchar创建完整索引的长度界限为767字节。
   所以utf8下，不超过767/3=255个字符，utf8mb4下不超过767/4=191个字符，就可以创建完整索引
   ```

6. 以下查询如何创建索引能够实现覆盖索引优化？(请给出具体SQL) select invalid_time_flag from pushtoken_android_62  where uid = 'AC54E24E-FB73-3981-C4BC-CED8D69407F8'  and pid = '10010' select count(*) from pushtoken_android_62  where uid = 'AC54E24E-FB73-3981-C4BC-CED8D69407F8'  and pid = '10010'

   ```sql
   # 索引要包含所有的查询字段，并且区分度高的字段放在最左边
   alter table pushtoken_android_62 add index idx_uid_pid_invalid_time_flag(uid,pid,invalid_time_flag);
   ```

考察点：对索引设计的理解，对字段长度含义的理解，对字符集影响的理解，对覆盖索引概念的理解

