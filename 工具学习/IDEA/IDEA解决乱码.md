[TOC]

# IDEA解决乱码

## 1 工程乱码

第一步把工程的编码设置为UTF-8

![](..\..\picture\IDEA工程设置编码.png)

## 2 执行main函数乱码

添加参数 `-encoding utf-8`

![1557644731073](D:\我的大学\学习笔记\picture\1557644731073.png)

## 3 tomcat乱码

添加 `-Dfile.encoding=UTF-8` 参数

![1557644852642](D:\我的大学\学习笔记\picture\1557644852642.png)

## 4 IDEA配置

如果上面的方案不生效时，打开IDEA安装目录，在bin目录下找到这两个文件：

- `idea.exe.vmoptions`
- `idea64.exe.vmoptions`

打开文件文件， 在文件末尾加上 `-Dfile.encoding=UTF-8` 参数。

![1557645026325](D:\我的大学\学习笔记\picture\1557645026325.png)

