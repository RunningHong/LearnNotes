[TOC]

# Ints类

## 1 类说明

Ints是原始类型的int类型的实用工具类。不能用作对象或者类型参数，而是以静态方法的形式提供一些实用的工具。

### 1.1 类签名

```java
public final class Ints
```

类Ints被final修饰不能被继承，不能拥有自己的子类

### 1.2 成员变量

```java
public static final int BYTES = 4;
public static final int MAX_POWER_OF_TWO = 1073741824;
```

Ints的成员变量都是静态成员变量，并且被final修饰。

## 2 方法

### 2.1 构造方法

```java
private Ints() { }
```

Ints的构造方法被private修饰，所以不能通过~~new Ints()~~的方式创建对象。

### 2.2 toByteArray

```java
public static byte[] toByteArray(int value) {
        return new byte[]{(byte)(value >> 24), (byte)(value >> 16), (byte)(value >> 8), (byte)value};
}
```

**作用：**将传入的int值转化为byte数组。

toByteArray方法返回的byte[]长度为4，元素分别是对将value右移24、右移16位、右移8位以及右移4位。

### 2.3 fromByteArray

```java
    public static int fromByteArray(byte[] bytes) {
        Preconditions.checkArgument(bytes.length >= 4, "array too small: %s < %s", bytes.length, 4);
        return fromBytes(bytes[0], bytes[1], bytes[2], bytes[3]);
}

    public static int fromBytes(byte b1, byte b2, byte b3, byte b4) {
        return b1 << 24 | (b2 & 255) << 16 | (b3 & 255) << 8 | b4 & 255;
    }
```

**作用：**将byte[]数组转化为一个int值。

方法首先使用前置条件Preconditions对byte[]数组的长度进行了检测（不能大于4），之后调用fromBytes方法将byte[]数组装换位int值。

frombyteArray与toByteArray作用互为相反。

### 2.4 join

```java
    public static String join(String separator, int... array) {
        Preconditions.checkNotNull(separator);
        if (array.length == 0) {
            return "";
        } else {
            StringBuilder builder = new StringBuilder(array.length * 5);
            builder.append(array[0]);

            for(int i = 1; i < array.length; ++i) {
                builder.append(separator).append(array[i]);
            }

            return builder.toString();
        }
    }
```

**作用：**对传入的int值使用分离器进行分离并返回字符串形式。

```java
String temp = Ints.join("|", 1,2,3,4);
// 返回1|2|3|4
```

**思想：**主要对可边长参数array进行遍历，在每个数字中间通过append方法添加分隔符。

### 2.5 asList

```java
    public static List<Integer> asList(int... backingArray) {
        return (List)(backingArray.length == 0 ? Collections.emptyList() : new Ints.IntArrayAsList(backingArray));
    }
```

**作用：**将传入的多个int值（可变长参数backingArray）转换为LIst的形式。

**思想：**使用了一个Ints的内部类IntArrayAsList（继承抽象类AbstractList）实现功能。

### 2.6 LexicographicalComparator

```java
    private static enum LexicographicalComparator implements Comparator<int[]> {
        INSTANCE;

        private LexicographicalComparator() {
        }

        public int compare(int[] left, int[] right) {
            int minLength = Math.min(left.length, right.length);

            for(int i = 0; i < minLength; ++i) {
                int result = Ints.compare(left[i], right[i]);
                if (result != 0) {
                    return result;
                }
            }

            return left.length - right.length;
        }

        public String toString() {
            return "Ints.lexicographicalComparator()";
        }
    }
```





