[TOC]

# Python常用

## 1 拼接字符串

使用模板的形式：

```python
from string import Template

str_template="""
	this is ${parm1} speaking
	this is ${parm2} speaking
"""
final_str=Template(str_template).safe_substitute(
    parm1='tom',
    parm2='jerry'
)
print(final_str)

最终输出：
this is tom speaking
this is jerry speaking
```

使用字符串的format函数

```python
str="hello {0}".format('tom')
print(str)

最终输出：
hello tom
```

## 2 获取传入脚本的参数

```
import sys

param1=sys.argv[1]
param2=sys.argv[2]
```

## 3 python调用cmd

```python
import os

cmd="ls -h ./"
res = os.popen(cmd)
output_str = res.read()   # 获得输出字符串
print(output_str)
```

## 4 python连接mysql

```python
import pymysql
db = pymysql.connect(host="xxxx", user="xxxx", password="xxxx", port=3306, database="xxx")
cursor = db.cursor()
cursor.execute("select col1, col2, col3 from table_name;")
data = cursor.fetchall()

# 遍历结果集
for record in data:
    col1=record[0]
    col2=record[1]
    col3=record[2]
    print("col1:{0}  col2:{1}   col3:{2}".format(col1, col2, col3))
```

## 5 当前时间

```
import datetime
cur_time_second = datetime.datetime.now()
print("当前时间:", cur_time_second)

当前时间: 2020-06-18 17:38:48.767390
```

