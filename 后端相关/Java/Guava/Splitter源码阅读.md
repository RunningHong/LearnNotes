# Splitter源码阅读

## 1 类说明

Ints是原始类型的int类型的实用工具类。不能用作对象或者类型参数，而是以静态方法的形式提供一些实用的工具。

### 1.1 类签名

```java
public final class Splitter
```

类Splitter被final修饰不能被继承，不能拥有自己的子类

### 1.2 成员变量

```java
    private final CharMatcher trimmer;
    private final boolean omitEmptyStrings;
    private final Splitter.Strategy strategy;
    private final int limit;
```

