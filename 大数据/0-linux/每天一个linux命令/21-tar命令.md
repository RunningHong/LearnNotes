[TOC]

tar命令可以为linux的文件和目录创建档案。利用tar，可以为某一特定文件创建档案（备份文件），也可以在档案中改变文件，或者向档案中加入新的文件。tar最初被用来在磁带上创建档案，现在，用户可以在任何设备上创建档案。利用tar命令，可以把一大堆的文件和目录全部打包成一个文件，这对于备份文件或将几个文件组合成为一个文件以便于网络传输是非常有用的。

首先要弄清两个概念：打包和压缩。
**打包**:是指将一大堆文件或目录变成一个总的文件.
**压缩**:则是将一个大的文件通过一些压缩算法变成一个小文件。

为什么要区分这两个概念呢？这源于Linux中很多压缩程序只能针对一个文件进行压缩，这样当你想要压缩一大堆文件时，你得先将这一大堆文件先打成一个包（tar命令），然后再用压缩程序进行压缩（gzip bzip2命令）。

linux下最常用的打包程序就是tar了，使用tar程序打出来的包我们常称为tar包，tar包文件的命令通常都是以.tar结尾的。生成tar包后，就可以用其它的程序来进行压缩。

# 一．命令格式

```
tar [必要参数] [选择参数] [文件] 
```

# 二. 命令功能

用来压缩和解压文件。tar本身不具有压缩功能。他是调用压缩功能实现的

# 三. 命令参数

## 必要参数

| 参数         | 描述                                                         |
| ------------ | ------------------------------------------------------------ |
| -A           | 或--catenate 新增压缩文件到已存在的压缩文件                  |
| -B           | 或--read-full-records，读取数据时重设区块大小。              |
| -c           | 或--create，建立新的压缩文件                                 |
| -d           | 或-diff，记录文件的差别                                      |
| -r           | 或--append 新增文件到已存在的压缩文件的结尾部分              |
| -u           | 或--update 仅置换较压缩文件内的文件更新的文件                |
| -x           | 或--extrac，从压缩的文件中提取文件                           |
| -t           | 或--list ，列出压缩文件的内容                                |
| -z           | 或--gzip或--ungzip,通过gzip指令解压文件                      |
| -j           | 通过bzip2指令解压文件                                        |
| -p           | 或--same-permissions 用原来的文件权限还原文件                |
| -Z           | 通过compress指令解压文件                                     |
| -N<日期格式> | 或--newer=<日期时间> ，只将较指定日期更新的文件保存到备份文件里。 |
| -v           | 显示操作过程                                                 |
| -l           | 文件系统边界设置                                             |
| -k           | 或--keep-old-files， 解压文件时，不覆盖已有的文件            |
| -m           | 或--modification-time ，解压文件时，不变更文件的更改时间     |
| -W           | 或--verify，压缩文件时，确认文件正确无误                     |

## 选择参数

| 参数      | 描述           |
| --------- | -------------- |
| -b        | 设置区块数目   |
| -C        | 切换到指定目录 |
| -f        | 指定压缩文件   |
| --help    | 显示帮助信息   |
| --version | 显示版本信息   |

# 四. 常见解压、压缩命令

## tar

打包：tar cvf FileName.tar DirName (将目录Dirname及其下面的目录、文件打包成名为FileName.tar的包)
解包：tar xvf FileName.tar

（注：tar是打包，不是压缩！）

## .gz

压缩： gzip FileName
解压1： gunzip FileName.gz
解压2： gzip -d FileName.gz

## .tar.gz 和 .tgz

压缩：tar zcvf FileName.tar.gz DirName
解压：tar zxvf FileName.tar.gz

## .bz2

压缩： bzip2 -z FileName
解压1：bzip2 -d FileName.bz2
解压2：bunzip2 FileName.bz2

## .tar.bz2

压缩：tar jcvf FileName.tar.bz2 DirName
解压：tar jxvf FileName.tar.bz2

## .bz

解压1：bzip2 -d FileName.bz
解压2：bunzip2 FileName.bz

## .tar.bz

解压：tar jxvf FileName.tar.bz

## .Z

压缩：compress FileName
解压：uncompress FileName.Z

## .tar.Z

压缩：tar Zcvf FileName.tar.Z DirName
解压：tar Zxvf FileName.tar.Z

## .zip

压缩：zip FileName.zip DirName
解压：unzip FileName.zip

## .rar

压缩：rar a FileName.rar DirName
解压：rar x FileName.rar

# 五. 使用实例

## 1：将文件全部打包成tar包

命令：

```
tar -cvf log.tar 1.log 
tar -zcvf log.tar.gz 1.log
tar -jcvf log.tar.bz2 1.log 
```

输出：

```
[root@localhost test]# ll 1.log 
-rw-r--r-- 1 root root 3743 Nov 30 09:51 1.log
[root@localhost test]# tar -cvf log.tar 1.log 
1.log
[root@localhost test]# tar -zcvf log.tar.gz 1.log 
1.log
[root@localhost test]# tar -jcvf log.tar.bz2 1.log 
1.log
[root@localhost test]# ll *.tar*
-rw-r--r-- 1 root root 10240 Nov 30 09:53 log.tar
-rw-r--r-- 1 root root  1798 Nov 30 09:55 log.tar.bz2
-rw-r--r-- 1 root root  1816 Nov 30 09:54 log.tar.gz
```

说明：

tar -cvf log.tar 1.log 仅打包，不压缩！
tar -zcvf log.tar.gz 1.log 打包后，以 gzip 压缩
tar -jcvf log.tar.bz2 1.log 打包后，以 bzip2 压缩

在参数 f 之后的文件档名是自己取的，我们习惯上都用 .tar 来作为辨识。 如果加 z 参数，则以 .tar.gz 或 .tgz 来代表 gzip 压缩过的 tar包； 如果加 j 参数，则以 .tar.bz2 来作为tar包名。

## 2：查阅上述 tar包内有哪些文件

命令：

```
tar -ztvf log.tar.gz
```

输出：

```
[root@localhost test]# tar -ztvf log.tar.gz
-rw-r--r-- root/root      3743 2018-11-30 09:51 1.log
```

说明：

由于我们使用 gzip 压缩的log.tar.gz，所以要查阅log.tar.gz包内的文件时，就得要加上 z 这个参数了。

## 3：将tar 包解压缩

命令：

```
tar -zxvf /home/hc/test/log.tar.gz 
```

输出：

```
[root@localhost test]# cd test2
[root@localhost test2]# ls
[root@localhost test2]# tar -zxvf /home/hc/test/log.tar.gz 
1.log
[root@localhost test2]# ls
1.log
```

说明：

在预设的情况下，我们可以将压缩档在任何地方解开的,比如此处就是在test2目录下解压了test目录下的log.tar.gz

## 4：只解压tar包里的部分文件

命令：

```
tar -zxvf /home/hc/test/log123.tar.gz 2.log
```

输出：

```
[root@localhost test2]# cd ../test
[root@localhost test]# ls
1.log  2.log  3.log  log.tar  log.tar.bz2  log.tar.gz
[root@localhost test]# tar -zcvf log123.tar.gz 1.log 2.log 3.log 
1.log
2.log
3.log
[root@localhost test]# ll
total 36
-rw-r--r-- 1 root root  3743 Nov 30 09:51 1.log
-rw-r--r-- 1 root root  3743 Nov 30 09:51 2.log
-rw-r--r-- 1 root root  3743 Nov 30 09:51 3.log
-rw-r--r-- 1 root root  1943 Nov 30 10:07 log123.tar.gz
-rw-r--r-- 1 root root 10240 Nov 30 10:01 log.tar
-rw-r--r-- 1 root root  1810 Nov 30 10:01 log.tar.bz2
-rw-r--r-- 1 root root  1817 Nov 30 10:01 log.tar.gz
[root@localhost test]# cd ../test2
[root@localhost test2]# ls
1.log
[root@localhost test2]# tar -ztvf /home/hc/test/log123.tar.gz 
-rw-r--r-- root/root      3743 2018-11-30 09:51 1.log
-rw-r--r-- root/root      3743 2018-11-30 09:51 2.log
-rw-r--r-- root/root      3743 2018-11-30 09:51 3.log
[root@localhost test2]# tar -zxvf /home/hc/test/log123.tar.gz 2.log
2.log
[root@localhost test2]# ls
1.log  2.log
```

说明：
此处是只解压出了log123.tar.gz包里的2.log文件，我们可以通过 tar -ztvf 来查阅 tar 包内的文件名称

## 5：在文件夹当中，比某个日期新的文件才备份

命令：

```
tar -N "2018/11/30" -zcvf log11.tar.gz .
```

输出：

```
[root@localhost test]# ll
total 0
-rw-r--r-- 1 root root 0 Nov 30 10:23 1.log
-rw-r--r-- 1 root root 0 Nov 30 10:23 2.log
-rw-r--r-- 1 root root 0 Nov 30 10:23 3.log
[root@localhost test]# tar -N "2018/11/30" -zcvf log11.tar.gz ./*
tar: Option --after-date: Treating date `2018/11/30' as 2018-11-30 00:00:00
./1.log
./2.log
./3.log
[root@localhost test]# tar -N "2018/12/30" -zcvf log12.tar.gz ./*
tar: Option --after-date: Treating date `2018/12/30' as 2018-12-30 00:00:00
tar: ./1.log: file is unchanged; not dumped
tar: ./2.log: file is unchanged; not dumped
tar: ./3.log: file is unchanged; not dumped
tar: ./log11.tar.gz: file is unchanged; not dumped
[root@localhost test]# ll
total 8
-rw-r--r-- 1 root root   0 Nov 30 10:23 1.log
-rw-r--r-- 1 root root   0 Nov 30 10:23 2.log
-rw-r--r-- 1 root root   0 Nov 30 10:23 3.log
-rw-r--r-- 1 root root 128 Nov 30 10:56 log11.tar.gz
-rw-r--r-- 1 root root  45 Nov 30 10:57 log12.tar.gz
[root@localhost test]# tar -tzvf log11.tar.gz 
-rw-r--r-- root/root         0 2018-11-30 10:23 ./1.log
-rw-r--r-- root/root         0 2018-11-30 10:23 ./2.log
-rw-r--r-- root/root         0 2018-11-30 10:23 ./3.log
[root@localhost test]# tar -tzvf log12.tar.gz 
[root@localhost test]# 
```

说明：
将当前目录下的更新时间比2018-11-30 00:00:00新的文件或目录进行压缩备份

## 6：备份文件夹内容时排除部分文件

命令：

```
tar --exclude ./log12.tar.gz  -zcvf test.tar.gz ./*
```

输出：

```
[root@localhost test]# ls
1.log  2.log  3.log  log11.tar.gz  log12.tar.gz
[root@localhost test]# tar --exclude ./log12.tar.gz  -zcvf test.tar.gz ./*
./1.log
./2.log
./3.log
./log11.tar.gz
[root@localhost test]# tar -tzvf test.tar.gz 
-rw-r--r-- root/root         0 2018-11-30 10:23 ./1.log
-rw-r--r-- root/root         0 2018-11-30 10:23 ./2.log
-rw-r--r-- root/root         0 2018-11-30 10:23 ./3.log
-rw-r--r-- root/root       128 2018-11-30 10:56 ./log11.tar.gz
```

说明：

备份压缩当前目录下除log12.tar.gz文件以外的所有文件或目录