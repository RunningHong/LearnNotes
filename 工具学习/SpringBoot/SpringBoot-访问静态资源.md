# 静态资源访问

spring boot项目只有src目录，没有webapp目录，会将静态访问(html/图片等)映射到其自动配置的静态目录：

- /static
- /public
- /resources
- /META-INF/resources



比如，在resources建立一个static目录和index.htm静态文件，访问地址 <http://localhost:8080/index.html> 

如果要从后台跳转到静态index.html，代码如下。

```java
@Controller
public class HtmlController {
	@GetMapping("/html")
	public String html() {
		return "/index.html";
}
```

