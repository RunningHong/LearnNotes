[TOC]

# shell学习

## 1 使用shell来encode和decode url

方法一：使用python的命令（但是没找到方法怎么在shell 中直接运行）

```shell
定义编码和解码
$ alias urldecode='python -c "import sys, urllib as ul; \
    print ul.unquote_plus(sys.argv[1])"'

$ alias urlencode='python -c "import sys, urllib as ul; \
    print ul.quote_plus(sys.argv[1])"'

范例：
$ urldecode 'q+werty%3D%2F%3B'
q werty=/;

$ urlencode 'q werty=/;'
q+werty%3D%2F%3B
```

方法二：使用解析

```shell
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

url='qunariphoneyouth://web/url?browserType=1&url=https%3A%2F%2Fzt.dujia.qunar.com%2Fzts%2F2019shuqi%2Ftouch.php%3Fin_track%3Dpush_vacation_sqdc%26et%3Dpush_vacation_sqdc%26bd_source%3Dpush_020021781'

decode_result=$(urldecode "$url")

echo $decode_result
```

## 2 shell返回字符串

```shell
#!/bin/sh

# 示例方法
function get_str() {
	echo "string"
}

#写法一
echo `get_str` 

 #写法二
echo $(get_str)
```

## 3 格式化日期

```shell
echo $(date -d "2018-09-17" +%Y-%m-%d)

# 取2018-09-17的后一天即【2018-09-18】
date -d "2018-09-17 +1 day" +%Y-%m-%d

# 取2018-09-17的前一天即【2018-09-16】
date -d "2018-09-17 -1 day" +%Y-%m-%d
```

## 4 nohup（后台挂起）

```shell
# 作用：不挂断地运行命令

# 语法：
nohup Command [ Arg … ] [ & ]

描述：nohup 命令运行由 Command 参数和任何相关的 Arg 参数指定的命令，忽略所有挂断（SIGHUP）信号。在注销后使用 nohup 命令运行后台中的程序。要运行后台中的 nohup 命令，添加 & （ 表示”and”的符号）到命令的尾部。

带&是为了在terminal（终端）关闭，或者电脑死机程序依然运行（前提是你把程序递交到服务器上）；

无论是否将 nohup 命令的输出重定向到终端，输出都将附加到当前目录的 nohup.out 文件中。如果当前目录的 nohup.out 文件不可写，输出重定向到 $HOME/nohup.out 文件中。如果没有文件能创建或打开以用于追加，那么 Command 参数指定的命令不可调用。如果标准错误是一个终端，那么把指定的命令写给标准错误的所有输出作为标准输出重定向到相同的文件描述符。

【提示】
当shell中提示了nohup成功后还需要按终端上键盘任意键退回到shell输入命令窗口，然后通过在shell中输入exit来退出终端；如果在nohup执行成功后直接点关闭程序按钮关闭终端.。所以这时候会断掉该命令所对应的session，导致nohup对应的进程被通知需要一起shutdown。


# 例子1：
nohup command > myout.file 2>&1 &
在上面的例子中，输出被重定向到myout.file文件中。

# 例子1：
nohup sh bashName > myout.txt 2>&1 &
运行sh将结果存放到指定文件
```

备注：

- 通过 `jobs` 命令可以查看任务， `jobs -l` 查看详细信息。
- `fg %n` （n为数字）让后台运行的进程n到前台来，再可以通过ctrl+c终止任务
- `bg %n` 让进程n到后台去【貌似不管用，可以使用 】
-  `ctrl + z` 可以将一个正在前台执行的命令放到后台,**并且暂停**（再使用 `bg n`就可以开始暂停的任务 ）。



**注意：**如果退出了启动nohup的那个窗口，或者，在其他窗口，无法使用jobs来查看运行中的命令。此时，可以用下面的命令查看：

- top -U username
- ps auxw
- **ps x**

## 5 转码文件

```shell
# 在windows上打开过的linux脚本，换行符会变化
# 导致执行出现：$'\r': command not found

dos2unix -k fileName
```

