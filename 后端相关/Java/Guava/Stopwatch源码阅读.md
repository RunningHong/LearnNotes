[TOC]

# Stopwatch源码阅读

Stopwatch代码挺简单的，主要应用于**程序耗时计算和性能调试**。

使用方法

```java
// 创建一个stopwatch
Stopwatch stopwatch = Stopwatch.createStarted();

// 业务操作
doSomething();

// 停止计时
stopwatch.stop(); 

// 传入计时单位
long millis = stopwatch.elapsed(MILLISECONDS);
log.info("time: " + stopwatch);
```

## 1 成员变量

```java
public final class Stopwatch {
  //计时器，用于获取当前时间
  private final Ticker ticker;
    
  //计时器是否运行中的状态标记
  private boolean isRunning;
    
  //用于标记从计时器开启到调用统计的方法时过去的时间  
  private long elapsedNanos;
    
  //计时器开启的时刻时间  
  private long startTick;
}
```

## 2 关键方法

### 2.1 实例方法

```java
    /** @deprecated */
    @Deprecated
    Stopwatch() {
        this(Ticker.systemTicker());
    }

    /** @deprecated */
    @Deprecated
    Stopwatch(Ticker ticker) {
        this.ticker = (Ticker)Preconditions.checkNotNull(ticker, "ticker");
    }

    public static Stopwatch createUnstarted() {
        return new Stopwatch();
    }

    public static Stopwatch createUnstarted(Ticker ticker) {
        return new Stopwatch(ticker);
    }

    public static Stopwatch createStarted() {
        return (new Stopwatch()).start();
    }

    public static Stopwatch createStarted(Ticker ticker) {
        return (new Stopwatch(ticker)).start();
    }
```

Stopwatch方法的构造方法已被@Deprecated修饰，所以Guava不建议我们采用这个来实例化Stopwatch类，而因该通过createUnstarted、createStarted来得到Stopwatch实例（方法对参数进行了处理）。

### 2.2 start()

```java 
public Stopwatch start() {
    checkState(!isRunning, "This stopwatch is already running.");
    isRunning = true;
    //设置startTick时间为stopwatch开始启动的时刻时间
    startTick = ticker.read();
    return this;
  }
```

start()为启动Stopwatch，首先还是很正规的进行判断，判断Stopwatch是否正在运行，如果正在运行则打印语句。如果调用start()方法时没有启动那么就对startTick进行赋值（赋一个初值）。

start()在createStarted()方法中被调用。

### 2.3 stop()

```java 
public Stopwatch stop() {
    long tick = ticker.read();
    checkState(isRunning, "This stopwatch is already stopped.");
    isRunning = false;
    //设置elapsedNanos时间为方法调用时间-stopwatch开启时间+上次程序stopwatch的elapsedNanos历史时间 
    elapsedNanos += tick - startTick;
    return this;
  }
```

stop就是停止计时的作用。

### 2.4 elapsed()

```
public long elapsed(TimeUnit desiredUnit) {
    return desiredUnit.convert(elapsedNanos(), NANOSECONDS);
  }


private long elapsedNanos() {
    //如果stopwatch仍在运行中，返回当前时刻时间-stopwatch开启时刻时间+历史elapsedNanos时间（elapsedNanos只在stop和reset时会更新）
    //如果stopwatch已停止运行，则直接返回elapsedNanos，详见stop()
    return isRunning ? ticker.read() - startTick + elapsedNanos : elapsedNanos;
  }
```

elapsed是返回的从开始到现在用了多少时间，并没有停止Stopwatch。