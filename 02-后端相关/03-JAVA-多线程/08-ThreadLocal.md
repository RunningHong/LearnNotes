[toc]

# ThreadLocal

## 1 ThreadLocal 简介

ThreadLocal是解决线程安全问题一个很好的思路，它通过为每个线程提供一个独立的变量副本解决了变量并发访问的冲突问题。在很多情况下，ThreadLocal比直接使用synchronized同步机制解决线程安全问题更简单，更方便，且结果程序拥有更高的并发性。

在Java的多线程编程中，为保证多个线程对共享变量的安全访问，通常会使用synchronized来保证同一时刻只有一个线程对共享变量进行操作。这种情况下可以将[类变量](https://links.jianshu.com/go?to=https%3A%2F%2Fbaike.baidu.com%2Fitem%2F%E7%B1%BB%E5%8F%98%E9%87%8F)放到ThreadLocal类型的对象中，使变量在每个线程中都有独立拷贝，不会出现一个线程读取变量时而被另一个线程修改的现象。

ThreadLocal并不是一个Thread，而是Thread的局部变量，也许把它命名为ThreadLocalVariable更容易让人理解一些。

## 2 应用场景

最常见的ThreadLocal使用场景为用来解决数据库连接、Session管理等。

一个线程拥有一个数据库连接，这是后这个连接就可以通过ThreadLocal来管理。

## 3 分析

### 3.1 ThreadLocal中的重点方法

```java
public class ThreadLocal<T> {
    
    // 获取当前线程的ThreadLocalMap，然后往map里添加KV，K是当前ThreadLocal实例，V是我们传入的value
	public void set(T value) {
		//这一步是取得当前线程
	    Thread t = Thread.currentThread();
	    //获取到一个ThreadLocalMap对象
	    ThreadLocalMap map = getMap(t);
	    //获取到map如果是null就创建并赋值
	    if (map != null)
	    	//map中的键为线程对象，值为变量副本
	        map.set(this, value);
	    else
	        createMap(t, value);
	}
    
    // 获取当前线程的私有变量，即ThreadLocalMap实例；
    // 如果不为空，以当前ThreadLocal实例为key获取value；
    // 如果ThreadLocalMap为空或者根据当前ThreadLocal实例获取的value为空，则执行setInitialValue()；
    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null)
                return (T)e.value;
        }
        // 设置初始化值
        return setInitialValue();
    }
    
    private T setInitialValue() {
        T value = initialValue();
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
        return value;
    }
    
	void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
    
	ThreadLocalMap getMap(Thread t) {
		//这个返回的是Thread的成员变量threadLocals
	    return t.threadLocals;
	}
    
	//这个ThreadLocalMap 是个内部类
	static class ThreadLocalMap {
		//Entry继承自WeakReference将ThreadLocal作为弱引用，GC运行, ThreadLocal即被回收
		static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
	}
}



// 单独说明下Thread类中的threadLocals变量
public class Thread implements Runnable {
	// Thread类中的threadLocals实际上就是ThreadLocalMap，并且ThreadLocalMap是ThreadLocal的内部类
	ThreadLocal.ThreadLocalMap threadLocals = null;
}
```

### 3.2 分析说明

- 每个线程是一个Thread实例，其内部维护一个threadLocals的实例成员，其类型是ThreadLocal.ThreadLocalMap。
- 通过实例化ThreadLocal实例，我们可以对当前运行的线程设置一些线程私有的变量，通过调用ThreadLocal的set和get方法存取。
- ThreadLocal本身并不是一个容器，我们存取的value实际上存储在ThreadLocalMap中，ThreadLocal只是作为TheadLocalMap的key。
- 每个线程实例都对应一个TheadLocalMap实例，我们可以在同一个线程里实例化很多个ThreadLocal来存储很多种类型的值，这些ThreadLocal实例分别作为key，对应各自的value，最终存储在Entry table数组中。
- 当调用ThreadLocal的set/get进行赋值/取值操作时，首先获取当前线程的ThreadLocalMap实例，然后就像操作一个普通的map一样，进行put和get。

![image-20210323094843986](picture/image-20210323094843986.png)

图中左边是栈，右边是堆。线程的一些局部变量和引用使用的内存属于Stack（栈）区，而普通的对象是存储在Heap（堆）区。

1. 线程运行时，我们定义的TheadLocal对象被初始化，存储在Heap(ThreadLocal对象)，同时线程运行的栈区保存了指向该实例的引用(即图中的ThreadLocal ref)。
2. 当ThreadLocal的set/get被调用时，虚拟机会根据当前线程的引用也就是CurrentThreadRef找到其对应在堆区的实例，然后查看其对用的TheadLocalMap实例是否被创建，如果没有，则创建并初始化。
3. Map实例化之后，也就拿到了该ThreadLocalMap的句柄(即图中的threadLocals成员变量ref)，那么就可以将当前ThreadLocal对象作为key，进行存取操作。
4. ThreadLocalMap中的Entity是一个map结构的数据，key指向的是ThreadLocal对象实例（弱引用），value指向的是ThreadLocal真实存储的值。

### 3.3 为什么ThreadLocalMap的key会使用弱引用呢？

ThreadLocalMap的key是一个弱引用类型，源代码如下：

```java
static class ThreadLocalMap {
    // 定义一个Entry类，key是一个弱引用的ThreadLocal对象
    // value是任意对象
    static class Entry extends WeakReference<ThreadLocal<?>> {
        /** The value associated with this ThreadLocal. */
        Object value;
        Entry(ThreadLocal<?> k, Object v) {
            super(k);
            value = v;
        }
    }
    // 省略其他
}
```

**弱引用：回收就会死亡**：被弱引用关联的对象实例只能生存到下一次垃圾收集发生之前。当垃圾收集器工作时，无论当前内存是否足够，都会回收掉只被弱引用关联的对象实例。在JDK 1.2之后，提供了WeakReference类来实现弱引用。

为什么ThreadLocalMap的key会使用弱引用呢，这是因为：
当引用ThreadLocal的对象被回收时（如上面图中的ThreadLocal对象实例），由于ThreadLocalMap的key持有ThreadLocal的弱引用，即使没有手动断开引用，ThreadLocal也会被回收。

这里有一个注意点：value不是弱引用，所以当前value只有在下一次ThreadLocalMap调用set、get、remove的时候会被清除。如果我们不使用这个值了最好手动的remove（不remove那么value对象的生命周期就和项目的生存周期一样长），就可能会造成内存泄漏问题。

## ps-相关资料

[ThreadLocal作用、场景、原理](https://www.jianshu.com/p/6fc3bba12f38)

[Java并发编程：深入剖析ThreadLocal](https://www.cnblogs.com/dolphin0520/p/3920407.html)

[ThreadLocal理解及应用](https://blog.csdn.net/zzg1229059735/article/details/82715741)

[ThreadLocal应用-多数据源切换](https://blog.csdn.net/csdn_mingss/article/details/86586322)

[TheadLocal 引起的内存泄露故障分析](https://mp.weixin.qq.com/s/Gf4MiHPz8DynY80UmwH04Q)