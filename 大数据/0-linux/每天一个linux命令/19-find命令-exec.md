[TOC]

find是我们很常用的一个Linux命令，但是我们一般查找出来的并不仅仅是看看而已，还会有进一步的操作，这个时候exec的作用就显现出来了。

# 一. exec参数说明：

-exec 参数后面跟的是command命令，它的终止是**以;为结束标志的**，所以这句命令后面的**分号**是不可缺少的，**考虑到各个系统中分号会有不同的意义，所以前面加反斜杠**。

**{} 花括号代表前面find查找出来的文件名**。

使用find时，只要把想要的操作写在一个文件里，就可以用exec来配合find查找，很方便的。在有些操作系统中只允许-exec选项执行诸如ls或ls -l这样的命令。大多数用户使用这一选项是为了查找旧文件并删除它们。建议在真正执行rm命令删除文件之前，最好先用ls命令看一下，确认它们是所要删除的文件。 exec选项后面跟随着所要执行的命令或脚本，然后是一对{ }，一个空格和一个\，最后是一个分号。为了使用exec选项，必须要同时使用print选项。如果验证一下find命令，会发现该命令只输出从当前路径起的相对路径及文件名。

# 二. 使用示例

## 1. 查找当前目录下的文件，并对查找结果执行ls -l 命令

命令：

```
find . -type f -exec ls -l {} \;
```

输出：

```
[root@localhost home]# ls
1.log  2.log  3.c  4.log  test
[root@localhost home]# find  -type f
./1.log
./2.log
./3.c
[root@localhost home]# find -type f -exec ls -l {} \;
-rw-r--r--. 1 root root 0 Nov 14 17:55 ./1.log
-rw-r--r--. 1 root root 0 Nov 14 17:55 ./2.log
-rwxrwxrwx. 1 root root 0 Nov 14 18:00 ./3.c
```

## 2. 查找当前目录下，24小时内更改过的文件，并进行删除操作（慎用！！！，删除没有提示）

命令：

```
 find -type f -mtime -1 -exec rm {} \;
```

输出：

```
[root@localhost home]# ll
total 0
-rw-r--r--. 1 root root 0 Nov 14 17:55 1.log
-rw-r--r--. 1 root root 0 Nov 14 17:55 2.log
-rwxrwxrwx. 1 root root 0 Nov 14 18:00 3.c
drwxr-xr-x. 2 root root 6 Nov 14 18:16 4.log
-rw-r--r--. 1 root root 0 Nov 15 18:02 5.log
drwxr-xr-x. 2 root root 6 Nov 14 17:55 test
[root@localhost home]# find -type f -mtime -1
./5.log
[root@localhost home]# find -type f -mtime -1 -exec rm {} \;
[root@localhost home]# ls
1.log  2.log  3.c  4.log  test
```

说明：

在shell中用任何方式删除文件之前，应当先查看相应的文件，一定要小心！当使用诸如mv或rm命令时，可以使用-exec选项的安全模式。它将在对每个匹配到的文件进行操作之前提示你。

## 3. 查找当前目录下文件名以.log结尾且24小时内更改过的文件，并进行安全删除操作（即删除前会进行询问）

命令：

```
 find -name "*.log" -type f  -mtime -1 -ok rm {} \;
```

输出：

```
[root@localhost home]# touch 6.c
[root@localhost home]# touch 7.c
[root@localhost home]# ls
1.log  2.log  3.c  4.log  6.log  7.c  test
[root@localhost home]# ll
total 0
-rw-r--r--. 1 root root 0 Nov 14 17:55 1.log
-rw-r--r--. 1 root root 0 Nov 14 17:55 2.log
-rwxrwxrwx. 1 root root 0 Nov 14 18:00 3.c
drwxr-xr-x. 2 root root 6 Nov 14 18:16 4.log
-rw-r--r--. 1 root root 0 Nov 15 18:07 6.log
-rw-r--r--. 1 root root 0 Nov 15 18:07 7.c
drwxr-xr-x. 2 root root 6 Nov 14 17:55 test
[root@localhost home]# find -name "*.log" -mtime -1 -ok rm {} \;
< rm ... ./6.log > ? y
[root@localhost home]# ll
total 0
-rw-r--r--. 1 root root 0 Nov 14 17:55 1.log
-rw-r--r--. 1 root root 0 Nov 14 17:55 2.log
-rwxrwxrwx. 1 root root 0 Nov 14 18:00 3.c
drwxr-xr-x. 2 root root 6 Nov 14 18:16 4.log
-rw-r--r--. 1 root root 0 Nov 15 18:07 7.c
drwxr-xr-x. 2 root root 6 Nov 14 17:55 test
[root@localhost home]# ls
1.log  2.log  3.c  4.log  7.c  test
```

说明：

* -ok： 和-exec的作用相同，只不过以一种更为安全的模式来执行该参数所给出的shell命令，在执行每一个命令之前，都会给出提示，让用户来确定是否执行。 

## 4. 查找当前目录下的以.log结尾的文件或目录，并移动到test目录下

命令：

```
find -name "*.log" -exec mv {} test \;
```

输出：

```
[root@localhost home]# tree
.
├── 1.log
├── 2.log
├── 3.c
├── 4.log
├── 7.c
└── test

2 directories, 4 files
[root@localhost home]# find -name "*.log" -exec mv {} test \;
[root@localhost home]# ls
3.c  7.c  test
[root@localhost home]# tree
.
├── 3.c
├── 7.c
└── test
    ├── 1.log
    ├── 2.log
    └── 4.log

2 directories, 4 files
```