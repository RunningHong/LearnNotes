# 1 Maven学习笔记

Maven是基于java的一个依赖控制工具，所以在使用Maven之前需要安装Java。

配置镜像，配置仓库地址在对应的settings.xml中（在c:/用户/用户名/.m2中，如：C:\Users\hong\.m2）

## 1.1 常用命令

```java
// 查看Maven的信息（Maven版本，Maven home，Java version等）
mvn -v 
    
// 创建一个名称为MyProject的项目，maven的groupId为proGroupID的项目模板
mvn archetype:generate -DgroupId=proGroupID -DartifactId=MyProject -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
    
// 构建本项目
mvn package
    
// 将target文件夹下编译产生的.class文件删除，作用是清理上一次构建生成的文件。有些类似于
// Myeclipse中Project — clean菜单。
mvn clean

// 编译整个工程，生成的.class文件存放到target目录下。
mvn compile

// 利用mvn手动导入一些jar包（比如导入测javax.transaction:jta:jar:1.0.1B,jta.jar）
mvn install:install-file -DgroupId=javax.transaction -DartifactId=jta -Dversion=1.0.1B -Dpackaging=jar -Dfile=C:/jta.jar


    
```

