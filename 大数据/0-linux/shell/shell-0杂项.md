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

## 2 转码文件

```shell
# 在windows上打开过的linux脚本，换行符会变化
# 导致执行出现：$'\r': command not found

dos2unix -k fileName
```

## 3 Shell中source与sh和.的区别

使用sh和.运行程序，程序会在子程序中运行，这样的结果就是这里面的变量都相当于临时变量，运行后就失效了。

使用source运行程序，程序会在主程序中运行，这样变量就相当于全局变量，运行后还可以在，服务器看到。

![1568368130820](picture/1568368130820.png)

## 4 shell中在脚本中第一行的#!/bin/bash的作用

#!/bin/bash的作用在于告诉shell用哪个shell来运行脚本（因为shell不止一个）

## 5 shell中变量截取

```
假设我们定义了一个变量为：
file=/dir1/dir2/dir3/my.file.txt

可以用${ }分别替换得到不同的值：
${file#*/}：删掉第一个/及其左边的字符串：dir1/dir2/dir3/my.file.txt
${file##*/}：删掉最后一个/及其左边的字符串：my.file.txt
${file#*.}：删掉第一个.及其左边的字符串：file.txt
${file##*.}：删掉最后一个.及其左边的字符串：txt
${file%/*}：删掉最后一个/及其右边的字符串：/dir1/dir2/dir3
${file%%/*}：删掉第一个/及其右边的字符串：(空值)
${file%.*}：删掉最后一个.及其右边的字符串：/dir1/dir2/dir3/my.file
${file%%.*}：删掉第一个.及其右边的字符串：/dir1/dir2/dir3/my

记忆的方法为：
\# 是去掉左边（键盘上#在 $ 的左边）
%是去掉右边（键盘上% 在$ 的右边）
单一符号是最小匹配；两个符号是最大匹配
${file:0:5}：提取最左边的 5个字节：/dir1
${file:5:5}：提取第 5个字节右边的连续5个字节：/dir2

也可以对变量值里的字符串作替换：
${file/dir/path}：将第一个dir替换为path：/path1/dir2/dir3/my.file.txt
${file//dir/path}：将全部dir替换为 path：/path1/path2/path3/my.file.txt

利用 ${ }还可针对不同的变数状态赋值(沒设定、空值、非空值)： 
${file-my.file.txt} ：假如 $file沒有设定，則使用 my.file.txt作传回值。(空值及非空值時不作处理) 
${file:-my.file.txt} ：假如 $file沒有設定或為空值，則使用 my.file.txt作傳回值。 (非空值時不作处理)
${file+my.file.txt} ：假如 $file設為空值或非空值，均使用 my.file.txt作傳回值。(沒設定時不作处理)
${file:+my.file.txt} ：若 $file為非空值，則使用 my.file.txt作傳回值。 (沒設定及空值時不作处理)
${file=my.file.txt} ：若 $file沒設定，則使用 my.file.txt作傳回值，同時將 $file賦值為 my.file.txt。 (空值及非空值時不作处理)
${file:=my.file.txt} ：若 $file沒設定或為空值，則使用 my.file.txt作傳回值，同時將 $file賦值為 my.file.txt。 (非空值時不作处理)
${file?my.file.txt} ：若 $file沒設定，則將 my.file.txt輸出至 STDERR。 (空值及非空值時不作处理)



${file:?my.file.txt}：若 $file 没设定或为空值，则将 my.file.txt输出至 STDERR。 (非空值時不作处理)

${#var}可计算出变量值的长度：
${#file}可得到 27 ，因为/dir1/dir2/dir3/my.file.txt是27个字节
```

