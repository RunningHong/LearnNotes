[TOC]

# Maven学习笔记

Maven是基于java的一个依赖控制工具，所以在使用Maven之前需要安装Java。

配置镜像，配置仓库地址在对应的settings.xml中（在c:/用户/用户名/.m2中，如：C:\Users\hong\.m2）

## 1 命令

### 1.1 常用命令

| 指令                | 说明                                                         |
| ------------------- | ------------------------------------------------------------ |
| mvn -v              | 查看Maven的信息（Maven版本，Maven home，Java version等）。   |
| mvn package         | 构建本项目。                                                 |
| mvn clean           | 删除target文件夹下编译产生的.class文件，作用是清理上一次构建生成的文件。 |
| mvn compile         | 编译整个工程，生成的.class文件存放到target目录下。           |
| mvn install         | 把自己打好的包，放入本地仓库，共别人使用。                   |
| mvn test            | 测试。                                                       |
| mvn dependency:tree | 显示依赖树                                                   |
| mvn dependency:list | 显示依赖列表                                                 |
|                     |                                                              |

### 1.2 长命令

```shell
// 创建一个名称为MyProject的项目，maven的groupId为proGroupID的项目模板（java项目）
// -DgroupId : 项目的groupId
// -DartifactId : 项目的artifactId
// -DarchetypeArtifactId : 一个maven快速构建的ArtifactId
// -DinteractiveMode : 设置是否使用询问模式
mvn archetype:generate -DgroupId="proGroupID" -DartifactId="MyProject" -DarchetypeArtifactId="maven-archetype-quickstart" -DinteractiveMode=false

    
// 利用mvn手动导入一些jar包（比如导入测javax.transaction:jta:jar:1.0.1B,jta.jar）
mvn install:install-file -DgroupId=javax.transaction -DartifactId=jta -Dversion=1.0.1B -Dpackaging=jar -Dfile=C:/jta.jar
```

## 2 依赖冲突

假设有这种情况，A依赖B，B又依赖了C1，并且D依赖了C2（注：C1、C2是一个jar包只是版本不同），如果我们有个新项目E需要引入A又需要引入D，那么此时C1、C2就会依赖冲突。

通过exclusion可以消除依赖冲突。