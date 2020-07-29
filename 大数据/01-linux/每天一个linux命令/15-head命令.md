[TOC]

head 与 tail 就像它的名字一样的浅显易懂，它是用来显示开头或结尾某个数量的文字区块，head 用来显示档案的开头至标准输出中，而 tail 想当然尔就是看档案的结尾。

# 一．命令格式：

```
head [参数]... [文件]...  
```

# 二．命令功能：

head 用来显示档案的开头至标准输出中，默认head命令打印其相应文件的开头10行。

# 三．命令参数：

| 参数     | 描述       |
| -------- | ---------- |
| -q       | 隐藏文件名 |
| -v       | 显示文件名 |
| -c<字节> | 显示字节数 |
| -n<行数> | 显示的行数 |

# 四．使用实例：

## 1.输出log1文件的前4行内容

命令：

```
head -n 4 log1
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
hc@hc-virtual-machine:~/snap$ head -n 4 log1
我是log1的第一行

我是log1的第三行
我是log1的第四行
```

## 2.输出log1文件除最后4行以外的全部内容

命令：

```
head -n -4 log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ head -n -4 log1
我是log1的第一行

我是log1的第三行
hc@hc-virtual-machine:~/snap$ 
```

## 3.输出log1文件的前24个字节

命令：

```
head -c 24 log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ head -c 24 log1
我是log1的第一行

hc@hc-virtual-machine:~/snap$ 
```

## 4.输出log1文件的除最后24个字节以外的内容

命令：

```
head -c -24 log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ head -c -24 log1
我是log1的第一行

我是log1的第三行
我是log1的第四行
我是log1的第五行
hc@hc-virtual-machine:~/snap$ 
```