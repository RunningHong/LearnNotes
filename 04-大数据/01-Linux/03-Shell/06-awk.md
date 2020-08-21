# awk

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

awk基本操作

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

