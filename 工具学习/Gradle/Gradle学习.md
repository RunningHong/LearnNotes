[TOC]

# Gradle学习笔记

## 1 简介

Gralde是基于Groovy这个脚本语言，Groovy是基于JVM的。

## 2 build.gradle文件（用于模块的配置）

```groovy
// 项目的group和version，用于标识这个project
group 'com.zh.gradle'
version '1.0-SNAPSHOT'

// 在多项目构建中(在根项目配置)添加所有模块的设置
// allProjects可以填build.gradle中所有的选项(apply plugin,repositories等等)
// 这样在setting.gradle中include的子模块中就可以不用写重复的代码了
 allprojects {
     apply plugin: 'java'
     sourceCompatibility = 1.8
     ......
}


// 应用的插件（java用于打jar包，war用于web项目打war包）
// 可在Gradle-Tasks-build中找到相应的插件启动程序
apply plugin: 'java'
apply plugin: 'war'


// jdk版本（需要在apply plugin后配置）
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
    // 依赖的模块（使用’:‘ + modelName表示依赖的模块）(多项目构建中使用)
    // compile project(":modelName")
    
    // 依赖的jar包
    compile group: 'junit', name: 'junit', version: '4.12'
    compile group: 'ch.qos.logback', name: 'logback-classic', version: '1.2.3'
    
    // 依赖jar包简写模式
    compile 'org.jxls:jxls:2.4.7'
    
    // 强制使用指定版本jar（gradle的有些策略会使用最新的jar有时会引发一些问题）
    compile ('org.apache.poi:poi:3.13') { force = true }
    
    // 忽略jar的传递性
    compile("org.springframework:spring-web:4.3.4.RELEASE") { transitive = false }
}


/** *********************** 以下是Groovy语言的脚本的demo ******************* */

/**
 * 一个闭包，根据path创建目录，在makeJavaDir中使用
 * 如果没有目录结构则通过脚本添加
 */
def createDir = {
    path ->
        File dir = new File(path);
        if(!dir.exists()) {
            dir.mkdirs();
        }
}


/**
 * 自定义任务(在Gradle-Tasks-other中找到这个task)
 * 根据paths创建目录
 */
task makeJavaDir() {
    def paths = ["src/main/java",
                 "src/main/resources",
                 "src/test/java",
                 "src/test/resources"];

    doFirst {
        paths.forEach(createDir);
    }
}


/**
 * 自定义任务(在Gradle-Tasks-other中找到这个task)
 * 创建一个web目录（依赖于java项目的结构）
 */
task makeWebDir() {
    // 依赖于makeJavaDir这个task
    dependsOn 'makeJavaDir';
    def paths = ["src/main/webapp", "src/test/webapp"];

    doLast {
        paths.forEach(createDir);
    }
}

```

## 3 setting.gradle文件（用于多项目的设置）

setting.gradle用于多项目构建，管理当前的项目有哪些子项目。

这个和Maven的父子工程相似。

```groovy
// 项目名称
rootProject.name = “projectName”

// 项目包含的子模块
include '子模块1'
include "子模块2"
```















