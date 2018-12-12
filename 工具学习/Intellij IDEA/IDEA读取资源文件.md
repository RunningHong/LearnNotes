# IDEA读取resource文件

前提：当前类为FileUtil，读取resources的picture目录下的ddd.txt文件。

```java
InputStream is = FileUtil.class.getClassLoader().getResourceAsStream("picture/ddd.txt");

// 也可使用这种格式读取
InputStream is = ClassLoader.getSystemResourceAsStream("picture/ddd.txt");
```

注：**picture** 为**resources** 的第一层目录。

![](https://github.com/RunningHong/LearnNotes/blob/master/picture/ideaResource.png?raw=true)