[TOC]

# Nginx学习笔记

一个高性能的HTTP server

反向代理服务器（IMAP/POP3/SMTP/HTTP/HTTPS）

具有丰富的module，提供丰富功能。

## 1 代理

两者的区别在于代理的对象不一样：**正向代理**代理的对象是客户端，**反向代理**代理的对象是服务端。

### 1.1 正向代理

我们把服务请求都转向proxy，proxy再访问资源。（想象Google代理）

特点：Google只知道代理访问了它，但不知道到底是谁访问了它。

### 1.2 反向代理

反向代理隐藏了真实的服务端，当我们请求 ww.baidu.com 的时候，就像拨打10086一样，背后可能有成千上万台服务器为我们服务，但具体是哪一台，你不知道，也不需要知道，你只需要知道反向代理服务器是谁就好了，ww.baidu.com 就是我们的反向代理服务器，反向代理服务器会帮我们把请求转发到真实的服务器那里去。Nginx就是性能非常好的反向代理服务器，用来做负载均衡。

### 2 常用的Nginx分支

Nginx source, Nginx Plus

Tengine:淘宝团队开发、维护的nginx分支

OpenResty:基于nginx开发，拥有丰富的module。

## 3 配置文件

Nginx.conf:基本配置文件

Mine.type:文件扩展列表，与MIME类型关联。

### 3.1 server

