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

## 2 shell方法返回字符串

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

[获得当前时间]
date "+%H:%M:%S"
[获取单签日期以及时间，格式可以自己转换]
date "+%Y-%m-%d %H:%M:%S"
备注：
    date后面有一个空格，否则无法识别命令，shell对空格还是很严格的。
    Y显示4位年份，如：2018；
    y显示2位年份，如：18;
    m表示月份;
    M表示分钟;
    d表示天;
    D则表示当前日期，如：1/18/18(也就是2018.1.18);
    H表示小时，而h显示月份(有点懵逼);
    s显示当前秒钟，单位为毫秒;
    S显示当前秒钟，单位为秒。
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

## 6 判断（数字、字符串、文件、逻辑）【[]、(())、[[]]的使用】

```shell
########################### 数字比较 ###############################
if [ $1 -gt $2 ]; then
	echo "参数$1大于参数$2"
else 
	echo "参数$1小于参数$2"
fi

# 数字判断的一些命令：
# -gt 大于
# -ge 大于等于
# -lt 小于
# -le 小于等于
# -eq 等于
# -ne 不等于

# 或者使用这种方式[支持各种判断]：
if (( $1<$2 || $1==$1 )); then
	echo "right"
else
	echo "error"
fi


########################### 字符串判断 ###############################
str1 = str2　　　　  当两个串有相同内容、长度时为真 
str1 != str2　　　　 当串str1和str2不等时为真 
-n str1　　　　　　　 当串的长度大于0时为真(串非空) 
-z str1　　　　　　　 当串的长度为0时为真(空串) 
str1　　　　　　　　   当串str1为非空时为真


########################### 文件判断 ###############################
-r file　　　　　用户可读为真 
-w file　　　　　用户可写为真 
-x file　　　　　用户可执行为真 
-f file　　　　　文件为正规文件为真 
-d file　　　　　文件为目录为真 
-c file　　　　　文件为字符特殊文件为真 
-b file　　　　　文件为块特殊文件为真 
-s file　　　　　文件大小非0时为真 
-t file　　　　　当文件描述符(默认为1)指定的设备为终端时为真


########################### 逻辑判断（与或非） ###############################
-a 　 　　　　　 与 
-o　　　　　　　 或 
!　　　　　　　　非


########################### 判断中[[]]的使用 ###############################
然后是[[ ]]，这是内置在shell中的一个命令，它就比刚才说的test强大的多了。支持字符串的模式匹配（使用=~操作符时甚至支持shell的正则表达 式）。简直强大的令人发指！逻辑组合可以不使用test的-a,-o而使用&&,||这样更亲切的形式(针对c、Java程序员)。当然，也不用想的太复杂，基本只要记住
1.字符串比较时可以把右边的作为一个模式（这是右边的字符串不加双引号的情况下。如果右边的字符串加了双引号，则认为是一个文本字符串。），而不仅仅是一个字符串，比如[[ hello == hell? ]]，结果为真。
2.另外要注意的是，使用[]和[[]]的时候不要吝啬空格，每一项两边都要有空格，[[ 1 == 2 ]]的结果为“false”，但[[ 1==2 ]]的结果为“true”！后一种显然是错的
```

