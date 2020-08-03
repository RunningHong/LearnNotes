[toc]

more命令，功能类似 cat ，cat命令是整个文件的内容从上到下显示在屏幕上。 more会以一页一页的显示方便使用者逐页阅读，而最基本的指令就是按空白键（space）就往下一页显示，**按 b 键就会往回（back）一页显示**，而且还有搜寻字串的功能 。more命令从前向后读取文件，因此在启动时就加载整个文件。

# 一．命令格式：

```
more [-dlfpcsu ] [-num ] [+/ pattern] [+ linenum] [file ... ] 
```

# 二．命令功能：

more命令和cat的功能一样都是查看文件里的内容，但有所不同的是more可以按页来查看文件的内容，还支持直接跳转行等功能。

# 三．命令参数：

| 参数      | 描述                                                         |
| --------- | ------------------------------------------------------------ |
| +n        | 从笫n行开始显示                                              |
| -n        | 定义屏幕大小为n行                                            |
| +/pattern | 在每个档案显示前搜寻该字串（pattern），然后从该字串前两行之后开始显示 |
| -c        | 从顶部清屏，然后显示                                         |
| -d        | 提示“Press space to continue，’q’ to quit（按空格键继续，按q键退出）”，禁用响铃功能 |
| -l        | 忽略Ctrl+l（换页）字符                                       |
| -p        | 通过清除窗口而不是滚屏来对文件进行换页，与-c选项相似         |
| -s        | 把连续的多个空行显示为一行                                   |
| -u        | 把文件内容中的下画线去掉                                     |

# 四．常用操作命令：

| 操作命令    | 描述                         |
| ----------- | ---------------------------- |
| Enter       | 向下n行，需要定义。默认为1行 |
| Ctrl+F      | 向下滚动一屏                 |
| 空格键 向下 | 滚动一屏                     |
| Ctrl+B      | 返回上一屏                   |
| =           | 输出当前行的行号             |
| ：f         | 输出文件名和当前行的行号     |
| V           | 调用vi编辑器                 |
| !命令 调    | 用Shell，并执行命令          |
| q           | 退出more                     |

# 五. 使用实例

## 1. 从第3行起显示log1文件中的内容

命令：

```
more +3 log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ nl -b a log1 
     1	我是log1的第一行
     2	
     3	
     4	我是log1的第四行
     5	我是log1的第五行
     6	
     7	我是log1的第七行
hc@hc-virtual-machine:~/snap$ more +3 log1 

我是log1的第四行
我是log1的第五行

我是log1的第七行
```

## 2.从文件中查找第一个出现"五"字符串的行，并从该处前两行开始显示输出

命令：

```
more +/五 log1
```

输出：

```angular2html
hc@hc-virtual-machine:~/snap$ cat log1 
我是log1的第一行

我是log1的第三行
我是log1的第四行
我是log1的第五行

我是log1的第七行
hc@hc-virtual-machine:~/snap$ more +/五 log1

...跳过
我是log1的第三行
我是log1的第四行
我是log1的第五行

我是log1的第七行
```

## 3.设定每屏显示2行

命令：

```
more -2 log1
```

输出:

显示输出文件的第一二行

```angular2html
hc@hc-virtual-machine:~/snap$ more -2 log1 
我是log1的第一行

--更多--(20%)
```

按下ENTER键后,向下n行，需要定义。默认为1行，输出了第三行

```angular2html
我是log1的第一行

我是log1的第三行
--更多--(40%)
```

按下空格键后,向下滚动一屏(当前设置的是一屏为2行)，输出了第四五行

```angular2html
hc@hc-virtual-machine:~/snap$ more -2 log1 
我是log1的第一行

我是log1的第三行
我是log1的第四行
我是log1的第五行
--更多--(79%)
```

## 4. 列一个目录下的文件，由于内容太多，我们应该学会用more来分页显示。这得和管道 | 结合起来

命令：

```
ls | more -5
```

输出：

```angular2html
hc@hc-virtual-machine:~$ ls
examples.desktop  PycharmProjects  vmware-tools-distrib  模板  图片  下载  桌面
git_demo          snap             公共的                视频  文档  音乐
hc@hc-virtual-machine:~$ ls | more -5
examples.desktop
git_demo
PycharmProjects
snap
vmware-tools-distrib
--更多--
```

说明：

每页显示5个文件信息，按 Ctrl+F 或者 空格键 将会显示下5条文件信息。