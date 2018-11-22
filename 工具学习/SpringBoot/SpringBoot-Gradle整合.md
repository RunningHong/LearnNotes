[TOC]

# SpringBoot-Gradle整合

## 1 build.gradle文件

```groovy
group 'com.zh.springboot'
version '1.0-SNAPSHOT'

// 应用的插件（java用于打jar包，war用于web项目打war包）
// 可在Gradle-Tasks-build中找到相应的插件启动程序
apply plugin: 'java'
apply plugin: 'war'

//声明java源码的版本
sourceCompatibility = 1.8


// 使用阿里云服务器进行仓库管理
repositories {
    // 先从url中下载jar若没有找到，则在artifactUrls中寻找
    maven {
        url "http://maven.aliyun.com/nexus/content/groups/public/"
        artifactUrls "http://central.maven.org/maven2/"
    }
}


// 依赖管理
dependencies {
    // 依赖的jar包
    compile group: 'junit', name: 'junit', version: '4.12'
    compile group: 'ch.qos.logback', name: 'logback-classic', version: '1.2.3'

    // springboot依赖的jar包
    //使用 Controller 的时候需要引入 web 包
    compile group: 'org.springframework.boot', name: 'spring-boot-starter-web', version: '2.0.4.RELEASE'
    // 热部署需要使用devtools
    compile group: 'org.springframework.boot', name: 'spring-boot-devtools', version: '2.0.4.RELEASE'
}
```

## 2  启动类

```java
package com.zh.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

启动类使用`@SpringBootApplication`标识，并且启动类放到**根目录（src.main.java）**下（spring boot默认会扫描启动类同包以及各子包的注解）

## 3 一个Controller类

```java
package com.zh.springboot.controller;

import com.zh.springboot.demo.User;
import com.zh.springboot.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping( value = "/say")
public class UserController {
    Logger log = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserRepository userRepository;

    @RequestMapping(path = "/sayYes")
    public String sayYes() {
        return "Yes, hahahah";
    }

    @RequestMapping(path = "/sayNo")
    public String sayHello2() {
        return "No, No，No";
    }
}
```

Controller使用`@RestController` 标识该Controller返回格式为JSON，使用 `@RequestMapping( value = "/say")`标识请求内部方法时，请求路径需要加上 `/say` 。

## 4 配置文件（内置tomcat, mybatis...）

配置文件`application.properties` 放在`src.resources` 目录下，主要对内置的tomcat，mybatis等进行配置。

```properties
############################# tomcat相关配置 #############################
# 【常用】服务端口配置
server.port=8080
# 【常用】项目contextPath，一般在正式发布版本中使用(项目访问时要加的path)
server.context-path=/springbootLearn
# 【常用】tomcat的URI编码
server.tomcat.uri-encoding=UTF-8
# 配置项目的名称(可有可无，主要在日志中显示)
spring.application.name=SpringBoot-Learning
# 错误页，指定发生错误时，跳转的URL。请查看BasicErrorController源码便知
server.error.path=/error
# session最大超时时间(分钟)，默认为30
server.session-timeout=60
############################### 数据库配置 ###############################
#spring.datasource.driver-class-name = com.mysql.jdbc.Driver
#spring.datasource.url = jdbc:mysql://localhost:3306/xxx
#spring.datasource.username = root
#spring.datasource.password = root
#spring.datasource.testOnBorrow = true
#spring.datasource.testWhileIdle = true
#spring.datasource.timeBetweenEvictionRunsMillis = 60000
#spring.datasource.minEvictableIdleTimeMillis = 30000
#spring.datasource.validationQuery = SELECT 1
#spring.datasource.max-active = 15
#spring.datasource.max-idle = 10
#spring.datasource.max-wait = 8000
############################ Mybatis相关配置 ##############################
#配置文件位置
#mybatis.config-location=classpath:mybatis-config.xml
##mapper文件位置
#mybatis.mapper-locations=classpath:mappers/**/*.xml
##配置模型路径
#mybatis.type-aliases-package=com/cvface/model
```



