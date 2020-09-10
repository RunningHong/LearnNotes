[TOC]

# mysql相关

## 1 简单的连接mysql数据库

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
    
cursor.close()
db.close()
```

## 2 常用方法封装

```python
#!/usr/bin q-python37
# -*- coding: utf-8 *-*

import pymysql
import sys
from string import Template
import os
import re

"""
说明：
	创建mysql连接，根据sql进行操作	
"""


class DB:
	def __init__(self, host='', port=3306, db='', user='', pwd='', charset='utf8'):
		conn_mes_template = "数据库连接信息：【host=${host}; db=${db}; user=${user}; pwd=${pwd}; port=${port}】"
		conn_mes = Template(conn_mes_template).safe_substitute(
			host=host, db=db, user=user, pwd=pwd, port=port)
		print(conn_mes)
		# 建立连接
		self.conn = pymysql.connect(host=host, port=port, db=db, user=user, passwd=pwd, charset=charset)
		# 创建游标，将结果作为字典返回游标,如果不设置cursor默认是返回一个列表的列表
		self.cur = self.conn.cursor(cursor=pymysql.cursors.DictCursor)

	def __enter__(self):
		# 返回游标
		return self.cur

	def __exit__(self, exc_type, exc_val, exc_tb):
		try:
			# 提交数据库并执行
			self.conn.commit()
			print("执行sql成功")
		except:
			print("执行sql发生错误进行回滚")
			self.conn.rollback()
		finally:
			# 关闭游标
			self.cur.close()
			# 关闭数据库连接
			self.conn.close()


# 执行sql--如新增/修改/删除等操作
def execute_sql(host='', port='', db='', user='', pwd='', sql=''):
	# 使用with as语法使用后连接会自动关闭
	with DB(host=host, port=port, db=db, user=user, pwd=pwd) as database_cur:
		print("执行sql:{sql}".format(sql=sql))
		# 执行语句
		database_cur.execute(sql)


# 执行sql返回执行结果(返回可迭代字典对象-对象数组)
def get_result_set_by_sql(host='', port='', db='', user='', pwd='', sql=''):
	# 使用with as语法使用后连接会自动关闭
	with DB(host=host, port=port, db=db, user=user, pwd=pwd) as database_conn:
		print("执行sql:{sql}".format(sql=sql))
		# 执行语句
		database_conn.execute(sql)
		# 返回拉取结果
		return database_conn.fetchall()
    

    # 示例
"""
# 引用当前路径的文件
import sys;
sys.path.append("/home/xxx/script/common")
import mysql_functions

sql='''
	select
		dt, tag,
		uv, exp_uv
	from dw_pp_vip_rights_flow
	where dt='2020-09-07'
		and tag like '%spend%'
	order by dt
'''

result_set = mysql_functions.get_result_set_by_sql(host='xxx', port=3306, 
		db='xxx', user='xxx', pwd='xxx', sql=sql)
for result in result_set:
	print(result)
	print(result.get('dt')) # 2020-09-07
	print(result.get('tag')) # tag_name
	print(result.get('uv')) # 123
	print(result.get('exp_uv')) # 234
"""
```

