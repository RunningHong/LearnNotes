[toc]

# 线程通信

线程的通信指的是在多线程运行中，线程间的某种合作。

比如：使用2个线程打印1-100，线程A,线程B交替打印。

## 1 代码实现

```java
package com.hong.concurrent;

/**
 * @author hongzh.zhang on 2021/01/30
 * 线程通信
 * 使用2个线程打印1-100，线程A,线程B交替打印。
 */
public class T08ThreadCommuncation {
    public static void main(String[] args) {
        PrintNumber printNumber = new PrintNumber();

        Thread window1 = new Thread(printNumber);
        Thread window2 = new Thread(printNumber);

        window1.setName("A");
        window2.setName("B");

        window1.start();
        window2.start();
    }
}



class PrintNumber implements Runnable {

    private int number = 0;

    @Override
    public void run() {
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        while (number<100) {
            synchronized (this) {
                notify(); // 获得锁后就唤醒其他线程，让其他线程等着（该线程此时获得锁，其他线程只有等到锁释放后才能拿到锁）
                if (number<100) {
                    System.out.println(Thread.currentThread().getName() + " : " + number);
                    number++;

                    try {
                        wait(); // 打印完后该线程就wait等待其他线程唤醒
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
```

## 2 涉及到的方法-wait(), notify(), notifyAll()

- wait()：一旦执行此方法，当前线程就进入进入阻塞状态，并释放同步监视器。
- notify()：一旦执行此方法，就会唤醒被wait的一个线程，如果有多个线程被wait，就会唤醒优先级高的线程
- notify()：一点执行此方法，就会唤醒所有被wait的线程

## 3 注意点

1. wait(), notify(), notifyAll()这三个方法必须在同步代码块或者同步方法中
2. wait(), notify(), notifyAll()这三个方法的调用者必须是同步代码块或者同步方法中的同步监视器，否者会报IllegalMonitorStateException异常。
3. wait(), notify(), notifyAll()这三个方法是定义在java.lang.Object中的

## 4 使用Condition精确控制

给每个线程不同的condition. 可以用condition.signal()精确地通知对应的线程继续执行(在对应的condition上await的线程, 可能是多个)。

例子：三个线程按顺序打印数字1/2/3

```java
public class TestSequential01 {
    private static Lock lock = new ReentrantLock();
    private static Condition[] conditions = {lock.newCondition(), lock.newCondition(), lock.newCondition()};
    private volatile int state = 1;
 
    private void run(final int self) {
        int next = self % 3 + 1;
        while(true) {
            lock.lock();
            try {
                while(this.state != self) {
                    conditions[self - 1].await();
                }
                System.out.println(self);
                this.state = next;
                conditions[next - 1].signal();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            lock.unlock();
        }
    }
 
    public static void main(String[] args) {
        TestSequential01 rlc = new TestSequential01();
        for (int i = 1; i < 4; i++) {
            int j = i;
            new Thread(()->rlc.run(j)).start();
        }
    }
}
```

## ps-相关资料

[三个线程按顺序交替打印ABC](https://www.jianshu.com/p/f79fa5aafb44)