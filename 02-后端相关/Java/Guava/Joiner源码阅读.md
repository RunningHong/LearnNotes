# Joiner源码阅读

Joiner主要是对传入的元素进行合并，可以在合并中添加分隔符，还可以对一些null进行操作。

## 1 成员变量

```java
// 表示分隔符，在进行合并字符串的时候，字符间添加的分隔符
private final String separator;
```

## 2 构造函数

```java
private Joiner(String separator) {
        this.separator = (String)Preconditions.checkNotNull(separator);
    }
```

Joiner的构造函数被private修饰，不想被外部实例化,主要功能是对成员变量separator进行赋值操作。

## 3 on()

在Joiner类中是通过on方法对构造方法进行调用：

```java
public static Joiner on(String separator) {
        return new Joiner(separator);
    }

    public static Joiner on(char separator) {
        return new Joiner(String.valueOf(separator));
    }
```

on方法将传入的字符或者字符串转化为分隔符。

## 4 join()

```java
    public final String join(Iterable<?> parts) {
        return this.join(parts.iterator());
    }

    public final String join(Iterator<?> parts) {
        return this.appendTo(new StringBuilder(), parts).toString();
    }

    public final String join(Object[] parts) {
        return this.join((Iterable)Arrays.asList(parts));
    }

    public final String join(@Nullable Object first, @Nullable Object second, Object... rest) {
        return this.join(iterable(first, second, rest));
    }
```



join()方法最终都归结于调用join(Iterator<?> parts)从而调用appendTo方法，对字符串进行添加，即需要分隔的字符串。

## 5 appendTo()

```java
    public <A extends Appendable> A appendTo(A appendable, Iterator<?> parts) throws IOException {
        Preconditions.checkNotNull(appendable);
        if (parts.hasNext()) {
            appendable.append(this.toString(parts.next()));

            while(parts.hasNext()) {
                appendable.append(this.separator);
                appendable.append(this.toString(parts.next()));
            }
        }

        return appendable;
    }
```

appendTo()的实质其实就是对可迭代的parts进行迭代，并在迭代过程中添加相应的分割器separator，从而达到对传入的数组以及其他可迭代数据的join。

## 6 skipNulls()

```java
    public Joiner skipNulls() {
        return new Joiner(this) {
            public <A extends Appendable> A appendTo(A appendable, Iterator<?> parts) throws IOException {
                Preconditions.checkNotNull(appendable, "appendable");
                Preconditions.checkNotNull(parts, "parts");

                Object part;
                
                // 第一次遍历是为了找到第一个不为null的数据，找到后就break，因为找到了第一个不为null的数据后，后续的直选判断是否为null如果不为null就可以直接添加分隔符以及这个数据
                while(parts.hasNext()) {
                    part = parts.next();
                    if (part != null) {
                        appendable.append(Joiner.this.toString(part));
                        break;
                    }
                }
			
                // 在第一个不为空的前提下，通过遍历对后面每一个不为null的数据都添加分隔符以及该遍历数据
                while(parts.hasNext()) {
                    part = parts.next();
                    if (part != null) {
                        appendable.append(Joiner.this.separator);
                        appendable.append(Joiner.this.toString(part));
                    }
                }

                return appendable;
            }

            public Joiner useForNull(String nullText) {
                throw new UnsupportedOperationException("already specified skipNulls");
            }

            public Joiner.MapJoiner withKeyValueSeparator(String kvs) {
                throw new UnsupportedOperationException("can't use .skipNulls() with maps");
            }
        };
    }
```

skipNulls()主要功能就是跳过为空的内容。

**核心**：在这里面的处理主要使用的是两个循环，第一个循环是找到第一个不为null的数据，第二循环是对后续不为null的数据都添加分隔符以及数据。

## 7 useForNull

```java
    public Joiner useForNull(final String nullText) {
        Preconditions.checkNotNull(nullText);
        return new Joiner(this) {
            CharSequence toString(@Nullable Object part) {
                return (CharSequence)(part == null ? nullText : Joiner.this.toString(part));
            }

            public Joiner useForNull(String nullTextx) {
                throw new UnsupportedOperationException("already specified useForNull");
            }

            public Joiner skipNulls() {
                throw new UnsupportedOperationException("already specified useForNull");
            }
        };
    }
```

作用：把null替换为指定的值nullTest

原理：对toString进行覆盖，这样如果值为null就可以替换为nullTest。

