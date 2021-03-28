[toc]

# Lambda表达式&方法引用

## 1 Lambda

### 1.1 简介

Lambda 表达式，也可称为闭包，它是推动 Java 8 发布的最重要新特性。

Lambda 允许把函数作为一个方法的参数（函数作为参数传递进方法中）。

使用 Lambda 表达式可以使代码变的更加简洁紧凑。

只有函数式接口可以使用Lambda表达式 。

### 1.2 语法

lambda 表达式的语法格式如下：

```java
(parameters) -> expression 
或 
(parameters) ->{ statements; }
```

以下是lambda表达式的重要特征:

- **可选类型声明：**不需要声明参数类型，编译器可以统一识别参数值。
- **可选的参数圆括号：**一个参数无需定义圆括号，但多个参数需要定义圆括号。
- **可选的大括号：**如果主体包含了一个语句，就不需要使用大括号。
- **可选的返回关键字：**如果主体只有一个表达式返回值则编译器会自动返回值，大括号需要指定明表达式返回了一个数值。

### 1.3 Lambda 表达式实例

```java
// 1. 不需要参数,返回值为 5  
() -> 5  
  
// 2. 接收一个参数(数字类型),返回其2倍的值  
x -> 2 * x  
  
// 3. 接受2个参数(数字),并返回他们的差值  
(x, y) -> x – y  
  
// 4. 接收2个int型整数,返回他们的和  
(int x, int y) -> x + y  
  
// 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)  
(String s) -> System.out.print(s)
```

```java
public class Java8Tester {
   interface MathOperation {
      int operation(int a, int b);
   }
    
   interface GreetingService {
      void sayMessage(String message);
   }
    
   private int operate(int a, int b, MathOperation mathOperation){
      return mathOperation.operation(a, b);
   }
    
    
    
   public static void main(String args[]){
      Java8Tester tester = new Java8Tester();
        
      // 类型声明
      MathOperation addition = (int a, int b) -> a + b;
        
      // 不用类型声明
      MathOperation subtraction = (a, b) -> a - b;
        
      // 大括号中的返回语句
      MathOperation multiplication = (int a, int b) -> { return a * b; };
        
      // 没有大括号及返回语句
      MathOperation division = (int a, int b) -> a / b;
        
      System.out.println("10 + 5 = " + tester.operate(10, 5, addition));
      System.out.println("10 - 5 = " + tester.operate(10, 5, subtraction));
      System.out.println("10 x 5 = " + tester.operate(10, 5, multiplication));
      System.out.println("10 / 5 = " + tester.operate(10, 5, division));
        
      // 不用括号
      GreetingService greetService1 = message ->
      System.out.println("Hello " + message);
        
      // 用括号
      GreetingService greetService2 = (message) ->
      System.out.println("Hello " + message);
        
      greetService1.sayMessage("Runoob");
      greetService2.sayMessage("Google");
   }
    
}
```

### 1.4 变量作用域

尽量不要使用局部变量，如果使用局部变量，那得把局部变量设置为final的。

原因就是局部变量是存放在栈中的，存放在栈中的变量只能被读取，不能被改变，这类似于Java中的final限定符，为了在编译的时候可以检查出来这个错误，我们应该在lambda表达式使用到局部变量的地方将局部变量使用final进行限制。

对于实例变量的使用，我们可以正常使用，因为实例变量存放于内存的堆中，堆中的变量是可以被读取和改变的。这类似于Java中将对象引用作为参数传递到一个方法中的用法。

```java

public void test() {
 	
    for( int i=0; i<10; i ++) {
        final int finalVal = i; // 必须声明为final，才能在下面使用
        new Thread(()->{
            System.out.println("print this value:" + finalVal)
        }).start();
    }
    
}
```

## 2 方法引用

 方法引用我们可以把它看做是 仅仅调用特定方法的Lambda的一种快捷写法。  实例如下： 

```java
(Apple a) -> a.getWeight()			 			 Apple::getWeight
() -> Thread.currentThread().dumpStack()		 Thread.currentThread()::dumpStack
(str, i) -> str.substring(i) 					 String::substring
(String s) -> System.out.println(s) 			 System.out::println
```

 方法引用可以分为三类： 

1.  指向静态方法 

    - ```java
        (args) -> ClassName.staticMethod(args)
        //可以写成
        ClassName::staticMethod
        ```

2.  指向实例对象的任意方法(arg0是ClassName类型的) 

    - ```java
        (arg0, rest) -> arg0.instanceMethod(rest)
        //可以写成
        ClassName::instanceMethod
        ```

3.  指向实例对象的属性的方法引用 

    - ```
        (args) -> expr.instanceMethod(args)
        //可以写成
        expr::instanceMethod
        ```

 下面是几个构造函数的例子，某些情况下，使用构造函数引用可以让代码简洁： 

```java
//不带参数的构造函数
Supplier<Apple> c1 = () -> new Apple();
Apple a1 = c1.get();
//等价于
Supplier<Apple> c1 = Apple::new;
Apple a1 = c1.get();




//带参数的构造函数
Function<Integer, Apple> c2 = (weight) -> new Apple(weight);
Apple a2 = c2.apply(110);
//等价于
Function<Integer, Apple> c2 = Apple::new;
Apple a2 = c2.apply(110);


//带有两个参数的构造函数
BiFunction<String, Integer, Apple> c3 =(color, weight) -> new Apple(color, weight);
Apple c3 = c3.apply("green", 110);
//等价于
iFunction<String, Integer, Apple> c3 = Apple::new;
Apple c3 = c3.apply("green", 110);


//不将构造函数实例化，但可以引用它，这有一些有趣的应用，如下：
static Map<String, Function<Integer, Fruit>> map = new HashMap<>();
static {
	map.put("apple", Apple::new);
	map.put("orange", Orange::new);
	// etc...
}
//利用构造函数引用，新创建了一个方法，用两个参数可以得到具有制定重量的不同水果
public static Fruit giveMeFruit(String fruit, Integer weight){
	return map.get(fruit.toLowerCase())
			  .apply(weight);
}
```

## ps-相关引用

[菜鸟教程-Lambda表达式](https://www.runoob.com/java/java8-lambda-expressions.html)

[https://blog.csdn.net/a13935302660/article/details/96437703](https://blog.csdn.net/a13935302660/article/details/96437703)