# 数据库作业（命名为MySQL）

图书表 id book_id author_id book_name pages price press
奖项表 id book_id author_id cup_type cup_time
作者表 id author_id author_name content

**一、设计表，写出建表语句(我给出的字段内容、名称仅供参考，各位同学可以按照自己的设计建表) 考察点：对字段定义的掌握，对字段类型的选择掌握**

```sql
# 整体说明：作者书写图书，图书可以获奖

# 图书表(图书表存储图书信息)
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

# 奖项表（奖项表存储奖项信息）
create table cup (
    id int(11) unsigned not null auto_increment comment '自增主键',
    cup_id int(11) not null default '0' comment '奖项的id',
    cup_name varchar(50) not null default '' comment '奖项名称',
    primary key (`id`)
) engine=InnoDB auto_increment=1 default CHARSET=utf8 COMMENT='奖项表';


# 获奖表（获奖表存储获奖图书以及获奖时间、类型等信息）
create table reward (
	id int(11) unsigned not null auto_increment comment '自增主键',
    cup_id int(11) not null default '0' comment '奖项id',
    book_id varchar(13) not null default '' comment '获奖图书id',
    cup_type varchar(20) not null default '' comment '奖项类型',
    cup_time datetime not null default '2019-01-01 00:00:00' comment '发奖时间',
    primary key (`id`)
)  engine=InnoDB auto_increment=1 default CHARSET=utf8 COMMENT='获奖表';

# 作者表 （存储作者信息）
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
alter table book add unique index uniq_book_id(book_id);

# cup的索引
alter table cup add unique index uniq_book_id(cup_id);

# reward的索引
alter table reward add index ind_cup_id(cup_id);
alter table reward add index ind_book_id(book_id);

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

insert into cup(cup_id,cup_name) values
('1','图书奖1'),
('2','图书奖2'),
('3','图书奖3');

insert into reward(cup_id,book_id,cup_type,cup_time) values
('1','0000000001','金奖','2019-02-02 12:00:000'),
('2','0000000002','银奖','2018-02-02 12:00:000'),
('3','0000000001','银奖','2018-02-02 12:00:000'),
('4','0000000004','金奖','2018-02-02 12:00:000');
```

**三、完成以下SQL**

1. **查询姓王的作者有多少**

   ```sql
   select count(*) as num from author where author.author_name like '王%';
   ```

2. **查询获奖作者总人数**

   ```sql
   # 由于一本图书可以有多个作者，而且一个作者可以有多本图书。
   # 我认为获奖作者总数指的所有获奖了的作者（不计算重复获奖）
   select 
   	count(distinct author.author_id) as num 
   from reward 
   left join book on reward.book_id=book.book_id
   right join author on author.author_id = book.author_id;
   ```

3. **查询同时获得过金奖、银奖的作者姓名**

   ```sql
   # 1.子查询列出所有获奖情况（人获了什么奖，如果获金奖就把gloden_num置位1，silver_num置位1）
   # 2.在1的基础上通过聚合筛选既获得金奖又获得银奖的人
   select author_name from (
       select author.author_name,
           reward.cup_type,
           if(reward.cup_type='金奖',1,0) gloden_num, # 金奖个数
           if(reward.cup_type='银奖',1,0) silver_num # 银奖个数
       from reward  
       left join book on reward.book_id=book.book_id
       right join author on author.author_id = book.author_id 
       where reward.id is not null
   ) as author_cuptype 
   group by author_name 
   having sum(gloden_num)>0 and sum(silver_num)>0;
   ```

4. **查询获得过金奖的图书有多少本，银奖的有多少本**

   ```sql
   # 1.子查询列出所有获奖情况
   # 2.计算金奖个数，银奖个数
   select 
   	sum(gloden_num) as gloden_num, # 获得金奖的个数 
   	sum(silver_num) as silver_num  # 获得银奖的个数
   from (
       select reward.id as reward_id,
           if(reward.cup_type='金奖',1,0) gloden_num, # 金奖个数
           if(reward.cup_type='银奖',1,0) silver_num # 银奖个数
       from reward  
       where reward.id is not null
   ) as author_cuptype;
   ```

5. **查询最近一年内获过奖的作者姓名**

   ```sql
   select 
   	author.author_name,
   	reward.cup_time
   from reward 
   left join book on reward.book_id=book.book_id
   right join author on author.author_id = book.author_id
   where reward.id is not null and reward.cup_time >= date_sub(CURDATE(),INTERVAL 1 YEAR);
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