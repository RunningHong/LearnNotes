[toc]

# NoSuchMethodException

## 1 详情报错信息&错误代码

执行mapreduce报错java.lang.Exception: java.lang.RuntimeException: java.lang.NoSuchMethodException: xxxx.<init>() 

### 1.1 具体报错如下：

```java
java.lang.Exception: java.lang.RuntimeException: java.lang.NoSuchMethodException: com.hong.hadoop.WordCountMR$WordCountMapper.<init>()
    at org.apache.hadoop.mapred.LocalJobRunner$Job.runTasks(LocalJobRunner.java:462)
    at org.apache.hadoop.mapred.LocalJobRunner$Job.run(LocalJobRunner.java:522)
Caused by: java.lang.RuntimeException: java.lang.NoSuchMethodException: com.hong.hadoop.WordCountMR$WordCountMapper.<init>()
    at org.apache.hadoop.util.ReflectionUtils.newInstance(ReflectionUtils.java:134)
    at org.apache.hadoop.mapred.MapTask.runNewMapper(MapTask.java:745)
    at org.apache.hadoop.mapred.MapTask.run(MapTask.java:341)
    at org.apache.hadoop.mapred.LocalJobRunner$Job$MapTaskRunnable.run(LocalJobRunner.java:243)
    at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
    at java.util.concurrent.FutureTask.run(FutureTask.java:266)
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
    at java.lang.Thread.run(Thread.java:748)
Caused by: java.lang.NoSuchMethodException: com.hong.hadoop.WordCountMR$WordCountMapper.<init>()
    at java.lang.Class.getConstructor0(Class.java:3082)
    at java.lang.Class.getDeclaredConstructor(Class.java:2178)
    at org.apache.hadoop.util.ReflectionUtils.newInstance(ReflectionUtils.java:128)
    ... 8 more
Job job_local1253315648_0001 running in uber mode : false
 map 0% reduce 0%
Job job_local1253315648_0001 failed with state FAILED due to: NA
Counters: 0
1

Process finished with exit code 0
```

### 1.2 我在Mapper类中的写法

```java
public class WordCountMR {

    public static void main(String[] args) throws Exception {
        // 这里运行程序
        job.setMapperClass(WordCountMapper.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
    }


    // 内部类形式未声明为static
    class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
        @Override
        protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
            String line = value.toString();
            String[] words = line.split(" ");
            for (String word : words) {
                if (!"".equals(word.trim())) {
                    context.write(new Text(word), new IntWritable(1));
                }
            }
        }
    }

}
```

## 2 上原因

具体原因：代码中Mapper为内部类，**但是没有声明为static**。

hadoop在底层是通过**反射**调用Mapper类里重写的map方法

hadoop中ReflectUtil.newInstance()源码(注意line 10这里是result = meth.newInstance();直接调用反射的newInstance方法)：

```java
  public static <T> T newInstance(Class<T> theClass, Configuration conf) {
    T result;
    try {
      Constructor<T> meth = (Constructor<T>) CONSTRUCTOR_CACHE.get(theClass);
      if (meth == null) {
        meth = theClass.getDeclaredConstructor(EMPTY_ARRAY);
        meth.setAccessible(true);
        CONSTRUCTOR_CACHE.put(theClass, meth);
      }
      result = meth.newInstance(); // 注意这里
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
    setConf(result, conf);
    return result;
  }
```

简单的写成下面的方式：

```java
// 无参构造方法
Constructor mapConstructor = cls.getDeclaredConstructor();
mapConstructor.setAccessible(true);

// 得到map方法
Method mapMethod = cls.getDeclaredMethod("map", String.class);
mapMethod.setAccessible(true);

// 注意：这里使用的newInstance()方法
Object result=mapConstructor.newInstance()

// 调用map方法
mapMethod.invoke(result);
```

对于静态内部类或者普通类，通过上面的方法不会报错，但是如果是非静态的内部类就有问题。

问题的原因在于：**非静态内部类的实例创建要依赖外部类**，所以需要先构建外部类实例再来实例化非静态内部类，就是下面的写法：

```java
// 构造方法（clazz代表外部类的类型信息）
Constructor mapConstructor = cls.getDeclaredConstructor(clazz);
mapConstructor.setAccessible(true);

// 得到map方法
Method mapMethod = cls.getDeclaredMethod("map", String.class);
mapMethod.setAccessible(true);

// outerClass是外部类构建的实例：Object outerClass=clazz.newInstance();
mapMethod.invoke(mapConstructor.newInstance(outerClass);
```

但由于

## 3 解决办法

- 如果Mapper类或者Reducer类为内部类的形式需要声明为static
- 可以把Mapper类提出去，写成非内部类的形式
- Mapper如果显示声明了一个有参构造方法，那么我们还需要手动的加上一个无参构造方法（反射构建类实例的时候通过的是**无参构造方法**进行实例的创建）

## 4 通过反射构建内部类实例扩展（静态内部类、普通内部类、匿名内部类）

```java
package com.hong.base;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

/**
 * @author hongzh.zhang on 2020/08/02
 * 反射内部类
 * 通过反射的方式构造内部类实例调用方法print
 */
public class ReflactInnerClass {

    public static void main(String[] args) {
        invokeInnerClassPrintMethod();
    }


    /**
     * 普通内部类
     * @author hongzh.zhang on 2020/8/2
     */
    private class InnerNormalClassA {
        private void print(String mes) {
            System.out.println("InnerNormalClassA print: " + mes);
        }
    }

    /**
     * 静态内部类
     * @author hongzh.zhang on 2020/8/2
     */
    private static class InnerStaticClassB {
        private void print(String mes) {
            System.out.println("InnerStaticClassB print: " + mes);
        }
    }


    /**
     * 声明一个匿名内部类
     * @author hongzh.zhang on 2020/8/2
     */
    private Runnable anonymousField = new Runnable() {
        @Override
        public void run() {
            System.out.println("匿名内部类的run方法");
        }
    };


    /**
     * 调用内部类的print方法
     * @author hongzh.zhang on 2020/8/2
     */
    public static void invokeInnerClassPrintMethod() {
        // 获取外部类的类型信息
        Class clazz = ReflactInnerClass.class;
        try {
            // 得到外部类实例
            Object outerClass=clazz.newInstance();

            // 得到声明的类信息
            Class[] declaredClasses = clazz.getDeclaredClasses();
            for (Class cls : declaredClasses) {
                // 获取类修饰符
                String modifier = Modifier.toString(cls.getModifiers());

                if (modifier.contains("static")) { // 构造静态内部类
                    // 获取静态内部类实例(如果是private构造器需要使用getDeclaredConstructor，
                    // 并通过innerStatic.setAccessible(true)设置访问权限)
                    Constructor innerStatic = cls.getDeclaredConstructor();
                    innerStatic.setAccessible(true);

                    // 得到打印方法（如果方法是private的则需要使用getDeclaredMethod，
                    // 再通过printMethod.setAccessible(true);设置访问权限）
                    Method printMethod = cls.getDeclaredMethod("print", String.class);
                    printMethod.setAccessible(true);

                    // 调用方法进行打印
                    printMethod.invoke(innerStatic.newInstance(), "I am inner static class");
                } else { // 构造非静态内部类
                    // 注意：这里是通过cls.getDeclaredConstructor(clazz);来获得实例的
                    // 非静态内部类的实例创建需要依赖外部类，所以这里把外部类的类型信息传入进行构造
                    Constructor innerNormal = cls.getDeclaredConstructor(clazz);
                    innerNormal.setAccessible(true);

                    Method printMethod = cls.getDeclaredMethod("print", String.class);
                    printMethod.setAccessible(true);

                    // 注意：这里方法调用的时候传入的第一个参数问innerNormal.newInstance(outterClassInstance)
                    // 非静态内部类的实例创建需要依赖外部类，所以这里把外部类的类型信息传入进行构造
                    printMethod.invoke(innerNormal.newInstance(outerClass), "I am inner normal class");
                }
            }

            // 匿名内部类相当于一个参数值
            Field field = clazz.getDeclaredField("anonymousField");
            field.setAccessible(true);
            Runnable anonymousField = (Runnable) field.get(outerClass);
            anonymousField.run();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }


}
```

输出：

```
InnerStaticClassB print: I am inner static class
InnerNormalClassA print: I am inner normal class
匿名内部类的run方法
```

