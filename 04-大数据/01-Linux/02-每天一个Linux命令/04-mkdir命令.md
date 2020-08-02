[TOC]

linux mkdir 命令用来创建指定的名称的目录，要求创建目录的用户在当前目录中具有写权限，并且指定的目录名不能是当前目录中已有的目录。

# 1．命令格式：

```
mkdir [选项] 目录名或路径名
```

# 2．命令功能：

通过 mkdir 命令可以实现在指定位置创建以 DirName(指定的文件名)命名的文件夹或目录。要创建文件夹或目录的用户必须对所创建的文件夹的父文件夹具有写权限。并且，所创建的文件夹(目录)不能与其父目录(即父文件夹)中的文件名重名，即同一个目录下不能有同名的(区分大小写)。

# 3．命令参数：

| 参数      | 描述                                                         |
| --------- | ------------------------------------------------------------ |
| -m        | --mode=模式，设定权限<模式> (类似 chmod)                     |
| -p        | --parents 可以是一个路径名称。此时若路径中的某些目录尚不存在,加上此选项后,系统将自动建立好那些尚不存在的目录,即一次可以建立多个目录; |
| -v        | --verbose , 每次创建新目录都显示信息                         |
| --help    | 显示此帮助信息并退出                                         |
| --version | 输出版本信息并退出                                           |

# 4．命令实例：

## 1：创建一个空目录

命令：

```
mkdir test1
```

输出：

```
hc@hc-virtual-machine:~$ ls
PycharmProjects  snap  公共的  模板  视频  图片  文档  下载  音乐  桌面
hc@hc-virtual-machine:~$ mkdir test1
hc@hc-virtual-machine:~$ ls
PycharmProjects  snap  test1  公共的  模板  视频  图片  文档  下载  音乐  桌面
```



## 2：递归创建多个目录

命令：

```
mkdir -p test2/test22
```

输出：

```
hc@hc-virtual-machine:~$ mkdir -p test2/test22
hc@hc-virtual-machine:~$ ls
PycharmProjects  test1  公共的  视频  文档  音乐
snap             test2  模板    图片  下载  桌面
hc@hc-virtual-machine:~$ cd test2/
hc@hc-virtual-machine:~/test2$ ls
test22
```



## 3：创建权限为777的目录

命令：

```
mkdir -m 777 test3
```

输出：

```
hc@hc-virtual-machine:~/test2$ mkdir -m 777 test3
hc@hc-virtual-machine:~/test2$ ll
总用量 16
drwxrwxr-x  4 hc hc 4096 10月 25 09:13 ./
drwxr-xr-x 25 hc hc 4096 10月 25 09:11 ../
drwxrwxr-x  2 hc hc 4096 10月 25 09:11 test22/
drwxrwxrwx  2 hc hc 4096 10月 25 09:13 test3/
```

说明：

ll 与 ls -l 命令效果相同

test3 的权限为rwxrwxrwx

## 4：创建新目录并显示创建信息

命令：

```
mkdir -v test4
```

输出：

```
hc@hc-virtual-machine:~/test2$ mkdir -v test4
mkdir: 已创建目录 'test4'
hc@hc-virtual-machine:~/test2$ ls
test22  test3  test4
```



## 5：创建目录及其子目录并显示创建信息

命令：

```
mkdir -vp test5/test5-1
```

输出：

```
hc@hc-virtual-machine:~/test2$ mkdir -vp test5/test5-1
mkdir: 已创建目录 'test5'
mkdir: 已创建目录 'test5/test5-1'
hc@hc-virtual-machine:~/test2$ ls
test22  test3  test4  test5
hc@hc-virtual-machine:~/test2$ cd test5/
hc@hc-virtual-machine:~/test2/test5$ ls
test5-1
```



## 6. 通过一个命令创建出项目的目录结构

命令：

```
mkdir -vp scf/{lib/,bin/,doc/{info,product},logs/{info,product},service/deploy/{info,product}}
```

输出：

```
hc@hc-virtual-machine:~/test2/test5$ ls
test5-1
hc@hc-virtual-machine:~/test2/test5$ pwd
/home/hc/test2/test5
hc@hc-virtual-machine:~/test2/test5$ mkdir -vp scf/{lib/,bin/,doc/{info,product},logs/{info,product},service/deploy/{info,product}}
mkdir: 已创建目录 'scf'
mkdir: 已创建目录 'scf/lib/'
mkdir: 已创建目录 'scf/bin/'
mkdir: 已创建目录 'scf/doc'
mkdir: 已创建目录 'scf/doc/info'
mkdir: 已创建目录 'scf/doc/product'
mkdir: 已创建目录 'scf/logs'
mkdir: 已创建目录 'scf/logs/info'
mkdir: 已创建目录 'scf/logs/product'
mkdir: 已创建目录 'scf/service'
mkdir: 已创建目录 'scf/service/deploy'
mkdir: 已创建目录 'scf/service/deploy/info'
mkdir: 已创建目录 'scf/service/deploy/product'
hc@hc-virtual-machine:~/test2/test5$ ls
scf  test5-1
hc@hc-virtual-machine:~/test2/test5$ tree scf/
scf/
├── bin
├── doc
│   ├── info
│   └── product
├── lib
├── logs
│   ├── info
│   └── product
└── service
    └── deploy
        ├── info
        └── product

12 directories, 0 files
hc@hc-virtual-machine:~/test2/test5$ 
```

说明：

tree命令可以用来查看目录树，需要自行安装后才能使用，Ubuntu安装命令： apt install tree