[TOC]

less 工具也是对文件或其它输出进行分页显示的工具，应该说是linux正统查看文件内容的工具，功能极其强大。less 的用法比起 more 更加的有弹性。在 more 的时候，我们并没有办法向前面翻， 只能往后面看，但若使用了 less 时，就可以使用 [pageup] [pagedown] 等按键的功能来往前往后翻看文件，更容易用来查看一个文件的内容！除此之外，在 less 里头可以拥有更多的搜索功能，不止可以向下搜，也可以向上搜。

# 一．命令格式：

```
less [参数]  文件 
```

# 二．命令功能：

less 与 more 类似，但使用 less 可以随意浏览文件，而 more 仅能向前移动，却不能向后移动，而且 less 在查看之前不会加载整个文件。

# 三．命令参数：

| 参数        | 描述                                                 |
| ----------- | ---------------------------------------------------- |
| -b          | <缓冲区大小> 设置缓冲区的大小                        |
| -e          | 当文件显示结束后，自动离开                           |
| -f          | 强迫打开特殊文件，例如外围设备代号、目录和二进制文件 |
| -g          | 只标志最后搜索的关键词                               |
| -i          | 忽略搜索时的大小写                                   |
| -m          | 显示类似more命令的百分比                             |
| -N          | 显示每行的行号                                       |
| -o <文件名> | 将less 输出的内容在指定文件中保存起来                |
| -Q          | 不使用警告音                                         |
| -s          | 显示连续空行为一行                                   |
| -S          | 行过长时间将超出部分舍弃                             |
| -x <数字>   | 将“tab”键显示为规定的数字空格                        |
| /字符串：   | **向下搜索“字符串”的功能**                           |
| ?字符串：   | **向上搜索“字符串”的功能**                           |
| n：         | **重复前一个搜索（与 / 或 ? 有关）**                 |
| N：         | **反向重复前一个搜索（与 / 或 ? 有关）**             |
| b           | CentOs向后翻一页（Ubuntu向前翻一页）                 |
| d           | 向后翻半页                                           |
| h           | 显示帮助界面                                         |
| Q           | 退出less 命令                                        |
| u           | 向前滚动半页                                         |
| y           | 向前滚动一行                                         |
| 空格键      | 滚动一页                                             |
| 回车键      | 滚动一行                                             |
| [pagedown]  | 向下翻动一页                                         |
| [pageup]    | 向上翻动一页                                         |

# 四．使用实例：

## 1.查看文件

命令：

```
less log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ less log1 
我是log1的第一行

我是log1的第三行
我是log1的第四行
我是log1的第五行

我是log1的第七行
log1 (END)
```

## 2. ps查看进程信息并通过less分页显示

命令：

```
ps -ef |less
```

输出：

```angular2html
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 10:10 ?        00:00:03 /sbin/init splash
root          2      0  0 10:10 ?        00:00:00 [kthreadd]
root          4      2  0 10:10 ?        00:00:00 [kworker/0:0H]
root          6      2  0 10:10 ?        00:00:00 [mm_percpu_wq]
root          7      2  0 10:10 ?        00:00:00 [ksoftirqd/0]
root          8      2  0 10:10 ?        00:00:03 [rcu_sched]
root          9      2  0 10:10 ?        00:00:00 [rcu_bh]
root         10      2  0 10:10 ?        00:00:00 [migration/0]
root         11      2  0 10:10 ?        00:00:00 [watchdog/0]
root         12      2  0 10:10 ?        00:00:00 [cpuhp/0]
root         13      2  0 10:10 ?        00:00:00 [cpuhp/1]
root         14      2  0 10:10 ?        00:00:00 [watchdog/1]
root         15      2  0 10:10 ?        00:00:00 [migration/1]
root         16      2  0 10:10 ?        00:00:00 [ksoftirqd/1]
root         18      2  0 10:10 ?        00:00:00 [kworker/1:0H]
root         19      2  0 10:10 ?        00:00:00 [cpuhp/2]
root         20      2  0 10:10 ?        00:00:00 [watchdog/2]
root         21      2  0 10:10 ?        00:00:00 [migration/2]
root         22      2  0 10:10 ?        00:00:00 [ksoftirqd/2]
root         24      2  0 10:10 ?        00:00:00 [kworker/2:0H]
root         25      2  0 10:10 ?        00:00:00 [cpuhp/3]
root         26      2  0 10:10 ?        00:00:00 [watchdog/3]
:
```

说明：

按空格键或者pagedown键，向后翻一页
按b（CentOs向后翻一页,Ubuntu向前翻一页）
按y向前翻一行，按回车键向后翻一行
d 向后翻半页，u前翻半页

## 3. 查看命令历史使用记录并通过less分页显示

命令：

```
history | less
```

输出：

```angular2html
    1  sudo apt install vmware-install.pl
    2  pwd
    3  ls
    4  pwd
    5  ls
    6  vmware-install.pl
    7  pwd
    8  ls
    9  pwd
   10  ls
   11  cd 桌面
   12  ls
   13  cp VMwareTools-10.1.6-5214329.tar.gz  ../
   14  ls
   15  cd ..
   16  ls
   17  tar zxvf VMwareTools-10.1.6-5214329.tar.gz 
   18  ls
   19  cd vmware-tools-distrib/
   20  sudo ./vmware-install.pl 
   21  sudo -su
   22  sudo su
   23  ls
:
```

## 4. 浏览多个文件

命令：

```
less log1 log2
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ less log1 log2

我是log1的第一行

我是log1的第三行
我是log1的第四行
我是log1的第五行

我是log1的第七行
log1 (file 1 of 2) (END) - Next: log2
```

说明：

输入 :n后，切换到 下一个文件，log2

输入 :p 后，切换到 上一个文件，log1

## 5．附加备注

### 1.全屏导航

CentOs下：

ctrl + F - 向前移动一屏

ctrl + B - 向后移动一屏

ctrl + D - 向前移动半屏

ctrl + U - 向后移动半屏

Ubuntu下：

ctrl + F - 向后移动一屏

ctrl + B - 向前移动一屏

ctrl + D - 向后移动半屏

ctrl + U - 向前移动半屏

### 2.单行导航

CentOs下：
j - 向前移动一行

k - 向后移动一行
Ubuntu下：
j - 向后移动一行

k - 向前移动一行

### 3.其它导航

G - 移动到最后一行

g - 移动到第一行

q / ZZ - 退出 less 命令

### 4.其它有用的命令

v - 使用配置的编辑器编辑当前文件

h - 显示 less 的帮助文档

&pattern - 仅显示匹配模式的行，而不是整个文件

### 5.标记导航

当使用 less 查看大文件时，可以在任何一个位置作标记，可以通过命令导航到标有特定标记的文本位置：

ma - 使用 a 标记文本的当前位置

'a - 导航到标记 a 处