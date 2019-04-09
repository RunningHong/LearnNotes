[TOC]

摘自

https://git-scm.com/book/zh/v2/Git-%E5%86%85%E9%83%A8%E5%8E%9F%E7%90%86-Git-%E5%AF%B9%E8%B1%A1

# Git内部原理

从根本上来讲 Git 是一个内容寻址（content-addressable）文件系统，并在此之上提供了一个版本控制系统的用户界面。

## 1 底层命令和高层命令

Git 最初是一套面向版本控制系统的工具集，而不是一个完整的、用户友好的版本控制系统，所以它还包含了一部分用于完成底层工作的命令。 这些命令被设计成能以 UNIX 命令行的风格连接在一起，抑或藉由脚本调用，来完成工作。 这部分命令一般被称作**“底层（plumbing）”命令**，而那些更友好的命令则被称作**“高层（porcelain）”命令**。

所以**底层命令**即Git的内部工作机制，**高层命令**（便于使用、面向用户）是对底层命令的封装。

## 2 git init

当在一个新目录或已有目录执行 `git init` 时，Git 会创建一个 `.git` 目录。 这个目录包含了几乎所有 Git 存储和操作的对象。

**创建目的**：通过这些文件以及目录记录文件的修改，即把与`.git`文件在同一个目录下的所有文件进行管理，也可以理解为`.git`就是一个记录着版本变化的数据库，从而达到版本控制的效果。

.git包含的主要文件夹：

```java
hooks/         // 包含客户端或服务端的钩子脚本（hook scripts）
info/          // 目录包含一个全局性排除（global exclude）文件
logs/
objects/
refs/
HEAD
description    // 仅供 GitWeb 程序使用
config         // 包含项目特有的配置选项
```

**重要部分**：

-  `objects` 目录存储所有数据内容；
- `refs` 目录存储指向数据（分支）的提交对象的指针；
- `HEAD` 文件指示目前被检出的分支；
- `index` 文件保存暂存区信息。

## 3 Git对象

### 3.1 数据对象

Git 是一个内容寻址文件系统。Git 的核心部分是一个简单的键值对数据库（key-value data store）。我们可以向该数据库插入任意类型的内容，它会返回一个键值，通过该键值可以在任意时刻再次检索（retrieve）该内容。 可以通过底层命令 `hash-object` 来演示上述效果——该命令可将任意数据保存于 `.git` 目录，并返回相应的键值。 

使用内部命令 `hash-object`可以向Git中存储数据：

```shell
$ echo 'test content' | git hash-object -w --stdin
d670460b4b4aece5915caf5c68d12f560a9fe3e4
```

该命令输出一个长度为 40 个字符的校验和。 这是一个 SHA-1 哈希值——一个将待存储的数据外加一个头部信息（header）一起做 SHA-1 校验运算而得的校验和。

通过内部命令`cat-file` 命令从 Git 那里取回数据：

```shell
$ git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4
test content
```

命令通过hash值，在通过 `-p` 选项可指示该命令自动判断内容的类型，并为我们显示格式友好的内容。

范例：

```shell
# 创建test.txt文件，写入信息，并把文件放到git仓库中
$ echo 'version 1' > test.txt
$ git hash-object -w test.txt
83baae61804e65cc73a7201a7252750c76066a30

# 再次修改test.txt文件，并放入git中
$ echo 'version 2' > test.txt
$ git hash-object -w test.txt
1f7a7a472abf3dd9643fd615f6da379c4acb3e3a

# 查看版本存入的版本信息（从上到下为从新到旧）
$ find .git/objects -type f
.git/objects/1f/7a7a472abf3dd9643fd615f6da379c4acb3e3a
.git/objects/83/baae61804e65cc73a7201a7252750c76066a30

# 恢复版本到指定版本
$ git cat-file -p 83baae61804e65cc73a7201a7252750c76066a30 > test.txt
$ cat test.txt
version 1
```

通过这些命令存储的对象我们叫它**数据对象**（blob object），通过**git cat-file -p** 可以查看存储的信息。但是这些对象并没有存储文件名信息，其实文件名保存是用**树对象**进行保存（见下节）。

### 3.2 树对象

**树对象**（tree object），它能解决文件名保存的问题，也允许我们将多个文件组织到一起。

Git 以一种类似于 UNIX 文件系统的方式存储内容，但作了些许简化。 所有内容均以树对象和数据对象的形式存储，**其中树对象对应了 UNIX 中的目录项**，数据对象则大致上对应了 inodes 或文件内容。 一个树对象包含了一条或多条树对象记录（tree entry），每条记录含有一个指向数据对象或者子树对象的 SHA-1 指针，以及相应的模式、类型、文件名信息。 例如，某项目当前对应的最新树对象可能是这样的：

```shell
$ git cat-file -p master^{tree}
100644 blob a906cb2a4a904a152e80877d4088654daad0c859      README
100644 blob 8f94139338f9404f26296befa88755fc2598c289      Rakefile
040000 tree 99f1a6d12cb4b6f19c8655fca46c3ecf317074e0      lib
```

`master^{tree}` 语法表示 `master` 分支上最新的提交所指向的树对象。注意，`lib` 子目录（所对应的那条树对象记录）并不是一个数据对象，而是一个指针，其指向的是另一个树对象：

```shell
$ git cat-file -p 99f1a6d12cb4b6f19c8655fca46c3ecf317074e0
100644 blob 47c6340d6459e05787f644c2447d2595f5d3a54b      simplegit.rb
```

从概念上讲，Git 内部存储的数据有点像这样：

![树对象](https://git-scm.com/book/en/v2/images/data-model-1.png)

**收获**：树对象其实可以看做是一个目录，一个tree记录着该目录下的所有文件（文件+目录）。

Git 根据某一时刻**暂存区（即 index 区域）所表示的状态创建并记录一个对应的树对象**。因此，为创建一个树对象，首先需要通过暂存一些文件来创建一个暂存区。

### 3.3 提交对象

前面的两个对象（数据对象、树对象）分别记录里内容信息以及目录信息，但是我们并不知道是谁（作者）保存了快照，以及保存的时间。通过**提交对象**（commit object）可以保存这些基本基本信息。

可以通过调用 `commit-tree` 命令创建一个提交对象，为此需要指定一个树对象的 SHA-1 值，以及该提交的父提交对象（如果有的话）。 我们从之前创建的第一个树对象开始：

```shell
$ echo 'first commit' | git commit-tree d8329f
fdf4fc3344e67ab068f836878b6c4951e3b15f3d
```

现在可以通过 `cat-file` 命令查看这个新提交对象：

```shell
$ git cat-file -p fdf4fc3
tree d8329fc1cc938780ffdd9f94e0d364e0ea74f579
author XXX <xxx@xx.com> 1243040974 -0700
committer XXX <xxx@xx.com> 1243040974 -0700

first commit
```

提交对象的格式很简单：它先指定一个**顶层树对象，代表当前项目快照**；然后是作者/提交者信息（依据你的 `user.name` 和 `user.email` 配置来设定，外加一个时间戳）；留空一行，最后是提交注释。

## 4 包文件

每次我都在想这样一个场景，如果每次都往Git提交一个大文件的修改，那么Git仓库会不会占用很大很大的磁盘空间（每提交一次就会有一个大文件，如果大文件是1G，那么即使每次修改的大小可以不计，但是如果提交10次也会占用至少10G的空间，那么就真的太恐怖了）。

事实上 Git 可以那样做。 Git 最初向磁盘中存储对象时所使用的格式被称为“松散（loose）”对象格式。 但是，Git 会时不时地将多个这些对象打包成一个称为“**包文件**（packfile）”的二进制文件，以节省空间和提高效率。 当版本库中有太多的松散对象，或者你手动执行 `git gc` 命令，或者你向远程服务器执行推送时，Git 都会这样做。**这种打包相当于压缩文件操作。**

Git做法：Git 打包对象时，会查找命名及大小相近的文件，并**只保存文件不同版本之间的差异内容**。

通过包文件，大大的提现了Git是一个**面向修改**的版本控制系统。

