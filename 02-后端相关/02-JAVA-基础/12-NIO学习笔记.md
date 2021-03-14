## NIO学习笔记

摘自

[NIO 入门 - IBM]: https://www.ibm.com/developerworks/cn/education/java/j-nio/j-nio.html



[TOC]

## 1 基础介绍

NIO(new Input Ouput)是在JDK1.4引入的。

## 2 为什么要使用NIO

NIO 的创建目的是为了让 Java 程序员可以实现高速 I/O 而无需编写自定义的本机代码。NIO 将最耗时的 I/O 操作(即填充和提取缓冲区)转移回操作系统，因而可以极大地提高速度。

## 3 流与块的比较

原来的 I/O 库(在 `java.io.*`中) 与 NIO 最重要的区别是数据打包和传输的方式。正如前面提到的，原来的 I/O 以流的方式处理数据，而 NIO 以块的方式处理数据。

*面向流* 的 I/O 系统一次一个字节地处理数据。一个输入流产生一个字节的数据，一个输出流消费一个字节的数据。为流式数据创建过滤器非常容易。链接几个过滤器，以便每个过滤器只负责单个复杂处理机制的一部分，这样也是相对简单的。不利的一面是，面向流的 I/O 通常相当慢。

一个 *面向块* 的 I/O 系统以块的形式处理数据。每一个操作都在一步中产生或者消费一个数据块。按块处理数据比按(流式的)字节处理数据要快得多。但是面向块的 I/O 缺少一些面向流的 I/O 所具有的优雅性和简单性。

## 4 通道和缓冲区

`通道 `和 `缓冲区 `是 NIO 中的核心对象，几乎在每一个 I/O 操作中都要使用它们。

### 4.1 通道

#### 4.1.1 通道概述

通道是对原 I/O 包中的流的模拟。

到任何目的地(或来自任何地方)的所有数据都必须通过一个 Channel 对象。一个 Buffer 实质上是一个容器对象。发送给一个通道的所有对象都必须首先放到缓冲区中；同样地，从通道中读取的任何数据都要读到缓冲区中。

通道（`Channel`）是一个对象，可以通过它读取和写入数据。拿 NIO 与原来的 I/O 做个比较，通道就像是流。

#### 4.1.2 通道类型

通道与流的不同之处在于**通道是双向的**。而流只是在一个方向上移动(一个流必须是 `InputStream` 或者 `OutputStream` 的子类)， 而 `通道 `可以用于读、写或者同时用于读写。

### 4.2 缓冲区

#### 4.2.1 缓冲区概述

`Buffer` 是一个对象， 它包含一些要写入或者刚读出的数据。 在 NIO 中加入 `Buffer` 对象，体现了新库与原 I/O 的一个重要区别。在面向流的 I/O 中，您将数据直接写入或者将数据直接读到 `Stream` 对象中。

在 NIO 库中，所有数据都是用缓冲区处理的。在读取数据时，它是直接读到缓冲区中的。在写入数据时，它是写入到缓冲区中的。任何时候访问 NIO 中的数据，您都是将它放到缓冲区中。

**缓冲区实质上是一个数组**。通常它是一个字节数组，但是也可以使用其他种类的数组。但是一个缓冲区不 *仅仅* 是一个数组。缓冲区提供了对数据的结构化访问，而且还可以跟踪系统的读/写进程。

#### 4.2.2 缓冲区类型

最常用的缓冲区类型是 `ByteBuffer`。一个 `ByteBuffer` 可以在其底层字节数组上进行 get/set 操作(即字节的获取和设置)。

`ByteBuffer` 不是 NIO 中唯一的缓冲区类型。事实上，对于每一种基本 Java 类型都有一种缓冲区类型：

- `ByteBuffer`
- `CharBuffer`
- `ShortBuffer`
- `IntBuffer`
- `LongBuffer`
- `FloatBuffer`
- `DoubleBuffer`

每一个 `Buffer` 类都是 `Buffer` 接口的一个实例。 除了 `ByteBuffer`，每一个 Buffer 类都有完全一样的操作，只是它们所处理的数据类型不一样。因为大多数标准 I/O 操作都使用 `ByteBuffer`，所以它具有所有共享的缓冲区操作以及一些特有的操作。

## 5 NIO 中的读和写

### 5.1 读和写概述

读和写是 I/O 的基本过程。从一个通道中读取很简单：只需创建一个缓冲区，然后让通道将数据读到这个缓冲区中。写入也相当简单：创建一个缓冲区，用数据填充它，然后让通道用这些数据来执行写入操作。

### 5.2 从文件中读取

如果使用原来的 I/O，那么我们只需创建一个 `FileInputStream` 并从它那里读取。而在 NIO 中，情况稍有不同：我们首先从 `FileInputStream` 获取一个 `Channel` 对象，然后使用这个通道来读取数据。

使用NIO读取文件步骤：

1. 从 `FileInputStream` 获取 `Channel`
2. 创建 `Buffer`
3. 将数据从 `Channel` 读到 `Buffer`

```java
// 第一步：获取通道。我们从 FileInputStream 获取通道：
FileInputStream fin = new FileInputStream( "filePath" );

FileChannel fc = fin.getChannel();

// 第二步：创建缓冲区
ByteBuffer buffer = ByteBuffer.allocate( 1024 );

// 最后一步：将数据从通道读到缓冲区中
fc.read( buffer );
```

### 5.3 写入文件

在 NIO 中写入文件类似于从文件中读取。

使用NIO写入文件步骤：

1. 从 `FileOutputStream` 获取一个通道
2. 创建一个缓冲区并在其中放入一些数据
3. 最后一步是写入缓冲区中

```java 
// 首先从 FileOutputStream 获取一个通道：
FileOutputStream fout = new FileOutputStream( "filePath" );
FileChannel fcout = fout.getChannel();

// 下一步是创建一个缓冲区并在其中放入一些数据
ByteBuffer buffer = ByteBuffer.allocate( 1024 );

String message = "Some bytes";
byte[] messageBytes = message.getBytes();

for (int i = 0; i < messageBytes.length; ++i) {
	buffer.put(messageBytes[i]);
}
buffer.flip();

// 最后一步是写入缓冲区中：
fcout.write( buffer );
```

### 5.4 读写结合（copy文件）

```java
// 获取input的通道。我们从 FileInputStream 获取通道：
FileInputStream fin = new FileInputStream( "inputFilePath" );
FileChannel fcin = fin.getChannel();

// 获取output的通道
FileOutputStream fout = new FileOutputStream("outputFilePath");
FileChannel fcout = fout.getChannel();

// 创建缓冲区
ByteBuffer buffer = ByteBuffer.allocate( 1024 );

// 循环读取文件，直到文件读取完毕
while (true) {
     // 调用clear()，清空缓存空间
     buffer.clear();
    
     // 数据从通道读到管道中，返回一个值，为-1时代表文件结束
     int r = fcin.read( buffer );
 
     if (r==-1) {
       break;
     }
 
     // 调用flip(),将buffer内部的指针limit置为position的大小，position置为0，从而写文件
     buffer.flip();
     fcout.write( buffer );
}
```

## 6 缓冲区内部细节

 NIO 中两个重要的缓冲区组件：状态变量和访问方法 (accessor)。

状态变量是的"内部统计机制"的关键。每一个读/写操作都会改变缓冲区的状态。通过记录和跟踪这些变化，缓冲区就可能够内部地管理自己的资源。

在从通道读取数据时，数据被放入到缓冲区。在有些情况下，可以将这个缓冲区直接写入另一个通道，但是在一般情况下，您还需要查看数据。这是使用*访问方法* `get()` 来完成的。同样，如果要将原始数据放入缓冲区中，就要使用访问方法 `put()`。

### 6.1 状态变量

可以用三个值指定缓冲区在任意时刻的状态：

- `position`
- `limit`
- `capacity`

这三个变量一起可以跟踪缓冲区的状态和它所包含的数据。
