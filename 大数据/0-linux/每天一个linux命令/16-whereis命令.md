[TOC]

whereis命令用于查找文件。

该指令会在特定目录中查找符合条件的文件。这些文件应属于原始代码、二进制文件，或是帮助文件。

该指令只能用于查找二进制文件、源代码文件和man手册页，一般文件的定位需使用locate命令。

# 一．命令格式：

```
whereis [-bfmsu][-B <目录>...][-M <目录>...][-S <目录>...][文件...]
```

# 二．命令功能：

whereis命令是定位可执行文件、源代码文件、帮助文件在文件系统中的位置。这些文件的属性应属于原始代码，二进制文件，或是帮助文件。whereis 程序还具有搜索源代码、指定备用搜索路径和搜索不寻常项的能力。
如果省略参数，则返回所有信息。

# 三．命令参数：

| 参数 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| -b   | 定位可执行文件。                                             |
| -m   | 定位帮助文件。                                               |
| -s   | 定位源代码文件。                                             |
| -u   | 搜索默认路径下除可执行文件、源代码文件、帮助文件以外的其它文件。 |
| -B   | 指定搜索可执行文件的路径。                                   |
| -M   | 指定搜索帮助文件的路径。                                     |
| -S   | 指定搜索源代码文件的路径。                                   |

# 四．使用实例：

## 1：查看指令"bash"的位置

命令：

```
whereis bash 
```

输出：

```
hc@hc-virtual-machine:~$ whereis bash
bash: /bin/bash /etc/bash.bashrc /usr/share/man/man1/bash.1.gz
```

说明：
以上输出信息从左至右分别为查询的程序名、bash路径、bash的man 手册页路径。

## 2：显示bash 命令的二进制程序的地址

命令：

```
whereis -b bash
```

输出：

```
hc@hc-virtual-machine:~$ whereis -b bash
bash: /bin/bash /etc/bash.bashrc
```

## 3.显示bash命令的帮助文件地址

命令：

```
whereis -m bash
```

输出：

```
hc@hc-virtual-machine:~$ whereis -m bash
bash: /usr/share/man/man1/bash.1.gz
```