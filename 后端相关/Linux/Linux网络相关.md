[TOC]

# Linux 网络相关

## 1 curl

参数：

​	-X指定requestde method，如GET POST等

​	-H指定请求的headr,如“contetn-type:application/json"

​	-d指定post请求的data,消息体

​	-b 指定请求的cookie, 可以在-H中设置。

​	-c 输出响应的set-cookie的内容到文件

​	-i 指定输出response的header信息等。

​	-w 指定输出部分格式化的数据，如请求时间。

- `curl www.baidu.com` 参看相关信息

## 2 wget

通常使用该命令来下载文件，其他可以被curl代替。

## 3 ping

全名（Packet Internet Groper）基于ICMP,用于检查网络的连通性，服务器的可访问性。

## 4 nc

网络发包工具

参数：

- -t 发送tcp数据包
- -u发送udp数据包
- -l 监听服务的某个端口

## 5 telnet

telnet协议的工具

登录和tcp链接测试

## 6 netstat

查看本机的网络连接和网络端口信息

## 7 tcpdump

网络抓包工具

tcpdump -vvv -i eth0 host 10.86.42.63 and tcp and prot 2181 -w ./temp.pcap

## 8 ssh

用于安全的远程登录，Secure Shell 客户端。

## 9 scp

远程拷贝。

scp ./xxx user@host:path

scp user@host:path/xxx./

## 10 ps

进程查看。

`ps -ef` 查看进程信息。

`ps -Lf pid` 查看指定进程的线程信息。

## 11 free

查看内存使用信息。

`free -m` 按M（兆）的形式显示。

free -h

## 12 top

查看cpu使用率，内存信息，进程情况，cpu load 等重要信息。

## 13 kill

发射一个信号给进程。

`kill -9 pid` 强制终止、杀死进程。

`kill -l` 中断、正常退出、暂停、继续。



