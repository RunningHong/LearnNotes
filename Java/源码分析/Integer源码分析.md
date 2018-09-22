# Integer源码分析

## 类定义

```java
public final class Integer extends Number implements Comparable<Integer>
```

从中我们可以看出Integer被final修饰是不能被继承的，Integer实现了Comparable方法但只能和Integer类型对象进行比较。

## 属性

```java
private final int value;
```

## 公共属性

```java
//值为 （－（2的31次方）） 的常量，它表示 int 类型能够表示的最小值。
public static final int   MIN_VALUE = 0x80000000;
//值为 （（2的31次方）－1） 的常量，它表示 int 类型能够表示的最大值。
public static final int   MAX_VALUE = 0x7fffffff;   
//表示基本类型 int 的 Class 实例。
public static final Class<Integer>  TYPE = (Class<Integer>) Class.getPrimitiveClass("int");
//用来以二进制补码形式表示 int 值的比特位数。
public static final int SIZE = 32;
//用来以二进制补码形式表示 int 值的字节数。1.8以后才有
public static final int BYTES = SIZE / Byte.SIZE;
```

## 方法

### 构造方法

```java
//构造一个新分配的 Integer 对象，它表示指定的 int 值。
public Integer(int value) {
    this.value = value;
}

//构造一个新分配的 Integer 对象，它表示 String 参数所指示的 int 值。
public Integer(String s) throws NumberFormatException {
    this.value = parseInt(s, 10);
}
```

从构造方法中我们可以知道，初始化一个Integer对象的时候只能创建一个十进制的整数。

### valueOf方法

```java
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)
        return IntegerCache.cache[i + (-IntegerCache.low)];
    return new Integer(i);
}
```

以上是valueOf方法的实现细节。通常情况下，IntegerCache.low=-128，IntegerCache.high=127（除非显示声明java.lang.Integer.IntegerCache.high的值），Integer中有一段静态代码块，该部分内容会在Integer类被加载的时候就执行。

```java
static {
        // high value may be configured by property
        int h = 127;
        String integerCacheHighPropValue =
            sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
        if (integerCacheHighPropValue != null) {
            try {
                int i = parseInt(integerCacheHighPropValue);
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
            } catch( NumberFormatException nfe) {
                // If the property cannot be parsed into an int, ignore it.
            }
        }
        high = h;

        cache = new Integer[(high - low) + 1];
        int j = low;
        for(int k = 0; k < cache.length; k++)
            cache[k] = new Integer(j++);

        // range [-128, 127] must be interned (JLS7 5.1.7)
        assert IntegerCache.high >= 127;
    }
```

也就是说，当Integer被加载时，就新建了-128到127的所有数字并存放在Integer数组cache中。

再回到valueOf代码，可以得出结论。**当调用valueOf方法（包括后面会提到的重载的参数类型包含String的valueOf方法）时，如果参数的值在-127到128之间，则直接从缓存中返回一个已经存在的对象。如果参数的值不在这个范围内，则new一个Integer对象返回。**

所以，当把一个int变量转成Integer的时候（或者新建一个Integer的时候），建议使用valueOf方法来代替构造函数。或者直接使用`Integer i = 100;`编译器会转成`Integer s = Integer.valueOf(10000);`

### decode方法

```java
public static Integer decode(String nm) throws NumberFormatException
```

该方法的作用是将 String 解码为 Integer。接受十进制、十六进制和八进制数字。

### 方法总结

如果只需要返回一个基本类型，而不需要一个对象，可以直接使用`Integert.parseInt("123");`

如果需要一个对象，那么建议使用`valueOf()`,因为该方法可以借助缓存带来的好处。

如果和进制有关，那么就是用`decode`方法。

如果是从系统配置中取值，那么就是用`getInteger`