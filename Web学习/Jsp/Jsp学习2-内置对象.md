[TOC]

# Jsp内置对象

## 1 内置对象简介

JSP内置对象是Web容器创建的一组对象，不使用new关键字就可以使用。

```jsp
<%
	int[] value = {10,20,30};
    for(int i=0; i<10; i++) {
		out.println(i); // 使用内置对象out
    }
%>
```

## 2 常用的内置对象

out，request, response, session, application, Page, pageContext, exception, config

## 3 out对象

out对象是JspWriter类的示例，是向客户端输出内容的对象。

常用方法：

| 方法                  | 说明                                              |
| --------------------- | ------------------------------------------------- |
| void println()        | 向客户端打印字符串                                |
| void clear()          | 清除缓冲区的内容，如果在flush之后调用会抛出异常。 |
| void clearBuffer();   | 清除缓冲区内容，如果在flush之后调用不会抛出异常   |
| void flush()          | 将缓冲区内容输出到客户端                          |
| int getBufferSize()   | 返回缓冲区以字节数的大小，如不设缓冲区则为0       |
| int getRemaining()    | 返回缓冲区还剩多少可用                            |
| boolean isAutoFlush() | 返回缓冲区满时，是自动清空还是抛出异常。          |
| void close()          | 关闭输出流                                        |

## 4 request对象

客户端的请求信息被封装在 request对象中,通过它才能了解到客户的需求,然后做出响应。它是 HttpservletreQuest类的实例。 request对象具有请求域即完成客户端的请求之前该对象一直有效。

常用方法如下

| 方法                                       | 说明                           |
| ------------------------------------------ | ------------------------------ |
| String getParameter( String name)          | 返回name指定参数的参数值       |
| String[] getParameter Values( String name) | 返回包含参数name的所有值的数组 |
| void setAttribute( String, Object):        | 存储此请求中的属性。           |
| Object getAttribute( String name)          | 返回指定属性的属性值           |
| String getContentType（）                  | 得到请求体的MIME类型           |
| String getProtocol（）                     | 返回请求用的协议类型及版本号   |
| String getServerName（）                   | 返回接受请求的服务器主机名     |

## 5 response对象

response对象包含了响应客户请求的有关信息,但在JSP中很少直接用到它。它是HttpservletresPonse类的实例。 response对象具有页面作用域,即访问一个页面时,该页面内的 Response对象只能对这次访问有效,其它页面的 Response对象对当前页面无效。常用方法如下:

| 方法                                      | 说明                                                         |
| ----------------------------------------- | ------------------------------------------------------------ |
| String getCharacterEncoding()             | 返回响应用的是何种字符编码                                   |
| void setContentType( String type)         | 设置响应的MIME类型                                           |
| PrintWriter getWritert()                  | 返回可以向客户端输出字符的一个对象(注意比较:PrintWriter与内置out对象的区别) |
| send Redirect(java.lang. String location) | 重新定向客户端的请求                                         |

## 6 请求转发与请求重定向

请求重定向：客户端行为，response.sendRedirect(), 从本质上等于两次请求，前一次的请求对象不会保存，地址栏的URL地址会改变。

请求转发：服务器行为，request.getRequestDispatcher().forward(req,resp);是一次请求，转发后请求对象会保存，地址栏URL地址不会改变。

