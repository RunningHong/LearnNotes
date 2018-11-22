[TOC]

# SpringBoot基础&踩坑

## 1 基础介绍

SpringBoot是一个约定优于配置的框架

SpringBoot 是基于Spring Framework构建的。

SpringBoot 2.0 依赖JDK8+（原因：Spring Framework 5.0.x需要依赖JDK8+）。

SpringBoot底层有kotlin参与。

Web Flux



## 2 踩坑

SpringBoot是一个约定优于配置的框架，在很多时候大大的减少我们的工作，但有些东西如果不知道，则会出现一些不可预料的错误。

### 2.1 启动类踩坑

启动类使用`@SpringBootApplication`标识，并且启动类放到**根目录（src.main.java）**下（spring boot默认会扫描启动类同包以及各子包的注解），如果没有放到根目录下面可能会出现以下问题：

- 使用 `@Autowired ` 注解时则会出现，could not autowired no bean have been found错误。

- 可能出现某些请求路径出现404无法访问的情况。

**解决方法**：把启动类放到src目录下，使之扫描所有的文件。

### 2.2 指定自动扫描包目录路径

在开发中我们知道spring boot默认会扫描启动类同包以及子包下的注解，那么如何改变这种扫描包的方式呢。

**解决方法**：`@ComponentScan`注解进行指定要扫描的包以及要扫描的类**启动类**加入：

```java
@ComponentScan(basePackages{"com.zh.controller","com.zh.service","需要扫描的路径..."})
```

### 2.3 IDEA出现Could not autowire. No beans of 'xxxx' type found的错误提示

**解决方法见**：https://blog.csdn.net/viqqw/article/details/79421826