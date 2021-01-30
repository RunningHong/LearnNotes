[toc]

# 线程通信

线程的通信指的是在多线程运行中，线程间的某种合作。

比如：使用2个线程打印1-100，线程A,线程B交替打印。

## 1 代码实现

```
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

