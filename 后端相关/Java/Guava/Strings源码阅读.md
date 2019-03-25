[TOC]

# Strings源码阅读

## 1 类声明

### 1.1 类签名

```java
public final class Strings
```

类Strings被final修饰不能被继承，不能拥有自己的子类。所有方法都被static修饰，类当工具类使用。

## 2 方法

### 2.1 nullToEmpty 方法

```java
public static String nullToEmpty(@Nullable String string) {
        return string == null ? "" : string;
    }
```

作用：如果值为null则返回空串，如果不会null则则返回本身。

### 2.2 emptyToNull 方法

```java
public static String emptyToNull(@Nullable String string) {
        return isNullOrEmpty(string) ? null : string;
    }
```

作用：如果string为空串或者null返回null，否则返回string。

### 2.3 padStart 方法

```java
    public static String padStart(String string, int minLength, char padChar) {
        Preconditions.checkNotNull(string);
        if (string.length() >= minLength) {
            return string;
        } else {
            StringBuilder sb = new StringBuilder(minLength);

            for(int i = string.length(); i < minLength; ++i) {
                sb.append(padChar);
            }

            sb.append(string);
            return sb.toString();
        }
    }
```

作用：给定指定长度minLength，如果string的长度比minLength，则在string前添加若干padChar，使string长度为minLength.

如：

```java
padStart("7", 3, '0');   returns {"007"}
padStart("2010", 3, '0');  returns {"2010"}
```

### 2.4 padEnd 方法

```java
    public static String padEnd(String string, int minLength, char padChar) {
        Preconditions.checkNotNull(string);
        if (string.length() >= minLength) {
            return string;
        } else {
            StringBuilder sb = new StringBuilder(minLength);
            sb.append(string);

            for(int i = string.length(); i < minLength; ++i) {
                sb.append(padChar);
            }

            return sb.toString();
        }
    }
```

作用：与padStart 类似，不过是在string前面添加padChar。

```java
padEnd ("7", 3, '0');   returns {"700"}
padEnd ("2010", 3, '0');  returns {"2010"}
```

### 2.5 repeat方法

```java
    public static String repeat(String string, int count) {
        Preconditions.checkNotNull(string);
        if (count <= 1) {
            Preconditions.checkArgument(count >= 0, "invalid count: %s", count);
            return count == 0 ? "" : string;
        } else {
            int len = string.length();
            long longSize = (long)len * (long)count;
            int size = (int)longSize;
            if ((long)size != longSize) {
                throw new ArrayIndexOutOfBoundsException("Required array size too large: " + longSize);
            } else {
                char[] array = new char[size];
                string.getChars(0, len, array, 0);

                int n;
                for(n = len; n < size - n; n <<= 1) {
                    System.arraycopy(array, 0, array, n, n);
                }

                System.arraycopy(array, 0, array, n, size - n);
                return new String(array);
            }
        }
    }
```

作用：将输入的字符串重复拼接count次。

方法对边界进行了考虑（当count*string.length>int的最大值），进行了long型转换。在循环的过程中，采用了向左以为的操作，而不是加减法，加快了运算的速度。

```java
repeat("hey", 3); returns the string {"heyheyhey"}
```

### 2.6 commonPrefix 方法

```java
    public static String commonPrefix(CharSequence a, CharSequence b) {
        Preconditions.checkNotNull(a);
        Preconditions.checkNotNull(b);
        int maxPrefixLength = Math.min(a.length(), b.length());

        int p;
        for(p = 0; p < maxPrefixLength && a.charAt(p) == b.charAt(p); ++p) {
        }

        if (validSurrogatePairAt(a, p - 1) || validSurrogatePairAt(b, p - 1)) {
            --p;
        }

        return a.subSequence(0, p).toString();
    }

    @VisibleForTesting
    static boolean validSurrogatePairAt(CharSequence string, int index) {
        return index >= 0 && index <= string.length() - 2 && Character.isHighSurrogate(string.charAt(index)) && Character.isLowSurrogate(string.charAt(index + 1));
    }
```

作用：求两个字符串的最长公共前缀。

```java
commonPrefix("aabbccasdf", "aabbccef"); // 返回"aabbcc";
```

### 2.7 commonSuffix 方法

```java
    public static String commonSuffix(CharSequence a, CharSequence b) {
        Preconditions.checkNotNull(a);
        Preconditions.checkNotNull(b);
        int maxSuffixLength = Math.min(a.length(), b.length());

        int s;
        for(s = 0; s < maxSuffixLength && a.charAt(a.length() - s - 1) == b.charAt(b.length() - s - 1); ++s) {
        }

        if (validSurrogatePairAt(a, a.length() - s - 1) || validSurrogatePairAt(b, b.length() - s - 1)) {
            --s;
        }

        return a.subSequence(a.length() - s, a.length()).toString();
    }

    @VisibleForTesting
    static boolean validSurrogatePairAt(CharSequence string, int index) {
        return index >= 0 && index <= string.length() - 2 && Character.isHighSurrogate(string.charAt(index)) && Character.isLowSurrogate(string.charAt(index + 1));
    }
```

作用：该方法返回两个字符串的最长公共后缀。

```java
Strings.commonSuffix("aaac", "aac"); // "aac"否则返回"" 
```

## 3 总结

在Strings中多数方法都使用了StringBuilder这个类对字符串进行添加操作而不是使用+，经过查阅，其实+，在每次循环的时候都会把字符串装维StringBuilder（即每次循环都new一个StringBuilder对象，加大了内存消耗），所以在这里直接在最开始直接new StringBuilder(),再对字符通过append进行字符的添加操作。