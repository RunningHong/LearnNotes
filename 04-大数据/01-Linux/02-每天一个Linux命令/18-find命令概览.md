[TOC]

Linux下find命令在目录结构中搜索文件，并执行指定的操作。Linux下find命令提供了相当多的查找条件，功能很强大。由于find具有强大的功能，所以它的选项也很多，其中大部分选项都值得我们花时间来了解一下。即使系统中含有网络文件系统( NFS)，find命令在该文件系统中同样有效，只你具有相应的权限。 在运行一个非常消耗资源的find命令时，很多人都倾向于把它放在后台执行，因为遍历一个大的文件系统可能会花费很长的时间(这里是指30G字节以上的文件系统)。

# 一. 命令格式

```
find   path   -option   [   -print ]   [ -exec   -ok   command ]   {} \;
```

# 二. 命令功能

Linux find命令用来在指定目录下查找文件。任何位于参数之前的字符串都将被视为欲查找的目录名。如果使用该命令时，不设置任何参数，则find命令将在当前目录下查找子目录与文件。并且将查找到的子目录和文件全部进行显示。

# 三. 参数说明

find 根据下列规则判断 path 和 expression（运算式），在命令列上第一个 - ( ) , ! 之前的部份为 path，之后的是 expression。如果 path 是空字串则使用目前路径，如果 expression 是空字串则使用 -print 为预设 expression。
你可以使用 ( ) 将运算式分隔，并使用下列运算。

exp1 -and exp2

! expr

-not expr

exp1 -or exp2

exp1, exp2

| 参数   | 描述                                                         |
| ------ | ------------------------------------------------------------ |
| path   | find命令所查找的目录路径。例如用.来表示当前目录，用/来表示系统根目录。 |
| -print | find命令将匹配的文件输出到标准输出。                         |
| -exec  | find命令对匹配的文件执行该参数所给出的shell命令。-exec command {} ; 将查到的文件执行command操作，注意{} 和 ;之间有空格 |
| -ok    | 和-exec的作用相同，只不过以一种更为安全的模式来执行该参数所给出的shell命令，在执行每一个命令之前，都会给出提示，让用户来确定是否执行。 |

# 四. 参数选项

| 命令                 | 说明                                                         |
| -------------------- | ------------------------------------------------------------ |
| -name name           | **按照文件名查找名为name的文件。-iname会忽略大小写**         |
| -path p              | **: 路径名称符合 p 的文件，-ipath 会忽略大小写**             |
| -perm                | 按照文件权限来查找文件。                                     |
| -prune               | 使用这一选项可以使find命令不在当前指定的目录中查找，如果同时使用-depth选项，那么-prune将被find命令忽略。 |
| -user                | 按照文件属主来查找文件。                                     |
| -group name          | 按照文件所属的组group，查找group为name的文件。               |
| -gid n               | gid为n的文件                                                 |
| -mtime -n +n         | 按照文件的更改时间来查找文件， -n表示文件更改时间距现在n天以内，+n表示文件更改时间距现在n天以前。 |
| -nogroup             | 查找无有效所属组的文件，即该文件所属的组在/etc/groups中不存在。 |
| -nouser              | 查找无有效属主的文件，即该文件的属主在/etc/passwd中不存在。  |
| -newer file1 ! file2 | 查找更改时间比文件file1新但比文件file2旧的文件。             |
| -type                | 查找某一类型的文件，诸如：b - 块设备文件。d - 目录。c - 字符设备文件。p - 管道文件。l - 符号链接文件。f - 普通文件。 |
| -size n [c]          | 查找文件长度为n块的文件，带有c时表示文件长度以字节计。       |
| -pid n               | process id 是 n 的文件                                       |
| -depth               | 在查找文件时，首先查找当前目录中的文件，然后再在其子目录中查找。 |
| -fstype              | 查找位于某一类型文件系统中的文件，这些文件系统类型通常可以在配置文件/etc/fstab中找到，该配置文件中包含了本系统中有关文件系统的信息。 |
| -empty               | 空的文件                                                     |
| -mount, -xdev        | 只检查和指定目录在同一个文件系统下的文件，避免列出其它文件系统中的文件 |
| -follow              | 如果find命令遇到符号链接文件，就跟踪至链接所指向的文件。     |
| -cpio                | 对匹配的文件使用cpio命令，将这些文件备份到磁带设备中。       |
| -amin n              | 查找系统中最近 n 分钟内被读取过的文件                        |
| -atime n             | 查找系统中最近n天内被读取过的文件                            |
| -cmin n              | 查找系统中最近 n 分钟内被改变文件状态的文件                  |
| -ctime n             | 查找系统中最近n天内被改变文件状态的文件                      |
| -mmin n              | 查找系统中最近n分钟内被改变文件数据的文件                    |
| -mtime n             | 查找系统中最近n天内被改变文件数据的文件                      |

跟时间有关的参数

- -n 表示距现在n个单位时间以内，+n表示距现在n个单位时间以前

# 五. 使用实例

## 1. 查找2天内被读取过的文件

命令：

```
find -atime  -2
```

输出：

```
[root@localhost home]# find -atime -2
.
./test
./1.log
./2.log
```

## 2. 在当前目录下查找.log结尾的文件

命令：

```
 find . -name  "*.log"
```

或

```
find  -name  "*.log"
```

输出：

```
[root@localhost home]# ls
1.log  2.log  3.c  test
[root@localhost home]# find . -name  "*.log"
./1.log
./2.log
[root@localhost home]# find  -name  "*.log"
./1.log
./2.log
```

说明：

"." 代表当前目录
find 命令 不指定path时，默认是当前目录

## 3. 查找home目录下 ,权限为777的文件

命令：

```
 find /home/ -perm 777
```

输出：

```
[root@localhost home]# ll
total 0
-rw-r--r--. 1 root root 0 Nov 14 17:55 1.log
-rw-r--r--. 1 root root 0 Nov 14 17:55 2.log
-rw-r--r--. 1 root root 0 Nov 14 18:00 3.c
drwxr-xr-x. 2 root root 6 Nov 14 17:55 test
[root@localhost home]#  find /home/ -perm 777
[root@localhost home]#
[root@localhost home]# chmod 777 3.c 
[root@localhost home]# find /home/ -perm 777
/home/3.c
[root@localhost home]# ll
total 0
-rw-r--r--. 1 root root 0 Nov 14 17:55 1.log
-rw-r--r--. 1 root root 0 Nov 14 17:55 2.log
-rwxrwxrwx. 1 root root 0 Nov 14 18:00 3.c
drwxr-xr-x. 2 root root 6 Nov 14 17:55 test
```

说明：
chmod 777 3.c 命令是指给3.c文件赋予777权限

## 4. 查找home目录下以.log结尾的文件或目录

命令：

查找以.log结尾的文件

```
find /home/ -type f -name '*.log'
```

查找以.log结尾的目录

```
 find /home/ -type d  -name '*.log'
```

输出：

```
[root@localhost home]# ls
1.log  2.log  3.c  test
[root@localhost home]# mkdir 4.log
[root@localhost home]# ls
1.log  2.log  3.c  4.log  test
[root@localhost home]# find /home/ -type f -name '*.log'
/home/1.log
/home/2.log
[root@localhost home]# find /home/ -type d  -name '*.log'
/home/4.log
```

## 5. 查找当前目录下文件大小大于5个字节的文件

命令：
大于5个字节

```
find -size +5c
```

等于6个字节

```
find -size 6c
[root@localhost home]# ll
total 0
-rw-r--r--. 1 root root 0 Nov 14 17:55 1.log
-rw-r--r--. 1 root root 0 Nov 14 17:55 2.log
-rwxrwxrwx. 1 root root 0 Nov 14 18:00 3.c
drwxr-xr-x. 2 root root 6 Nov 14 18:16 4.log
drwxr-xr-x. 2 root root 6 Nov 14 17:55 test
[root@localhost home]# find -size +5c
.
./test
./4.log
[root@localhost home]# find -size 6c
./test
./4.log
```