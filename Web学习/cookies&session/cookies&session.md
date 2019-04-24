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

## 4 session

session也可以保持状态信息不过相对cookie session是以**服务端**保存状态的。

### 4.1 session机制

当客户端请求创建一个session的时候，服务器会先检查这个客户端的请求里是否已包含了一个session标识 - sessionId，

- 如果已包含这个sessionId，则说明以前已经为此客户端创建过session，服务器就按照sessionId把这个session检索出来使用（如果检索不到，可能会新建一个）
- 如果客户端请求不包含sessionId，则为此客户端创建一个session并且生成一个与此session相关联的sessionId

sessionId的值一般是一个既不会重复，又不容易被仿造的字符串，这个sessionId将被在本次响应中返回给客户端保存。**保存sessionId的方式大多情况下用的是cookie。**

### 4.2 HttpSession接口

```java
public interface HttpSession {
    /**
     * 返回session的创建时间
     */
    public long getCreationTime();
    
    /**
     * 返回一个sessionId,唯一标识
     */
    public String getId();
    
    /**
     *返回客户端最后一次发送与该 session 会话相关的请求的时间
     *自格林尼治标准时间 1970 年 1 月 1 日午夜算起，以毫秒为单位。
     */
    public long getLastAccessedTime();
    
    /**
     * 返回当前session所在的ServletContext
     */
    public ServletContext getServletContext();

    public void setMaxInactiveInterval(int interval);

    /**
     * 返回 Servlet 容器在客户端访问时保持 session
     * 会话打开的最大时间间隔
     */
    public int getMaxInactiveInterval();
    
    public HttpSessionContext getSessionContext();

    /**
     * 返回在该 session会话中具有指定名称的对象，
     * 如果没有指定名称的对象，则返回 null。
     */
    public Object getAttribute(String name);
    
    public Object getValue(String name);

    /**
     * 返回 String 对象的枚举，String 对象包含所有绑定到该 session
     * 会话的对象的名称。
     */    
    public Enumeration<String> getAttributeNames();
    
    public String[] getValueNames();

    public void setAttribute(String name, Object value);

    public void putValue(String name, Object value);

    public void removeAttribute(String name);

    public void removeValue(String name);

    /**
     * 指示该 session 会话无效，并解除绑定到它上面的任何对象。
     */
    public void invalidate();
    
    /**
     * 如果客户端不知道该 session 会话，或者如果客户选择不参入该
     * session 会话，则该方法返回 true。
     */
    public boolean isNew();
}
```

### 4.3 创建session

```java
// 1、创建Session对象
HttpSession session = request.getSession(); 
```

如果session不存在，就新建一个；如果是false的话，标识如果不存在就返回null；

### 4.4 session生命周期

session的生命周期指的是从Servlet容器创建session对象到销毁的过程。Servlet容器会依据session对象设置的存活时间，在达到session时间后将session对象销毁。session生成后，只要用户继续访问，服务器就会更新session的最后访问时间，并维护该session。

### 4.5 session的有效期

session一般在内存中存放，内存空间本身大小就有一定的局限性，因此session需要采用一种**过期删除**的机制来确保session信息不会一直累积，来防止内存溢出的发生。

session的超时时间可以通过maxInactiveInterval属性来设置。

如果想让session失效的话，也可以当通过invalidate()来完成。

## 5 关于鉴权

### 5.1 使用session

session认证主要分四步： 

1. 服务器在接受客户端首次访问时在服务器端创建seesion，然后保存seesion(我们可以将seesion保存在内存中，也可以保存在redis中)，然后给这个session生成一个唯一的标识字符串（sessionId）,然后在响应头中种下这个唯一标识字符串。 
2. 签名。这一步只是对sid进行加密处理，服务端会根据这个secret密钥进行解密。（非必需步骤） 
3. 浏览器中收到请求响应的时候会解析响应头，然后将sessionId保存在本地cookie中，浏览器在下次http请求的请求头中会带上**该域名下的cookie信息**。
4. 服务器在接受客户端请求时会去解析请求头cookie中的sessionId，然后根据这个sessionId去找服务器端保存的该客户端的session，然后判断该请求是否合法。

**session其实也是使用了cookie的，所以浏览器禁用cookie会使session保持状态信息失败。**

sessionId是存放在服务器的（可通过redis保存等）。因为客户端每次请求带的token/sessionId都需要去Redis里查找看是否存在且有效，无效就无法访问了，是否有效由后台决定，失效操作可以进行逻辑删除或物理删除。

### 5.2 使用Token验证

使用基于 Token 的身份验证方法，大概的流程是这样的：

    1. 客户端使用用户名跟密码请求登录 
    2. 服务端收到请求，去验证用户名与密码 
    3. 验证成功后，服务端会签发一个 Token，再把这个 Token 发送给客户端 
    4. 客户端收到 Token 以后可以把它存储起来，比如放在 Cookie 里或者 Local Storage 里 
    5. 客户端每次向服务端请求资源的时候需要带着服务端签发的 Token 
    6. 服务端收到请求，然后去验证客户端请求里面带着的 Token，如果验证成功，就向客户端返回请求的数据

这样一看流程感觉和session差不多，感觉就是使用Token代替了sessionId，但其实这里面的差别还是有的：

- sessionId是一个由服务器生成的字符串，服务端是根据这个字符串，来查询在服务器端保持的seesion，**这里面才保存着用户的登陆状态（就是说有sessionId不一定就是成功的，需要验证是否是这个session）**。但是**token本身就是一种登陆成功凭证（只有登录成功了才会有token出现）**，它是在登陆成功后根据某种规则生成的一种信息凭证，他里面本身就保存着用户的登陆状态。服务器端只需要根据定义的规则校验这个token是否合法就行（通过这的再次验证可以实现会话过期等功能）。
- session是需要cookie配合的，cookie只有在浏览器才会去解析响应头的cookie（在一些原生的APP中cookie就不起作用了、浏览器禁止使用cookie也会导致session保持状态信息）；使用token可以存放在cookie、local strage、内存中，所以选择相对较多，可以在很多情况使用token。
- 时间层面上：session-cookie的sessionid实在登陆的时候生成的而且在登出事时一直不变的，在一定程度上安全就会低，而token是可以在一段时间内动态改变的（服务端改变验证规则等使token改变）。 

### 5.3 方式选择

token自校验这种方式更适用于开放平台，类似微信这种，在token中加入信息去校验调用者是否符合要求，同时权限范围也在token中有指定。

查表校验更适用于指定的服务/app，有token/sessionId就可以执行此用户的所有操作。