# Enum源码分析

## 定义

```java
public abstract class Enum<E extends Enum<E>> implements Comparable<E>, Serializable
```

### 1.抽象类（但不可被继承）

首先，**抽象类不能被实例化**，所以我们**在java程序中不能使用new关键字来声明一个Enum**，如果想要定义可以使用这样的语法：

```java
enum enumName{
    value1,value2
    method1(){}
    method2(){}
}
```

其次，看到抽象类，第一印象是肯定有类继承他。至少我们应该是可以继承他的，所以：

```java
public class testEnum extends Enum{
}
public class testEnum extends Enum<Enum<E>>{
}
public class testEnum<E> extends Enum<Enum<E>>{
}
```

尝试了以上三种方式之后，得出以下结论：**Enum类无法被继承**。

为什么一个抽象类不让继承？enum定义的枚举是怎么来的？难道不是对Enum的一种继承吗？带着这些疑问我们来反编译以下代码：

```java
  enum Color {RED, BLUE, GREEN}
```

编译器将会把他转成如下内容：

```java
public final class Color extends Enum<Color> {
  public static final Color[] values() { return (Color[])$VALUES.clone(); }
  public static Color valueOf(String name) { ... }

  private Color(String s, int i) { super(s, i); }

  public static final Color RED;
  public static final Color BLUE;
  public static final Color GREEN;

  private static final Color $VALUES[];

  static {
    RED = new Color("RED", 0);
    BLUE = new Color("BLUE", 1);
    GREEN = new Color("GREEN", 2);
    $VALUES = (new Color[] { RED, BLUE, GREEN });
  }
} 
```

短短的一行代码，被编译器处理过之后竟然变得这么多，看来，enmu关键字是java提供给我们的一个语法糖啊。。。从反编译之后的代码中，我们发现，编译器不让我们继承Enum，但是当我们使用enum关键字定义一个枚举的时候，他会帮我们在编译后默认继承java.lang.Enum类，而不像其他的类一样默认继承Object类。且采用enum声明后，该类会被编译器加上final声明，故该类是无法继承的。 PS：**由于JVM类初始化是线程安全的，所以可以采用枚举类实现一个线程安全的单例模式。**

