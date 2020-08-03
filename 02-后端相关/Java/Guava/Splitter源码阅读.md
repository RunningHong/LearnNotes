[TOC]

# Splitter源码阅读

## 1 类说明

Splitter类用来处理分割字符串。不能用作对象或者类型参数，而是以静态方法的形式提供一些实用的工具。Splitter使用的是策略模式，通过传入不同的策略达到想要的结果。

### 1.1 类签名

```java
public final class Splitter
```

类Splitter被final修饰不能被继承，不能拥有自己的子类。

### 1.2 成员变量

```java
// 将结果集中的每个字符串前缀和后缀都去除trimmer，知道前缀或后缀没有这个字符了，字符串“中”的不用去除
// 这个用的最多的体现就是去除字符两边的空格
private final CharMatcher trimmer;

//是否移除结果集中的空集，true为移除结果集中的空集，false为不用移除结果集中的空集
private final boolean omitEmptyStrings;

//这个变量最终会返回一个所有集合类的父接口，它是贯穿着整个字符串分解的变量
private final Splitter.Strategy strategy;

//最多将字符串分为几个集合，比如limit=3, 对”a,b,c,d”字符串进行'，'分割，返回的[”a”,”b”,”c,d”] //意思为最多可以分割成3段，这个可以在链式编程的limit方法参数设置
private final int limit;
```

## 2 策略模式（strategy）体现

Splitter采用了策略模式，而且表达的很精妙。如：

```java
    public static Splitter on(final CharMatcher separatorMatcher) {
        Preconditions.checkNotNull(separatorMatcher);
        return new Splitter(new Splitter.Strategy() {
            public Splitter.SplittingIterator iterator(Splitter splitter, CharSequence toSplit) {
                return new Splitter.SplittingIterator(splitter, toSplit) {
                    int separatorStart(int start) {
                        return separatorMatcher.indexIn(this.toSplit, start);
                    }

                    int separatorEnd(int separatorPosition) {
                        return separatorPosition + 1;
                    }
                };
            }
        });
    }
```

通过静态on()方法，可以构建了一个Splitter对象，在代码中返回了一个Splitter，Splitter的初始化是通过传入一个策略【Splitter.Strategy】的实现，这是一个Splitter内部接口的实现，省去了独立编写多个的策略类，之后对接口方法iterator进行实现,iterator的实现是返回了一个 SplittingIterator对象，并对 SplittingIterator 抽象类实现 separatorStart方法和 separatorEnd方法。

## 3 策略接口

```java
private interface Strategy {
    Iterator<String> iterator(Splitter var1, CharSequence var2);
}
```

此接口中只有一个方法，返回的是一个Iterator迭代器，这里可以先联想到最终返回的集合的迭代器会与它有关系。这里实现了一个惰性迭代器，直到不得不计算的时候（调用split方法）才会去将字符串分割，即在迭代的时候才去分割字符串，无论将分隔符还是被分割的字符串加载到Splitter类中，都不会去分割，只有在迭代的时候才会真正的去分割。











