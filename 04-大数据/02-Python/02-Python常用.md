[TOC]

# Python常用

## 1 获取传入脚本的参数

```
import sys

param1=sys.argv[1]
param2=sys.argv[2]
```

## 2 python调用cmd

```python
import os

cmd="ls -h ./"
res = os.popen(cmd)
output_str = res.read()   # 获得输出字符串
print(output_str)
```

## 3 python连接mysql

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

## 4 获取当前时间

```
import datetime
cur_time_second = datetime.datetime.now()
print("当前时间:", cur_time_second)

当前时间: 2020-06-18 17:38:48.767390
```

## 5 eval函数

eval() 函数用来执行一个字符串表达式，并返回表达式的值。

```
eval() 方法的语法:
eval(expression[, globals[, locals]])
expression -- 表达式。
globals -- 变量作用域，全局命名空间，如果被提供，则必须是一个字典对象。
locals -- 变量作用域，局部命名空间，如果被提供，可以是任何映射对象。
```

1、计算字符串中有效的表达式，并返回结果

```
>>> eval('pow(2,2)')
4
>>> eval('2 + 2')
4
>>> eval("n + 4")
85
```

2、将字符串转成相应的对象（如list、tuple、dict和string之间的转换）

```
>>> a = "[[1,2], [3,4], [5,6], [7,8], [9,0]]"
>>> b = eval(a)
>>> b
[[1, 2], [3, 4], [5, 6], [7, 8], [9, 0]]

>>> a = "{1:'xx',2:'yy'}"
>>> c = eval(a)
>>> c
{1: 'xx', 2: 'yy'}

>>> a = "(1,2,3,4)"
>>> d = eval(a)
>>> d
(1, 2, 3, 4)
```

3、将利用反引号转换的字符串再反转回对象

```
>>> list1 = [1,2,3,4,5]
>>> `list1`
'[1, 2, 3, 4, 5]'
>>> type(`list1`)
<type 'str'>
>>> type(eval(`list1`))
<type 'list'>
>>> a = eval(`list1`)
>>> a
[1, 2, 3, 4, 5]
```



