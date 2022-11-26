### 为什么需要多线程

-   cpu和I/O的读写差异「CPU：这个世界慢死了，（百度下这个文章）」
-   多核CPU的发展

-   线程的本质是什么？

1-多个执行流，并发执行（同时做）

2-缺点：慢：切换上下文 占用资源多

#### 能不能让上下文切换尽可能少

-   协程-用户态线程 专门有一个线程管理上下文切换

### Thread是什么以及线程问题

-   Thread类中的每一个实例代表JVM中的线程

- start()之后，且未结束

-   Runnable/Callable都不是线程
-   Thread.start()后JVM中就增加：

- 一个工人/执行流

- 一套方法栈

-   不同的执行流的同步执行是一切线程问题的根源

![](https://cdn.nlark.com/yuque/__puml/14d45d8fda9d730a873e359ca548d9c5.svg)

### Thread的底层模型

-   Thread类的每一个实例代表一个JVM中的线程

-   在Linux上称为【轻量级进程】，和进程无本质区别
-   在Windows上使用系统线程

-   Linux用指针直接指向内核对应的线程

-   优点：

-   简单，直接依赖操作系统调度器

-   缺点

-   占用资源多
-   上下文切换慢

-   不灵活，无法实现灵活的优先级

  

### Thread的生命周期

-   ![](https://cdn.nlark.com/yuque/0/2021/jpeg/21566525/1623070565047-37ed55ff-fd9f-4705-a61a-bfcd6630da9b.jpeg)

![](https://cdn.nlark.com/yuque/__puml/54bf811c3dd5521757d263ca4369c115.svg)

### ThreadLocal的详解与源码分析

-   上下文的数据传输（一定要注意最后清理）
-   设置全局私有的变量变成局部变量，使得每个线程都有独自的线程变量互不干扰

private static class MyThreadLocal{
    Map<Long,String> data = new HashMap<>();
    public String get(){
        return data.get(Thread.currentThread().getId())
    }
    public void set(String userName){
     data.put(Thread.currentThread().getId(),userName)
    }
}

-   数据为什么要放在threadLocalMap中而不是ThreadLocal中，是因为放在map中在线程结束后map作为弱引用就会被回收，放在Thread中就可能会成为泄露的强引用

### 协程的优缺点

-   操作系统的内核的缺点

-   慢：上下文切换极其费时

-   调度的时候需要发起系统调用，在内核态和用户态之间切换

-   大：独立的方法栈需要很多空间

-   协程

-   快：始终占用CPU，在用户态
-   小：可以方便的实现上百万的并发度

-   解决的问题是：

-   多线程调度较慢，占用资源多的问题

-   不解决的问题:

-   并发问题：死锁/竞争条件

### 什么是线程·Runnable·Callable

-   Runnable是一个可执行的接口，代表一个任务
-   可以被任一个线程执行

-   什么是Callable？

-   Runnable的限制（没办法返回值）
-   不能抛出checked Exception

### 多线程中断

-   任何线程都可以被中断吗（取决于这个线程自己的决定）
-   中断只能发生在这些方法里吗（取决于线程自己的策略，JVM会正常响应）

-   如果你自己没有能力处理中断，那么请重新设置标志位 使得其他人能够知道该线程被中断了

1 让一个线程停在一个地方

### Java Memory Model

-   局部变量是私有的除此之外都是共有

### 线程安全问题

### JUC的并发工具包 (CAS Compare And Swap)

-   int/long ->AtomicInteger/Long
-   HashMap->ConcurrentHashMap

-   ArrayList->CopyOnWriteArrayList
-   TreeMap->ConcurrentSkipListMap

-   []->AtomicLongArray
-   Object->AtomicReference

### 死锁问题

哲学家就餐问题

public class Main{
    static Object lock1=new Object();
    static Object lock2=new Object();
    public static void main (String[] args){
        new Thread(()->{
            synchronized(lock2){
                try{
                    //dosomthing
                    synchronized(lock1){
                      //dosomthing  
                    }
                }
            }
        }).start();
        synchronized(lock1){
            try{
                //dosomthing
                synchronized(lock2){
                    //dosomthing  
                }
            }
        }
    }
}

-   jps+jstack
-   结合源代码

-   Object.wait()+Object.notify/notifyAll
-   Lock/Condition

### Volatile相关的

### 多线程的问题

-   正确性：

-   安全：竞争条件/死锁
-   协同：同时，随机执行的线程，如何让他们协同工作

-   效率和易用性：

-   执行的越快越好
-   用起来越不容易出错越好

### Synchronized

-   字节码上是什么（MONITORENTER，MONITOREXIT）
-   锁住的是什么

#### 某个对象的对象头的锁膨胀的过程

-   无锁：来占有我吧
-   偏向锁：一直以来都只有一个线程使用我，下次直接使用

-   轻量锁：有线程竞争的情况发生，但是不严重，假如你能抢到我，就不需要monitor
-   重量锁：有多个线程在同时竞争锁，所以必须获取monitor

### Wait 和Sleep的区别

-   wait会放弃持有资源，sleep则是一直持有资源
-   生产者消费者

public class Main {
    public static void main(String[] args){
        Container container=new Container();
        Producer producer = new Producer();
        Consumer consumer = new Consumer();
        producer.start();
        consumer.start();
        producer.join();
        consumer.join();
    }
    
    static class Container{
       volatile Object value;
    }
    static class Producer extends Thread{
        Container container;
            public Producet(Container container){
                this.container=container;
            }
        @override
        public void run(){
            synchronized(container){
                while(container.value!=null){
                    container.wait();
                }
                int random = new Random.nextInt();
                container.value=random;
                container.notify;
            }
        }
    }
    static class Consumer extends Thread{
                Container container;
            public Consumer(Container container){
                this.container=container;
            }
                @override
        public void run(){
            synchronized(container){
                while(container.value==null){
                    container.wait();
                }
                container.value=null;
                container.notify;
            }
        }
    }
}

### JUC包

  

#### lock/Condition

-   Lock/Condition与synchronized/wait/notify机制的差别
-   锁的重入问题

-   更加灵活

-   同一个锁可以有多个条件
-   读写分离

-   tryLock
-   可以方便的实现更加灵活的优先级/公平性

-   Lock/Condition再次实现生产者/消费者模型
-   Lock/Condition实现多线程的协调工作

### SPI机制

![1660460431127.png](http://cdn.jykss.top/1660460431127.png)

![1660460513076.png](http://cdn.jykss.top/1660460513076.png)
