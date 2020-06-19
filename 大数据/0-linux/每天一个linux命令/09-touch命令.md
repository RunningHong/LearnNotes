[TOC]

linux的touch命令一般用来修改文件时间戳，或者新建一个不存在的文件。

# 一．命令格式：

```
touch [参数]... 文件...
```

# 二．命令参数：

| 参数 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| -a   | 或--time=atime或--time=access或--time=use 　只更改存取时间。 |
| -c   | 或--no-create 　不建立任何文档。                             |
| -d   | 使用指定的日期时间，而非现在的时间。                         |
| -f   | 此参数将忽略不予处理，仅负责解决BSD版本touch指令的兼容性问题。 |
| -m   | 或--time=mtime或--time=modify 　只更改变动时间。             |
| -r   | 把指定文档或目录的日期时间，统统设成和参考文档或目录的日期时间相同。 |
| -t   | 使用指定的日期时间，而非现在的时间。                         |

# 三．命令功能：

touch命令参数可更改文档或目录的日期时间，包括存取时间和更改时间。

# 四．使用实例：



## 1. 创建file1和file2两个空文件

命令：

```
 touch file1 file2
```

输出：

```
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
hc@hc-virtual-machine:~/test$ touch file1 file2
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
-rw-r--r--  1 hc hc    0 11月  1 09:48 file1
-rw-r--r--  1 hc hc    0 11月  1 09:48 file2
```

说明：

如果加入 -c 参数，当目标文件不存在时，不会创建新文件，如果目标文件存在，则会修改文件时间属性为当前系统时间

```
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
-rw-r--r--  1 hc hc    0 11月  1 09:48 file1
-rw-r--r--  1 hc hc    0 11月  1 09:48 file2
hc@hc-virtual-machine:~/test$ touch -c file2
hc@hc-virtual-machine:~/test$ touch -c file3
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
-rw-r--r--  1 hc hc    0 11月  1 09:48 file1
-rw-r--r--  1 hc hc    0 11月  1 09:50 file2
```



## 2. 将file1的时间改为file2的时间

命令：

```
touch -r file2 file1
```

输出：

```
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
-rw-r--r--  1 hc hc    0 11月  1 09:48 file1
-rw-r--r--  1 hc hc    0 11月  1 09:50 file2
hc@hc-virtual-machine:~/test$ touch -r file2 file1
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
-rw-r--r--  1 hc hc    0 11月  1 09:50 file1
-rw-r--r--  1 hc hc    0 11月  1 09:50 file2
```



## 3.指定文件的日期时间

命令：

```
touch -t 201810011003.17 file2
```

输出：

```
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
-rw-r--r--  1 hc hc    0 11月  1 09:50 file1
-rw-r--r--  1 hc hc    0 11月  1 09:50 file2
hc@hc-virtual-machine:~/test$ touch -t 201810011003.17 file2
hc@hc-virtual-machine:~/test$ ll
总用量 8
drwxr-xr-x  2 hc hc 4096 11月  1 09:48 ./
drwxr-xr-x 25 hc hc 4096 10月 31 19:52 ../
-rw-r--r--  1 hc hc    0 11月  1 09:50 file1
```

说明：

-t time 使用指定的时间值 time 作为指定文件相应时间戳记的新值。此处的 time规定为如下形式的十进制数:

```
 [[CC]YY]MMDDhhmm[.SS]     
```

这里，CC为年数中的前两位，即”世纪数”；YY为年数的后两位，即某世纪中的年数。如果不给出CC的值，则touch 将把年数CCYY限定在1969--2068之内。MM为月数，DD为天将把年数CCYY限定在1969--2068之内。MM为月数，DD为天数，hh 为小时数(几点)，mm为分钟数，SS为秒数。此处秒的设定范围是0--61，这样可以处理闰秒。这些数字组成的时间是环境变量TZ指定的时区中的一个时 间。由于系统的限制，早于1970年1月1日的时间是错误的。

