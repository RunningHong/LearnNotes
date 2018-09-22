# String源码分析

String表示字符串，Java中所有字符串的字面值都是String类的实例，例如“ABC”。**字符串是常量，在定义之后不能被改变，字符串缓冲区支持可变的字符串。因为 String 对象是不可变的，所以可以共享它们。**



 **Java语言提供了对字符串连接运算符的特别支持（+）**，该符号也可用于将其他类型转换成字符串。

字符串的连接实际上是通过`StringBuffer`或者`StringBuilder`的`append()`方法来实现的，字符串的转换通过`toString`方法实现，该方法由 Object 类定义，并可被 Java 中的所有类继承。



## 定义

```Java
public final class String implements java.io.Serializable, Comparable<String>, CharSequence 
```

在这里我们可以看出String是final类型的，所以final是不可以被继承的，同时该类实现了`java.io.Serializable`、 `Comparable<String>`、 `CharSequence`接口。



## 属性

```java
private final char value[];
```

String的底层存储结构就是char[]，并且被声明为final，所以String中的内容一旦被初始化是不可以修改的，但是我们都知道，String str = "aaa";str = "bbb",这是可以的，其实这样没有修改str指向指针的值而是把新的对象赋给了它。



## 构造方法

### 使用字符数组构造String

```java
    public String(char value[]) {
        this.value = Arrays.copyOf(value, value.length);
    }
```

在构造方法中，String是把value数组通过Arrays.copyOf方法直接拷贝到了一个新数组，并把值返回给value属性；

### 使用字节数组构造String

在Java中，String实例中保存有一个`char[]`字符数组，`char[]`字符数组是以unicode码来存储的，String 和 char 为内存形式，byte是网络传输或存储的序列化形式。所以在很多传输和存储的过程中需要将byte[]数组和String进行相互转化。所以，String提供了一系列重载的构造方法来将一个字符数组转化成String，提到byte[]和String之间的相互转换就不得不关注编码问题。**String(byte[] bytes, Charset charset)是指通过charset来解码指定的byte数组，将其解码成unicode的char[]数组，构造成新的String。**

## 方法

### equals方法

```java
    public boolean equals(Object anObject) {
        if (this == anObject) {
            return true;
        }
        if (anObject instanceof String) {
            String anotherString = (String) anObject;
            int n = value.length;
            if (n == anotherString.value.length) {
                char v1[] = value;
                char v2[] = anotherString.value;
                int i = 0;
                while (n-- != 0) {
                    if (v1[i] != v2[i])
                            return false;
                    i++;
                }
                return true;
            }
        }
        return false;
    }
```

首先比较this==anObject?，之后判断instanceof String，之后再判断长度是否相等，最后在一个一个比较元素是否相等。

### hashCode方法

```java
    public int hashCode() {
        int h = hash;
        if (h == 0 && value.length > 0) {
            char val[] = value;

            for (int i = 0; i < value.length; i++) {
                h = 31 * h + val[i];
            }
            hash = h;
        }
        return h;
    }
```

在存储数据计算hash地址的时候，我们希望尽量减少有同样的hash地址，所谓“冲突”。如果使用相同hash地址的数据过多，那么这些数据所组成的hash链就更长，从而降低了查询效率！所以在选择系数的时候要选择尽量长的系数并且让乘法尽量不要溢出的系数，因为如果计算出来的hash地址越大，所谓的“冲突”就越少，查找起来效率也会提高。

### subString方法

```java
public String substring(int beginIndex) {
    if (beginIndex < 0) {
        throw new StringIndexOutOfBoundsException(beginIndex);
    }
    int subLen = value.length - beginIndex;
    if (subLen < 0) {
        throw new StringIndexOutOfBoundsException(subLen);
    }
    return (beginIndex == 0) ? this : new String(value, beginIndex, subLen);
}
```

原理其实是根据开始的下标和长度返回了一个新的String。

### intern方法

```java
    public native String intern();
```

该方法返回一个字符串对象的内部化引用。 众所周知：String类维护一个初始为空的字符串的对象池，当intern方法被调用时，如果对象池中已经包含这一个相等的字符串对象则返回对象池中的实例，否则添加字符串到对象池并返回该字符串的引用。

直接使用双引号声明出来的`String`对象会直接存储在常量池中。
如果不是用双引号声明的`String`对象，可以使用`String`提供的`intern`方法。`intern` 方法会从字符串常量池中查询当前字符串是否存在，若不存在就会将当前字符串放入常量池中



## String对‘+’的重载

底层原理：使用StringBuilder以及其append方法和toString方法。



如：

```java 
String str = "aaa" + "bbb";
```

底层原理：

```java 
String str = (new StringBuilder("aaa")).append("bbb").toString();
```





## String为什么要被设计为不可变

### 字符串池

字符串池是方法区中的一部分特殊存储。当一个字符串被被创建的时候，首先会去这个字符串池中查找，如果找到，直接返回对该字符串的引用。
如果字符串可变的话，**当两个引用指向指向同一个字符串时，对其中一个做修改就会影响另外一个。**

### 缓存Hashcode

Java中经常会用到字符串的哈希码（hashcode）。例如，在HashMap中，**字符串的不可变能保证其hashcode永远保持一致**，这样就可以避免一些不必要的麻烦。这也就意味着每次在使用一个字符串的hashcode的时候不用重新计算一次，这样更加高效。

### 安全性

String被广泛的使用在其他Java类中充当参数。比如网络连接、打开文件等操作。如果字符串可变，那么类似操作可能导致安全问题。因为某个方法在调用连接操作的时候，他认为会连接到某台机器，但是实际上并没有（其他引用同一String对象的值修改会导致该连接中的字符串内容被修改）。可变的字符串也可能导致反射的安全问题，因为他的参数也是字符串。

### 不可变对象是天生的线程安全对象

因为不可变对象不能被改变，所以他们可以自由地在多个线程之间共享。不需要任何同步处理。

总之，`String`被设计成不可变的主要目的是为了安全和高效。所以，使`String`是一个不可变类是一个很好的设计。

