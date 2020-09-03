[TOC]

# Awk命令

## 1 介绍

awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在其对数据分析并生成报告时，显得尤为强大。简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。

demo数据如下：

```
[root@www ~]# cat test.txt
root     pts/1   192.168.1.100  Tue Feb 10 11:21   still logged in
root     pts/1   192.168.1.100  Tue Feb 10 00:46 - 02:28  (01:41)
root     pts/1   192.168.1.100  Mon Feb  9 11:41 - 18:30  (06:48)
dmtsai   pts/1   192.168.1.100  Mon Feb  9 11:41 - 11:41  (00:00)
root     tty1                   Fri Sep  5 14:09 - 14:10  (00:01)
```

awk工作流程是这样的：读入有'\n'换行符分割的一条记录，然后将记录按指定的域分隔符划分域，填充域，$0则表示所有域,$1表示第一个域,$n表示第n个域。默认域分隔符是"空白键" 或 "[tab]键",所以$1表示登录用户，$3表示登录用户ip,以此类推。

## 2 awk基本操作

```shell
# 打印第一列
#cat test.txt | awk '{print $1}'
root
root
root
dmtsai
root

# 打印第1列和第2列，使用\t分隔
# cat test.txt | awk '{print $1"\t"$2}'
root     pts/1
root     pts/1
root     pts/1
dmtsai   pts/1
root     tty1 

# 使用指定分隔符分隔(如果当行信息没有指定的分隔符那么整行都在$1里面)
# cat test.txt | awk -F '/' '{print $1}'
root     pts
root     pts
root     pts
dmtsai   pts
root     tty1                   Fri Sep  5 14:09 - 14:10  (00:01)
```

## 3 Awk 的两个特殊模式-BEGIN-END

- BEGIN 和 END，BEGIN 被放置在没有读取任何数据之前，而 END 被放置在所有的数据读取完成以后执行
- 体现如下：
  BEGIN{}: 读入第一行文本之前执行的语句，一般用来初始化操作
  {}: 逐行处理
  END{}: 处理完最后以行文本后执行，一般用来处理输出结果

### 3.1 awk中BEGIN&END基本用法

准备文件：text.txt，任意写入一些信息如：

```shell
echo "aa bb cc
dd ee ff
gg hh jj" > text.txt
```

#### 3.1.1 输出文件内容&在文件头加first在文件尾加end

说明：直接`print`则是打印当前行也可写成`print $0`

```shell
cat text.txt | awk '
    BEGIN { print "first" }
    { print }
    END { print "end" }
'

输出：
first
aa bb cc
dd ee ff
gg hh jj
end
```

#### 3.1.2 以空格为分隔符打印第一列的内容

说明：-F参数可指定分隔符，$1代表第一列

```shell
cat text.txt | awk -F " " '
    BEGIN { print "first" }
    { print $1 }
    END { print "end" }
'


输出：
first
aa
dd
gg
end
```

#### 3.1.3 打印行号&内容

备注：`NR`代表行号，使用`,`隔离字段

```shell
cat text.txt | awk  '
    BEGIN { print "first" }
    { print "行号：",NR," 内容：",$0 }
    END { print "end" }
'

输出：
first
行号： 1  内容： aa bb cc
行号： 2  内容： dd ee ff
行号： 3  内容： gg hh jj
end
```

### 3.2 awk高级应用

#### 3.2.1 统计文本总字数

备注：`NF`代表浏览记录的域的个数

```shell
cat text.txt | awk  '
    BEGIN { i=0 }
    { i+=NF }
    END { print i }
'

输出：
9
```

#### 3.2.2 if分支语句

```powershell
# 统计登录shell为bash的用户
[root@server19 mnt]# awk -F: 'BEGIN{i=0}{if($7~/bash$/){i++}}END{print i}' /etc/passwd
2 


# 统计/etc/passwd下uid小于500的用户个数
[root@server19 mnt]# awk -F: 'BEGIN{i=0}{if($3<500){i++}}END{print i}' /etc/passwd
31 


# 统计uid小于等于500和大于500的用户个数
[root@server19 mnt]# awk -F: 'BEGIN{i=0;j=0}{if($3<=500){i++}else{j++}}END{print i,j}' /etc/passwd
31 9 
```

#### 3.2.3 for循环

```shell
[root@server19 mnt]# awk -F: 'BEGIN{i=0;j=0}{if($3<=500){i++}else{j++}}END{print i,j}' /etc/passwd
31 9 
```

#### 3.2.4 while循环

```shell
语法一：
[root@test ~]# awk 'i=1 {} BEGIN {while (i<3) {++i;print i}}' test.txt 
1
2
3
[root@test ~]#

语法二：
[root@test ~]# awk 'BEGIN {do {++i;print i} while (i<3)}' test.txt 
1
2
3
```

## 4 关于awk中NR、FNR、NF、$NF、FS、OFS的说明

### 4.1 NR和FNR

- NR: 表示当前读取的行数
- FNR:当前修改了多少行

举例：
比如现在AWK处理到第五行。第一行没有进行操作，2,3,4,5行进行了操作，那么NR=5,FNR=4
NR==FNR 表示从起始行到当前行，awk都进行了操作，比如修改，添加等等 

### 4.2 NF和$NF

- NF:浏览记录的域的个数
- $NF: 最后一个列，输出最后一个列的内容

```
# pwd
/root/aaa/scripts/shell
# echo $PWD|awk -F/ '{print $NF}'
shell
# echo $PWD|awk -F/ '{print NF}'
5
```

### 4.3 FS和OFS

- FS:指定列分隔符，当FS为空的时候，awk会把一行中的每个字符，当成一列来处理。
- OFS：列输出分隔符，默认为空白字符；

（1）FS指定列分隔符

```shell
[zhangy@localhost test]$ echo "111|222|333"|awk '{print $1}'  
 111|222|333  
[zhangy@localhost test]$ echo "111|222|333"|awk 'BEGIN{FS="|"}{print $1}'  
 111  
```

（2）FS也可以使用正则

```shell
[zhangy@localhost test]$ echo "111||222|333"|awk 'BEGIN{FS="[|]+"}{print $1}'  
111  
```

（3）FS为空时

```shell
[zhangy@localhost test]$ echo "111|222|333"|awk 'BEGIN{FS=""}{NF++;print $0}'  
1 1 1 | 2 2 2 | 3 3 3  
```

（4）RS被设定成非\n时，\n会成FS分割符中的一个

```shell
[zhangy@localhost test]$ cat test1  
 111 222  
 333 444  
 555 666  
[zhangy@localhost test]$ awk 'BEGIN{RS="444";}{print 2,3}' test1  
 222 333  
 666  
```

（5）OFS列输出分隔符

```shell
[zhangy@localhost test]$ awk 'BEGIN{OFS="|";}{print 1,2}' test1  
 111|222  
 333|444  
 555|666  
[zhangy@localhost test]$ awk 'BEGIN{OFS="|";}{print 1OFS2}' test1  
 111|222  
 333|444  
 555|666  
```