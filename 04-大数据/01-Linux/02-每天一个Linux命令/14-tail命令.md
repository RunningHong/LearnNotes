[TOC]

tail 命令从指定点开始将文件写到标准输出.使用tail命令的-f选项可以方便的查阅正在改变的日志文件,**tail -f filename会把filename里最尾部的内容显示在屏幕上,并且不断刷新,使你看到最新的文件内容.**

# 一．命令格式;

```
tail [必要参数] [选择参数] [文件]   
```

# 二．命令功能：

用于显示指定文件末尾内容，不指定文件时，作为输入信息进行处理。常用查看日志文件。

# 三．命令参数：

| 参数      | 描述                                                    |
| --------- | ------------------------------------------------------- |
| -f        | 循环读取                                                |
| -q        | 不显示处理信息                                          |
| -v        | 显示详细的处理信息                                      |
| -c<数目>  | 显示的字节数                                            |
| -n<行数>  | 显示行数                                                |
| --pid=PID | 与-f合用,表示在进程ID,PID死掉之后结束.                  |
| -q        | --quiet, --silent 从不输出给出文件名的首部              |
| -s        | --sleep-interval=S 与-f合用,表示在每次反复的间隔休眠S秒 |

# 四．使用实例：

## 1.显示log1文件最后3行内容

命令：

```
tail -n 3 log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ nl -b a log1
     1	我是log1的第一行
     2	
     3	我是log1的第三行
     4	我是log1的第四行
     5	我是log1的第五行
     6	
     7	我是log1的第七行
hc@hc-virtual-machine:~/snap$ tail -n 3 log1
我是log1的第五行

我是log1的第七行
```

## 2. 从第3行开始显示log1文件内容

命令：

```
tail -n +3 log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ nl -b a log1
    1	我是log1的第一行
    2	
    3	我是log1的第三行
    4	我是log1的第四行
    5	我是log1的第五行
    6	
    7	我是log1的第七行
hc@hc-virtual-machine:~/snap$ tail -n +3 log1
我是log1的第三行
我是log1的第四行
我是log1的第五行

我是log1的第七行
```

## 3.循环刷新查看文件内容

命令：

```
tail -f test.log
```

输出:

```angular2html
hc@hc-virtual-machine:~/snap$ ping 127.0.0.1 > test.log & 
[1] 24615
hc@hc-virtual-machine:~/snap$ tail -f test.log
64 bytes from 127.0.0.1: icmp_seq=5 ttl=64 time=0.065 ms
64 bytes from 127.0.0.1: icmp_seq=6 ttl=64 time=0.068 ms
64 bytes from 127.0.0.1: icmp_seq=7 ttl=64 time=0.157 ms
64 bytes from 127.0.0.1: icmp_seq=8 ttl=64 time=0.067 ms
64 bytes from 127.0.0.1: icmp_seq=9 ttl=64 time=0.034 ms
64 bytes from 127.0.0.1: icmp_seq=10 ttl=64 time=0.043 ms
64 bytes from 127.0.0.1: icmp_seq=11 ttl=64 time=0.031 ms
64 bytes from 127.0.0.1: icmp_seq=12 ttl=64 time=0.076 ms
64 bytes from 127.0.0.1: icmp_seq=13 ttl=64 time=0.045 ms
64 bytes from 127.0.0.1: icmp_seq=14 ttl=64 time=0.069 ms
64 bytes from 127.0.0.1: icmp_seq=15 ttl=64 time=0.067 ms
64 bytes from 127.0.0.1: icmp_seq=16 ttl=64 time=0.063 ms
^C
hc@hc-virtual-machine:~/snap$ ps -ef | less
[1]+  已杀死               ping 127.0.0.1 > test.log
```

说明：

ping 127.0.0.1 > test.log & //在后台ping远程主机。并输出文件到test.log；这种做法也使用于一个以上的档案监视。用Ctrl＋c来终止。

由于加了&,所以输出命令一直在后台运行，想要杀死它就得找到它的pid，然后kill -9 pid，终止输出