[TOC]

# ContentType相关

**问题现象：**

前端POST请求参数已经传过来了，Java后端Debug也能进到请求里，可就是取不到请求参数。

## 1 介绍

HTTP Content-Type 是用于标识传输数据的类型。在请求中，Content-Type告诉服务端实际请求内容的类型；在响应中，Content-Type告诉客户端实际返回内容的类型。

HTTP定义的Content-Type类型有近200种（https://www.w3cschool.cn/http/ahkmgfmz.html），其中最常用的是以下三种：

## 2 常用ContentType

### 2.1 application/x-www-form-urlencoded

请求参数在Form Data中，只能上传键值对，并且键值对都是间隔分开的。
参数形式:  name1=value1&name2=value2

### 2.2 multipart/form-data

请求参数在Request Payload中，既可以上传文件等二进制数据，也可以上传表单键值对，只是最后会转化为一条信息。
浏览器将表单内的数据和文件放在一起发送。这种方式会定义一个不可能在数据中出现的字符串作为分隔符，然后用它将各个数据段分开。

### 2.3 application/json

请求参数在Request Payload中

参数形式: {key1:value1,key2:value2}

## 3 Java 对应的请求

重点：对应以上三种类型Java服务端获取请求参数的方法也不同(伪代码)

### 3.1 application/x-www-form-urlencoded

1）注解@RequestParam(value="name1") String name1  
2）注解@ModelAttribute 绑定请求参数到指定对象
3）HttpServletRequest.getParameter("name1")

### 3.2 multipart/form-data

流HttpServletRequest.getInputStream()或者HttpServletRequest.getReader()

### 3.3 application/json

1）注解@RequestBody 
2）流HttpServletRequest.getInputStream()或者HttpServletRequest.getReader()

Tips: request.getParameter()、 request.getInputStream()、request.getReader()这三种方法是有冲突的，因为流只能被读一次，所以只有第一次能取到参数。

## 4 原理

那么是什么导致Content-Type类型不同取参方式也不同呢？

由于Tomcat对于Content-Type multipart/form-data（文件上传）和application/x-www-form-urlencoded（POST请求）做了“特殊处理”:

Tomcat的HttpServletRequest类的实现类为org.apache.catalina.connector.Request，而它处理请求参数的方法为protected void parseParameters()，这个方法中对Content-Type multipart/form-data（文件上传）和application/x-www-form-urlencoded（POST请求）做了处理，会解析表单数据放到request parameter map中。其他请求不会解析表单数据，所以通过request.getParameter()是获取不到的。

服务器为什么会对Content-Type application/x-www-form-urlencoded做特殊处理？

因为表单提交数据是名值对的方式，而其他的post请求（Content-Type不是application/x-www-form-urlencoded）数据格式不固定，不一定是名值对的方式，服务器无法知道具体的处理方式，所以只能通过获取原始数据流的方式来进行解析。

## 5 其他

jQuery在执行post请求时，会默认设置Content-Type为application/x-www-form-urlencoded，所以服务器能够正确解析，而使用原生ajax请求时，如果不显示的设置Content-Type，那么默认是**text/plain**，这时服务器就不知道怎么解析数据了，所以才只能通过获取原始数据流的方式来进行解析请求数据。

jQuery中的dataType指的是预期服务器返回的数据类型，而不是发送的数据类型。如果不指定，jQuery 将自动根据 HTTP 包 MIME 信息来智能判断，比如 XML MIME 类型就被识别为 XML。这样服务端返回json数据，前端就会获取不到返回值。