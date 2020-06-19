[TOC]

cat命令的用途是连接文件或标准输入并打印。这个命令常用来显示文件内容，或者将几个文件连接起来显示，或者从标准输入读取内容并显示，它常与重定向符号配合使用。

# 一．命令格式：

```
cat [参数] [文件]...
```

# 二．命令功能：

cat主要有三大功能：

1.一次显示整个文件:cat filename

2.从键盘创建一个文件:cat > filename 只能创建新文件,不能编辑已有文件.

3.将几个文件合并为一个文件:cat file1 file2 > file

# 三. 命令参数

| 参数 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| -n   | --number ， 由1开始对所有输出的行数编号                      |
| -b   | --number-nonblank， 和 -n 相似，只不过对于空白行不编号。     |
| -s   | --squeeze-blank,当遇到有连续两行以上的空白行,就代换为一行的空白行。 |
| -v   | --show-nonprinting ， 使用 ^ 和 M- 引用，除了 LFD 和 TAB 之外 |
| -E   | --show-ends ， 在每行结束处显示 $                            |
| -T   | --show-tabs，将 TAB 字符显示为 ^I。                          |
| -A   | --show-all ， 等价于 -vET                                    |
| -e   | 等价于 -vE                                                   |
| -t   | 与 -vT 等价                                                  |

# 四. 使用实例



## 1. 将file1的文档内容覆盖到file2中

命令：

不带行号覆盖内容

```
cat file1 > file2
```

带行号覆盖内容

```
cat -n file1 > file2
```

输出：

```
hc@hc-virtual-machine:~/test$ cat file1
我是file1的第一行
我是file1的第二行
hc@hc-virtual-machine:~/test$ cat file2
hc@hc-virtual-machine:~/test$ cat file1 > file2
hc@hc-virtual-machine:~/test$ cat file2
我是file1的第一行
我是file1的第二行
hc@hc-virtual-machine:~/test$ cat -n file1 > file2
hc@hc-virtual-machine:~/test$ cat file2
     1	我是file1的第一行
     2	我是file1的第二行
```

## 2. 将file1的内容追加到file2的内容中

命令：

不带行号追加

```
cat file1 >> file2
```

带行号追加（空白行不加行号）

输出：

```
hc@hc-virtual-machine:~/test$ cat file1
我是file1的第一行
我是file1的第二行
hc@hc-virtual-machine:~/test$ cat file2
我是file2的第一行


我是file2的第6行
hc@hc-virtual-machine:~/test$ cat file1 >> file2
hc@hc-virtual-machine:~/test$ cat file1
我是file1的第一行
我是file1的第二行
hc@hc-virtual-machine:~/test$ cat file2
我是file2的第一行




我是file2的第6行
我是file1的第一行
我是file1的第二行
hc@hc-virtual-machine:~/test$ cat -b file2 >> file1
hc@hc-virtual-machine:~/test$ cat file1
我是file1的第一行
我是file1的第二行
     1	我是file2的第一行
     2	我是file2的第6行
     3	我是file1的第一行
     4	我是file1的第二行
hc@hc-virtual-machine:~/test$ 
```

说明：

```
>是重新编辑内容，>> 是追加内容
```

## 3. 清空file1文档内容

命令：

```
cat /dev/null > file1
```

输出：

```
hc@hc-virtual-machine:~/test$ cat file1
我是file1的第一行
我是file1的第二行
     1	我是file2的第一行

     2	我是file2的第6行
     3	我是file1的第一行
     4	我是file1的第二行
hc@hc-virtual-machine:~/test$ cat /dev/null > file1
hc@hc-virtual-machine:~/test$ cat file1
hc@hc-virtual-machine:~/test$ 
```



## 4. 倒序输出file2中的内容

命令：

```
tac file2
```

输出：

```
hc@hc-virtual-machine:~/test$ cat file2
我是file2的第一行
我是file2的第6行
我是file1的第一行
我是file1的第二行
hc@hc-virtual-machine:~/test$ tac file2
我是file1的第二行
我是file1的第一行
我是file2的第6行
我是file2的第一行
hc@hc-virtual-machine:~/test$ 
```

说明：

tac 是将 cat 反写过来，所以他的功能就跟 cat 相反， cat 是由第一行到最后一行连续显示在屏幕上，而 tac 则是由最后一行到第一行反向在屏幕上显示出来！

