[TOC]

# 用Shell判断字符串包含关系

## 1 利用grep

先打印长字符串，然后在长字符串中 grep 查找要搜索的字符串，用变量result记录结果

如果结果不为空，说明strA包含strB。如果结果为空，说明不包含。

```shell
strA="long string"
strB="string"
result=$(echo $strA | grep "${strB}")
if [[ "$result" != "" ]]; then
  echo "包含"
else
  echo "不包含"
fi
```

## 2 利用字符串运算符

利用字符串运算符 =~ 直接判断strA是否包含strB。

```shell
strA="helloworld"
strB="low"
if [[ $strA =~ $strB ]]; then
  echo "包含"
else
  echo "不包含"
fi
```

## 3 利用通配符

```shell
A="helloworld"
B="low"
if [[ $A == *$B* ]]
then
  echo "包含"
else
  echo "不包含"
fi
```

