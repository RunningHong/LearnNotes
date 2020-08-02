[TOC]

rmdir是常用的命令，该命令的功能是删除空目录，一个目录被删除之前必须是空的。（注意，rm - r dir命令可代替rmdir，但是有很大危险性。）删除某目录时也必须具有对父目录的写权限。

# 一.命令格式

```
rmdir [参数] 目录
```

# 二．命令功能：

该命令从一个目录中删除一个或多个子目录项，删除某目录时也必须具有对父目录的写权限。

# 三．命令参数：

| 参数 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| -p   | 递归删除目录dirname，当子目录删除后其父目录为空时，也一同被删除。如果整个路径被删除或者由于某种原因保留部分路径，则系统在标准输出上显示相应的信息。 |
| -v   | --verbose,显示指令执行过程                                   |

# 四. 命令示例



## 1.删除空目录dir31

命令：

```
rmdir dir31
```

输出：

```
hc@hc-virtual-machine:~$ tree test1/
test1/
├── dir1
│   ├── dir11
│   └── file1
└── dir2
│   └── dir21
└── dir3
    └── dir31

4 directories, 1 file
hc@hc-virtual-machine:~$ rmdir test1/dir1/file1
rmdir: 删除 'test1/dir1/file1' 失败: 不是目录
hc@hc-virtual-machine:~$ rmdir test1/dir3
rmdir: 删除 'test1/dir3' 失败: 目录非空
hc@hc-virtual-machine:~$ rmdir test1/dir3/dir31
hc@hc-virtual-machine:~$ tree test1/
test1/
├── dir1
│   ├── dir11
│   └── file1
└── dir2
│   └── dir21
└── dir3
```

说明：

rmdir 目录名 ，不能用来删除文件，也不能删除非空目录，只能用来删除单个空目录

## 2. “递归”删除空目录（此“递归”指“反向递归”，删除父级空目录）

命令：

```
    rmdir -p test1/dir2/dir21/
```

输出：

```
hc@hc-virtual-machine:~$ tree test1/
test1/
├── dir1
│   ├── dir11
│   └── file1
└── dir2
    └── dir21

4 directories, 1 file
hc@hc-virtual-machine:~$ rmdir -p test1/dir2/dir21/
rmdir: 删除目录 'test1' 失败: 目录非空
hc@hc-virtual-machine:~$ tree test1/
test1/
└── dir1
    ├── dir11
    └── file1

2 directories, 1 file
```

说明：
删除dir2目录下的dir21目录，如果删除后，dir21目录的父级目录为空目录，则删除其父级目录dir2，如果dir2的目录被删除后，test1目录为空目录，则接着删除，直到遇到父级目录不为空目录，则停止删除

rmdir -p 当该目录的子目录被删除后使其也成为空目录的话，则顺便一并删除该目录

## 3. 显示删除过程

命令：

```
rmdir -pv test1/dir1/dir11/
```

输出：

```
hc@hc-virtual-machine:~$ ls
PycharmProjects  snap  test1  公共的  模板  视频  图片  文档  下载  音乐  桌面
hc@hc-virtual-machine:~$ tree test1/
test1/
└── dir1
    └── dir11
hc@hc-virtual-machine:~$ rmdir -pv test1/dir1/dir11/
rmdir: 正在删除目录 'test1/dir1/dir11/'
rmdir: 正在删除目录 'test1/dir1'
rmdir: 正在删除目录 'test1'
hc@hc-virtual-machine:~$ ls
PycharmProjects  snap  公共的  模板  视频  图片  文档  下载  音乐  桌面
```