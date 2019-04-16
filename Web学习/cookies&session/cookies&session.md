[TOC]

# cookies&session

## 1 无状态和无连接

- 无状态：每次连接只处理一个请求，服务端处理完客户端一次请求，等到客户端作出回应之后便**断开连接**；
- 无连接：是指服务端对于客户端每次发送的请求都认为它是一个**新的请求**，上一次会话和下一次会话没有联系；

就拿Http来说，Http是一个无状态的协议。http是基于tcp的，从http1.1开始默认使用**持久连接**；在连接过程中客户端可以向服务端发送多次请求，但是各个请求之间的并没有什么联系（无连接体现）。

无状态其实指的是信息（客户端与服务端之间的通信介质）的无状态，因为HTTP本身是不保存任何用户的状态信息的，所以HTTP是无状态的协议。

持久连接：本质上是客户端与服务器通信的时候，建立一个**持久化的TCP连接**，这个连接**不会随着请求结束而关闭**，通常会保持连接一段时间。

## 2 保持状态信息

通过引入cookie和session体系机制来维护状态信息。

即用户第一次访问服务器的时候，服务器响应报头通常会出现一个Set-Cookie响应头，这里其实就是在本地设置一个cookie，当用户再次访问服务器的时候，http会附带这个cookie过去，cookie中存有sessionId这样的信息来到服务器这边确认是否属于同一次会话。

## 3 cookie

cookie是由**服务器发送给客户端**（浏览器）的小量信息，以{key：value}的形式存在。下面是一个网站的cookie

![1555379052156](https://github.com/RunningHong/LearnNotes/blob/master/picture/1555379052156.png?raw=true)

通过内容我们可以看见cookie的主要属性有name，value，deman等等。

### 3.1 cookie机制

客户端请求服务器时，如果服务器需要记录该用户状态，就使用response向客户端浏览器颁发一个Cookie。而客户端浏览器会把Cookie保存起来。当浏览器再请求 服务器时，浏览器把请求的网址连同该Cookie一同提交给服务器。服务器通过检查该Cookie来获取用户状态。（**可以这样理解，客户端有点笨，服务端发送的有些信息，客户端需要使用小本本（cookie）记着，每次客户端去见服务端都要把小本本带上**）

### 3.2 Cookie同源与跨域

Cookie的同源**只关注域名**，是忽略协议(http/https)和端口的。所以一般情况下，https://localhost:80/和http://localhost:8080/的Cookie是共享的。

Cookie是不可跨域的。

### 3.3 cookie在servlet-api中的定义

```java
public class Cookie implements Cloneable, Serializable {
    private static final long serialVersionUID = -6454587001725327448L;
    private static final String TSPECIALS;
    private static final String LSTRING_FILE = "javax.servlet.http.LocalStrings";
    private static ResourceBundle lStrings = ResourceBundle.getBundle("javax.servlet.http.LocalStrings");
    
    // cookie的名字，name唯一，可以看做map中的key
    private String name;
    
    // cookie 的值
    private String value;
    
    // cookie说明
    private String comment;
    
    // 可以访问该Cookie的域名。如果设置为“.baidu.com”（注意第一个字符为.），则所有以“baidu.com”结尾的域名都可以访问该Cookie；
    private String domain;
    
    // Cookie失效的时间，单位秒。
    // 如果为正数则超过maxAge秒之后失效;
    // 如果为负数则为临时的cookie，关闭浏览器就失效；
    // 为0表示删除cookie
    private int maxAge = -1;
    
    // cookie的使用路径
    // 如果path=/，说明本域名下contextPath都可以访问该Cookie。
    // path=/app/，则只有contextPath为“/app”的程序可以访问该Cookie
    private String path;
    
    // 该Cookie是否仅被使用安全协议传输。这里的安全协议包括HTTPS，SSL等。默认为false。
    private boolean secure;
    
    // Cookie使用的版本号。
    private int version = 0;
    
    // HttpOnly属性是用来限制非HTTP协议程序接口对客户端Cookie进行访问；也就是说如果想要在客户端取	 // 到httponly的Cookie的唯一方法就是使用AJAX(不能通过js注解获取cookie)，
    // 将取Cookie的操作放到服务端，接收客户端发送的ajax请求后将取值结果通过HTTP返回客户端。这样能有效的防止XSS攻击。
    private boolean isHttpOnly = false;   
}
```

### 3.4 使用方法

#### 3.4.1 创建cookie

```java 
Cookie cookie = new Cookie("cookieId","value");

// 设置域名
cookie.setDomain(".baidu.com"); 

// 设置路径
cookie.setPath("/");

 // 设置有效期为永久
cookie.setMaxAge(Integer.MAX_VALUE); 

// 通过response回写到客户端
response.addCookie(cookie);                 
```

#### 3.4.2 更新cookie

只有通过addCookie添加相同name的cookie进行覆盖前面的cookie才能实现cookie的更新。

```java
Cookie cookie = new Cookie("cookieId","newValue");
response.addCookie(cookie);
```

#### 3.3.3 删除cookie

删除Cookie可以通过将maxAge设置为0即可。

```java
Cookie cookie = new Cookie("cookieId","new-value");
cookie.setMaxAge(0);
response.addCookie(cookie);
```

一些默认情况会删除cookie：

- 如果maxAge是负值，则cookie在浏览器关闭时被删除
- 持久化cookie在到达失效日期时会被删除
- 浏览器中的 cookie 数量达到上限，那么 cookie 会被删除以为新建的 cookie 创建空间。

#### 3.4.4 获取cookie

```java
// 只有通过request.getCookies()才能获取cookie值，通过遍历获取指定的值
Cookie[] cookies = request.getCookies();
```

