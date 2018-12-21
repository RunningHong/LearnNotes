[TOC]

摘自《鸟哥的Linux私房菜 - 基础学习篇》

# Linux的Shell Script

## 1 script注意事项

1. 指令的执行是从上而下、从左而有的分析与执行；
2. 指令、选项与参数间的多个空白都会被忽略掉；
3. 空白行也将被忽略掉，并且`tab`按键所推开的空白同样规为空格键；
4. 如果读到一个`Enter`符号，就尝试开始执行命令；
5. 如果一行内容太多，可以使用 `\Enter` 来延伸到下一行；
6. `#` 作为注释， `#` 后面的信息将被忽略。
7. 在bash中用一个 `=` 或者用两个 `=` 进行值比较是一样的。

## 2 执行script

现在我们写好了一个script，文件名为 `/home/ddd/shell.sh`, 怎样执行它：

1. 直接指令下达（**shell.sh必须具有rx权限**）
   - 绝对路径：使用 `/home/ddd/shell.sh` 来下达指令。
   - 相对路径：假设现在在 `/home/ddd/` , 使用 `.shell.sh` 来执行。
   - 变量 `PATH` 功能：将shell.sh放在PATH指定目录下，如：~/bbb/
2. 使用bash程序
   - 通过 `bash shell.sh` 执行。
   - 通过 `sh shell.sh` 执行。
   - 通过 `source` 来执行指令（把代码放到父程序执行），执行后script申明的变量变为全局可读取。


## 3 script的一些指令

### 3.1 打印信息（echo）

| 命令          | 说明     |
| ------------- | -------- |
| `echo "信息"` | 打印信息 |

### 3.2 读取信息（read）

| 命令                     | 说明                         |
| ------------------------ | ---------------------------- |
| `read "提示信息" 变量名` | 读取输入的值并把值赋给变量。 |
| `echo $变量名`           | 取得变量的值。               |

### 3.3 测试（test）

`test` 指令告诉我们是exist还是not exist，也可以使用 `[ 判断语句 ]` 来代替 `test`

#### 3.3.1 档案**文件类型**判断

```shell
[root@www ~]# test -参数 fileName
```

| 参数 | 说明                     |
| ---- | ------------------------ |
| -e   | 是否存在file             |
| -f   | 是否存在，并且是否为file |
| -d   | 是否存在且为目录         |
| -L   | 是否存在且为连接档       |

#### 3.3.2 档案权限判断

```shell
[root@www ~]# test -参数 fileName
```

| 参数 | 说明         |
| ---- | ------------ |
| -r   | 具有可读权限 |
| -w   | 具有可写权限 |
| -x   | 具有可执行   |

#### 3.3.3 两个档案之间比较

```shell
[root@www ~]# test file1 -参数 file2
```

| 参数 | 说明                                 |
| ---- | ------------------------------------ |
| -nt  | 判断file1是否比file2新（newer than） |
| -ot  | 判断file是否比file2旧（older than）  |
| -ef  | 判断两个档案是否为同一档案。         |

#### 3.3.4 整数间的比较

```shell
[root@www ~]# test num1 -参数 num2
```

| 参数 | 说明                  |
| ---- | --------------------- |
| -eq  | 相等?（equal）        |
| -ne  | 不相等？（not equal） |
| -gt  | num1 > num2 ?         |
| -lt  | num1 < num2 ?         |
| -ge  | num1 >= num2 ?        |
| -le  | num1 <= num2 ?        |

#### 3.3.5 字符串的判断

| 指令                | 说明         |
| ------------------- | ------------ |
| `test -z str`       | 字符串为空？ |
| `test -n str`       | 字符串非空？ |
| `test str1 = str2`  | str1==str2?  |
| `test str1 != str2` | str1!=str2?  |

#### 3.3.6 多重条件判定

```shell
[root@www ~]# test -r filename -a -x filename
```

| 参数 | 说明                                                         |
| ---- | ------------------------------------------------------------ |
| -a   | (and)两状况同时成立！例如 test -r file -a -x file，则 file 同时具有r 与 x 权限时，才回传 true。 |
| -o   | (or)两状况任何一个成立！例如 test -r file -o -x file，则 file 具有 r或 x 权限时，就可回传 true。 |
| !    | 相反状态，如 test ! -x file ，当 file 不具有 x 时，回传 true |

### 3.4 条件判断语句

#### 3.4.1 简单条件判断（if）

```shell
# 语法
if [ 条件判断式 ]; then
	当条件判断成立时，可以进行的指令工作内容；
fi <==将 if 反过来写，就成为 fi 啦！结束 if 之意！
```

#### 3.4.2 多重条件判断（if...else）

```shell
# 一个条件判断，分成功与失败进行 (else)
if [ 条件判断式 ]; then
	当条件判断式成立时，可以进行的指令工作内容；
else
	当条件判断式不成立时，可以进行的指令工作内容；
fi


# 多个条件判断 (if ... elif ... elif ... else) 分多种不同情况执行
if [ 条件判断式一 ]; then
	当条件刞断式一成立时，可以进行的指令工作内容；
elif [ 条件判断式二 ]; then
	当条件判断式二成立时，可以进行的指令工作内容；
else
	当条件判断式一与二均不成立时，可以进行的指令工作内容；
fi

# 使用case关键字（示例）
case $1 in
"hello")
	echo "Hello, how are you ?"
	;;
"")
	echo "You MUST input parameters, ex> {$0 someword}"
	;;
*) # 其实就相当亍通配符，0~无穷多个任意字符乀意！
	echo "Usage $0 {hello}"
	;;
esac
```

### 3.5 方法（function）

function的的定义**一定要在程序最前面**，这样才能被程序认出来。

```shell
function fun() {
    程序
}
```

### 3.6 循环（loop）

#### 3.6.1 使用while

```shell
# 使用while
while [ condition ] <==中括号内的状态就是刞断式
do 			<==do 是循环的开始！
	程序段落
done 		<==done 是循环的结束

############# 举例 ##############
s=0 # 这是加总的数值发数
i=0 # 这是累计的数值，亦即是 1, 2, 3....
while [ "$i" != "100" ]
do
	i=$(($i+1)) # 每次 i 都会增加 1
	s=$(($s+$i)) # 每次都会加总一次！
done
echo "The result of '1+2+3+...+100' is ==> $s"
```

#### 3.6.2 使用until

```shell
# 使用until
until [ condition ]
do
	程序段落
done
```

#### 3.6.3 固定循环

```shell
# 固定循环
for var in con1 con2 con3 ...
do
	程序段
done

############# 举例 ##############
for animal in dog cat elephant
do
	echo "There are ${animal}s.... "
done
```

#### 3.6.4 for循环

```shell
for (( 刜始值; 限制值; 执行步阶 ))
do
	程序段
done

############# 举例 ##############
s=0
for (( i=1; i<=$nu; i=i+1 ))
do
	s=$(($s+$i))
done
echo "The result of '1+2+3+...+$nu' is ==> $s"
```

### 3.7 script的debug

```shell
[root@www ~]# sh [-nvx] scripts.sh
选项与参数：
-n ：不要执行 script，仅查询语法的问题；
-v ：再执行 sccript 前，先将 scripts 的内容输出到屏幕上；
-x ：将使用到的 script 内容显示到屏幕上，这是很有用的参数！

############# 举例 ##############
范例一：测试 sh16.sh 有无语法的问题？
[root@www ~]# sh -n sh16.sh
# 若语法没有问题，则不会显示任何信息！

范例二：将 sh15.sh 的执行过程全部列出来～
[root@www ~]# sh -x sh15.sh
```







