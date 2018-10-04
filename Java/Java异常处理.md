[TOC]

# 异常处理

## 1 异常处理的优势

异常处理最根本的优势是将检测错误（由被调用的方法完成）从处理错误（由调用方法完成）中分离出来。

## 2 异常类型

Throwable类是所有异常类的根。所有的Java异常类都直接或间接地继承自Throwable。可以通过扩展Exception或者Exception的子类来创建自己的异常类。

整体异常类可以分为三类：**系统错误**（Error），**异常**，**运行异常**

### 2.1 系统错误（Error）

系统错误（System error）是由Java虚拟机抛出的，用Error表示。Error类描述的是内部系统错误。这样的错误很少发生，一旦发生了除了终止程序外，几乎什么也做不了。

常见的系统异常：

- OutOfMemoryError
- StackOverflowError

### 2.2 异常（Exception）

用Eception类表示的，它描述的是由程序和外部环境引起的错误，这些错误能被程序捕获和处理。

常见的异常：

- ClassNotFoundException
- IOException

### 2.3 运行时异常（RuntimeException）

是用RuntimeException类表示的，它描述的是程序设计错误，例如，错误的类型转换、访问一个越界的数组或数值错误。运行时异常通常是由Java虚拟机抛出的。

常见的运行时异常：

- ArithmeticException
- NullPointerException
- IndexOutOfBoundsException

## 3 免检异常和必检异常

**RuntimeException**、**Error**以及它们的子类都称为**免检异常**（unchecked exception），所有其他的异常都成为必检异常。

免检异常是不用try-catch或者throws的但是必检异常是必须我们要处理的，想想编程的时候我们是否处理过数组越界的情况，这些都是在运行时JVM帮我们检查的。