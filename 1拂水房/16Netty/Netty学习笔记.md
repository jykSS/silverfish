# 为什么需要Spring WebFlux

在当下的环境中，我们将面临越来越多的并发处理需求，而传统的Spring Web MVC已经无法满足这类需求，即我们需要一个无阻塞的且使用很少硬件资源（也就是通过很少的线程）的Web框架来处理并发任务。Servlet 3.1确实为非阻塞I/O提供了相应的API，但是，使用它时Servlet其余部分的API是同步（比如Filter）或阻塞（比如getParameter、getPart）的。我们知道，Tomcat等服务器有一个Servlet Worker线程池，而使用Spring Web MVC的话，请求的处理过程将会在DispatcherServlet中进行，而其内部默认不会进行异步处理，所以当有I/O或者耗时操作的时候，很可能会阻塞当前Servlet实例所在的线程（可以参考网上关于Spring Web MVC异步操作的相关文章）。我们的目的就是将当前Servlet实例正在使用的线程给释放出来，这样就可以接收更多的请求。那么Spring Web MVC与Spring WebFlux的区别到底是什么？Spring WebFlux的存在有何意义？这也是本章要涉及的主题。

  

## **1.1 客户端与服务端通信**

  

在HTTP1.1中，如果没有其他特殊声明，浏览器与服务器之间的所有连接都可认为是持久存在的，即我们常说的长连接。也就是说，可以使用一个TCP连接去发送和接收多个HTTP 请求/响应，而无须为每个单独的请求/响应 都去创建一个新的连接用以通信。 作为Java Web开发者，相信大家在接触Tomcat之后，都会学习Tomcat的配置文件server.xml，其中有一个Connector，主要功能是接收连接请求，创建Request和Response对象，用于与请求端交换数据；然后分配线程让Servlet容器来处理这个请求，并把产生的Request和Response对象传递给Servlet。在Servlet处理完请求后，也会通过Connector将响应返回给客户端。所以我们就从Connector入手，讨论一些与Connector有关问题，包括NIO/BIO模式、线程池、连接数等。根据不同的协议，Connector可以分为HTTP Connector、AJP Connector等，本章只讨论HTTP Connector。 直到Tomcat 6，Tomcat使用的都是基于Servlet 2.5版本，此处拿Tomcat 6来说，它默认的HTTP Connector采用的异步阻塞模型，是一条线程对应一个连接（connection）。这意味着，如果有50个用户同时并发访问，Tomcat就需要有50条活动线程处理这些连接。我们知道，线程的创建是极为消耗资源的，而目前大多数HTTP请求使用的是长连接（HTTP/1.1默认的keep-alive为true），而长连接意味着，在当前请求结束后，如果没有新的请求到来，一个TCP的socket不会立马被释放，而是等超时后再释放。虽然可以使用线程池来对线程进行管理，但接收请求和处理请求都在同一条线程内，当线程池中所有可使用的处理请求的线程数都被使用时，新的请求就会放到该线程池的处理队列中，关于此处，如果读者有查看相关资料，可以发现Tomcat 6的server.xml配置文件中有一个参数acceptCount，用于设定该线程池队列的大小，默认为10个。所以，当请求数量大于该线程池承受能力时，Tomcat 6就拒绝处理了，由此可看出，Tomcat可以同时处理的socket数量不能超过最大线程数，从而性能受到了极大的限制。。 Tomcat 6的这种默认处理请求的方式虽然使用了多线程来进行异步处理，但其实还是阻塞BIO。我们想要让它从BIO变为NIO的处理模型，就要从Connector入手。Connector在处理HTTP请求时，会使用不同的协议。不同的Tomcat版本支持的协议不同，其中典型的协议包括BIO、NIO和APR（Tomcat 7中支持这3种协议，Tomcat 8中增加了对NIO2的支持，而在Tomcat 8.5和Tomcat 9.0中，则去掉了对BIO的支持）。我们可以在Tomcat的Service.xml文件中对Connector配置属性protocol做如下修改：

  

<Connector port="8080" protocol="HTTP/1.1" 

connectionTimeout="20000" 

redirectPort="8443" /> 

改为

<Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol" 

connectionTimeout="20000" 

redirectPort="8443" />

  

为了便于理解，下面先明确一下连接与请求的关系。

  

• 连接是TCP层面的（传输层），对应socket。

  

• 请求是HTTP层面的（应用层），必须依赖于TCP的连接实现。

  

• 一个TCP连接中可能会传输多个HTTP请求。

  

BIO是Blocking I/O，顾名思义，代表阻塞的I/O；NIO是Non-blocking I/O，代表的是非阻塞的I/O。而APR是Apache Portable Runtime，是Apache可移植运行库，利用本地库可以实现高可扩展性、高性能；APR是在Tomcat上运行高并发应用的首选模式，但需要安装apr、apr-utils、tomcat-native等包。

  

在基于BIO实现的Connector中，请求主要由JioEndpoint对象来处理。JioEndpoint维护了Acceptor和Worker，通过Acceptor接收socket，然后从Worker线程池中找到空闲的线程处理socket，如果Worker线程池中没有空闲的线程，则Acceptor将被阻塞。其中Worker是Tomcat自带的线程池，如果通过配置了其他线程池，原理与Worker线程池类似。

  

在基于NIO实现的Connector中，处理请求的主要实体是NIOEndpoint对象。NIOEndpoint中除了包含Acceptor和Worker外，还使用了Poller，处理流程如图1-1所示。

  

![](https://pic3.zhimg.com/v2-d6481cca3d3d32f286192740244a0dfa_b.jpg)

  

图1-1

  

图1-1中的Acceptor及Worker都是以线程池形式存在，Poller默认是一个单线程。从图中可以看到，在Acceptor在接收请求后会得到一个SocketChannel对象，然后将其封装在一个Tomcat的org.apache.tomcat.util.net.NIOChannel实现类对象中，这里，并不会直接使用Worker线程池中的线程处理请求，而是将NIOChannel包装为一个PollerEvent对象并添加在一个events queue这个队列中。这里会先将PollerEvent对象发送给Poller，而Poller是实现NIO的关键。Acceptor向Poller发送包装后的请求，这是通过添加队列的操作实现的，这里使用了典型的生产者—消费者模式。同时，在Poller中，维护了一个Selector对象；在Poller从队列中取出包装后的socket（即PollerEvent），将其注册到Selector对象中；然后通过遍历Selector，找出其中可读的socket，并使用Worker线程池中的线程处理相应的请求。

  

相较于BIO，Tomcat使用NIO，读取socket并交给Worker线程池中的线程这一过程是非阻塞的（是由Poller所在的线程维护的），并不会占用工作线程，因此Tomcat可以同时处理的socket数量不受最大线程数的约束，从而并发性能得到了大大的提升，但Poller同时也成为其性能瓶颈。

  

随着引入基于NIO的Connector，客户端到服务端的通信是非阻塞的，但是服务端到Servlet的连接仍然是阻塞的，这也就意味着，每个请求都会阻塞一个线程，也就导致我们会看到一个线程处理一个请求的模型。因此，随着Servlet容器的发展，Servlet API也需要支持非阻塞，这就有了Servlet 3.0与Servlet 3.1+。

  

## **1.2 Servlet 3.0与Servlet 3.1中的异步实现**

  

从上一节可知，在引入基于NIO的Connector后，我们会看到一个线程处理一个请求的模型。也就是一旦一个线程被分配给了一个Servlet，在Servlet中就会发生对Socket的读写，即会尝试从HttpInputStream / HttpOutputStream中读写数据，那这个读写的过程就是一个阻塞的行为。所以，Servlet API是天然阻塞的，我们要通过一些特殊的方式来使之实现异步调用。

  

首先，最简单的方式就是使用大量的线程来处理Servlet任务，这里使用一个线程池，专门用于管理Servlet任务，比如上一节中我们提到的Worker线程池。如果这个线程池默认大小为200，那么它同时可并发处理的请求数量为200。此时，问题就又出现了，默认情况下，在响应返回前，处理线程会一直同步处理Servlet任务，如果任务比较繁重，这可能会导致线程运行很长时间。同样，如果这种情况大规模发生，那线程池中将无线程可用。我们可以增加线程池大小，但会受到服务器自身硬件限制，同时，随着线程池线程数量的增加，也会增加线程上下文切换，CPU高速缓存刷新等性能开销。不过增加线程数量以服务更多的并发请求本就是我们想要的，只是我们希望通过其他的方式来让应用程序获取到更高的并发性，而不是这样一味地增加Servlet线程池大小。

  

### **Servlet 3.0中实现异步化**

  

可以思考下，本质上，Servlet任务是对Socket的读写，那我们就把这个读写的过程异步化，然后就将Servlet线程给释放出来了，这样Servlet线程也就可以处理更多的请求。而对Socket的读写，完全可以放在一个我们可控的单独线程中来做，Socket在操作系统看来，其实就是一个文件，那我们要做的事情其实就是在这条单独的线程中实现对文件的读写。

  

具体操作是，通过Servlet线程来获取到客户端传入的请求，然后将请求传递到我们自己设定的线程中，后者将负责处理请求并将响应发送给客户端。Servlet线程在将请求传递给我们设定的线程后，立即返回Servlet线程池（即1.1所提到的Worker线程池）中，用于处理下一个请求。

  

接下来通过下面一段代码来看下如何在Servlet 3.0中实现异步化：

  

@WebServlet(name="simvisoServlet", urlPatterns={"/asyncprocess"}, asyncSupported=true)
public class SimvisoServlet extends HttpServlet {
 ScheduledThreadPoolExecutor executor = new ScheduledThreadPoolExecutor(10);
 public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
 OutputStream out = response.getOutputStream();
        AsyncContext ctx = request.startAsync(request, response);
 //在一个单独的线程中处理请求
 Runnable runnable = new Runnable() {
 @Override
 public void run() {
 String string ="simviso asyncprocess";
                out.write(string);
 //ctx.dispatch("/asynctest.jsp");
                ctx.complete();
            }
        };
 //将任务提交到自定义的一个线程池中执行
        executor.submit(runnable);
    }
}

  

当asyncSupported属性设置为true时，在方法退出时不会提交响应对象。调用HttpServletRequest的startAsync方法返回一个AsyncContext对象，该对象用于缓存请求/响应对象。doGet方法将返回，并且最初的用于请求处理的Servlet线程将被回收，没有任何延迟。我们可以在服务器启动时配置一个自定义线程池执行器，该线程池将真正用于处理请求。处理完毕后，你可以选择调用HttpServletResponse.getOutputStream().write方法，然后，需要调用AsyncContext对象的complete方法提交响应，或调用AsyncContext对象的forward方法将结果将显示到一个JSP页面上。注意，JSP页面是一个asyncSupported属性默认值为false的servlet，而调用AsyncContext对象的complete方法会触发Servlet容器将响应返回给客户端。

  

这里还需要提到的是，在Servlet 3.0中可以使用AsyncListener接口来为异步处理提供一个监听器。此接口负责管理异步事件，用于监控如下四种事件：

  

异步线程开始时，调用AsyncListener的onStartAsync(AsyncEvent event)方法；

  

异步线程出错时，调用AsyncListener的onError(AsyncEvent event)方法；

  

异步线程执行超时，调用AsyncListener的onTimeout(AsyncEvent event)方法；

  

异步执行完毕时，调用AsyncListener的onComplete(AsyncEvent event)方法；

  

要注册一个AsyncListener，只需将准备好的AsyncListener对象传递给AsyncContext对象的addListener方法即可，如下所示：

  

ScheduledThreadPoolExecutor executor = new ScheduledThreadPoolExecutor(10);
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
    AsyncContext ctx = request.startAsync(request, response);
    ctx.addListener(new AsyncListener(){
 public void onComplete(AsyncEvent event) throws IOException{
 // 做一些清理或者其他工作
        }

 public void onTimeout(AsyncEvent event) throws IOException{
 //做一些超时处理或者其他工作
        }
    });
 //在一个单独的线程中处理请求
 Runnable runnable = new Runnable() {
 @Override
 public void run() {
 String string ="simviso asyncprocess";
                out.write(string);
 //ctx.dispatch("/asynctest.jsp");
                ctx.complete();
            }
        };
 //将任务提交到自定义的一个线程池中执行
        executor.submit(runnable);
}

  

下面通过图1-2来展示整个客户端从请求到服务器端响应的执行过程：

  

![](https://pic2.zhimg.com/v2-61ea4b6219a7c3b08c77c6ebe4193499_b.jpg)

  

图1-2

  

Servlet 3.0对请求的处理虽然是异步的，但是对InputStream和OutputStream的IO操作却依然是阻塞的，如果我们没有将异步处理交给自己创建的线程池，那么，我们也可以先通过request.startAsync()获取到该请求对应的AsyncContext，然后调用AsyncContext的start方法进行异步处理，处理完毕后调用AsyncContext的complete方法提交响应。AsyncContext的start方法会向Servlet容器另外申请一个新的线程（这里往往是Worker线程池，可能有些Servlet容器实现有所不同），然后在这个新的线程中继续处理请求，而原先的线程将被回收到Worker线程池中。由此，可以看到，这种方式对性能的改进不大，因为如果新的线程和初始Servlet线程共享同一个线程池的话，相当于闲置了一个线程，但同时又占用了另一个线程，反而造成了线程上下文切换这种资源浪费的情况出现。所以，在Servlet 3.0中，对请求的异步处理编程需要很小心才行。针对这里描述的内容，下面通过一段代码进行表示：

  

@WebServlet(name="simvisoServlet", urlPatterns={"/asyncprocess"}, asyncSupported=true)
public class SimvisoServlet extends HttpServlet {
 ScheduledThreadPoolExecutor executor = new ScheduledThreadPoolExecutor(10);
 public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        AsyncContext asyncContext = request.startAsync();
        asyncContext.start(()->{
 try {
                asyncContext.getResponse().getWriter().write("simviso asyncprocess!");
            } catch (IOException e) {
                e.printStackTrace();
            }
            asyncContext.complete();
        });
    }
}

  

然后再通过图1-3来展示在没有将异步处理交给自己创建的线程池时整个客户端从请求到服务器端响应的执行过程：

  

![](https://pic2.zhimg.com/v2-dafff3624ecc4158b7234952861bf2dd_b.jpg)

  

图1-3

  

根据前文所述，Servlet 3.0允许对请求进行异步处理，但在这个异步处理过程中，传统的I/O是允许的。这就会造成一些问题，此处通过两个场景来思考：

  

• 因为客户端与服务器底层的通信都是通过Socket进行的，如果进入服务器（客户端写入Socket）的数据阻塞或因为网络问题数据流传输的速度比服务器读取的速度慢，则尝试读取此数据的服务器线程必须等待该数据。

  

• 另一方面，如果从服务器往ServletOutputStream写入响应数据的速度很慢，则客户端线程必须等待。

  

在这两种情况下，服务器线程都执行都会因这种传统的I/O（用于请求/响应）阻塞。同时，对于数据量大的请求体或者响应体，阻塞IO也将导致不必要的等待。换句话说，在Servlet 3.0中，只有请求处理部分变为异步，而用于服务请求和响应的I/O并不是异步的。要知道，Servlet线程中会有一个过滤器链对请求和响应进行处理，在过滤器链的处理过程中会对请求和响应产生I/O操作，如果线程阻塞的数量足够多，这将导致线程饥饿，并影响性能。

  

为此，在Servlet 3.1中引入了非阻塞IO，通过在HttpServletRequest和HttpServletResponse中分别添加ReadListener和WriterListener方法，可以让我们做到：只有在IO数据满足一定条件时（比如读取/写入已经数据准备好），再进行后续的操作。如下代码所示：

  

void doGet(request, response) {
        ServletOutputStream out = response.getOutputStream();
        AsyncContext ctx = request.startAsync();
        out.setWriteListener(new WriteListener() {
 void onWritePossible() {
 while (out.isReady()) {
 byte[] buffer = readFromSomeSource();
 if (buffer != null)
                        out.write(buffer); ---> Async Write!
 else{
                        ctx.complete(); break;
                    }
                  }
                }
            });
        }

  

在上面的代码中，我们使用了Servlet 3.1中引入的WriteListener。 WriteListener有一个onWritePossible方法的接口，该方法由Servlet容器调用。 通过ServletOutputStream的isReady来检查是否可以写入NIO Socket的缓冲区。 万一返回true，则在Servlet容器上调用执行onWritePossible方法，否则在Socket可用于写的时候，Servlet容器会调用此监听器方法。相关源码如下所示：

  

//org.apache.coyote.Response#setWriteListener
public void setWriteListener(WriteListener listener) {     
        ...
 this.listener = listener; 
 if (isReady()) {
 synchronized (nonBlockingStateLock) {      
                registeredForWrite = true;               
                fireListener = true;
            }
 action(ActionCode.DISPATCH_WRITE, null);
 if (!ContainerThreadMarker.isContainerThread()) {                
 action(ActionCode.DISPATCH_EXECUTE, null);
            }
        }
    }

//org.apache.catalina.connector.CoyoteAdapter#asyncDispatch
@Override
public boolean asyncDispatch(org.apache.coyote.Request req, org.apache.coyote.Response res,
                             SocketEvent status) throws Exception {

 Request request = (Request) req.getNote(ADAPTER_NOTES);
 Response response = (Response) res.getNote(ADAPTER_NOTES);
    ...
 if (!request.isAsyncDispatching() && request.isAsync()) {
            WriteListener writeListener = res.getWriteListener();
            ReadListener readListener = req.getReadListener();
 //Socket可用于写的时候，Servlet容器会调用写监听器方法onWritePossible
 if (writeListener != null && status == SocketEvent.OPEN_WRITE) {
 ClassLoader oldCL = null;
 try {
                    oldCL = request.getContext().bind(false, null);
                    res.onWritePossible();
 if (request.isFinished() && req.sendAllDataReadEvent() &&
                        readListener != null) {
                        readListener.onAllDataRead();
                    }
                } catch (Throwable t) {
                   ...
                } finally {
                    request.getContext().unbind(false, oldCL);
                }
            }
            ...
        }

  

结合上面的内容，我们对图1-2进行改造如下：

  

![](https://pic2.zhimg.com/v2-53f05ea987ee93e63ca370e819a63209_b.jpg)

  

图1-4

  

## **1.3 基于消息传递的事件驱动类型架构介绍**

  

在使用同步类型API时，如果将每一个同步类型的API方法都看作是一个命令，那编写这种由多个命令衔接的单个调用栈风格的代码会很轻松。但编写前文所示的非阻塞代码，那就有点难度了，但相对的，我们获得了想要的性能。

  

那到底怎样才能做到非阻塞？结合前面的内容，可以总结出，我们做到非阻塞的核心在于Event-Loop。我们需要去设定一些Worker线程用于低级层面的IO处理。对于当下成熟的HTTP服务器，它们的核心就是一个Event-Loop。Tomcat，Jetty和Netty它们都有这个Event-Loop，通过Event-Loop，我们可以处理大量的连接，当一个连接的状态是读或者写时，它们可以根据状态进行相应的处理，当Event-Loop对应的线程不再处理这个连接的时候，就会去处理下一个连接。

  

拿Netty来举例，将客户端与服务器端建立的连接称之为Channel，将1.1节谈到的Tomcat中Acceptor的角色称之为BossEventLoopGroup。将用来处理Channel业务的Worker线程池称之为WorkerEventLoopGroup，在处理每个Channel涉及的具体业务时，为了避免每出现一个Channel就要创建一个线程，这里，将Channel和WorkerEventLoop绑定在一起，在处理有关Channel的读写事件时，将读写任务提交到与Channel绑定的WorkerEventLoop中。本质上说，这就是通过使用固定数量线程的EventLoopGroup来驱动处理我们想要做事情的方式。这样也就会默认地将我们的程序架构演进为基于消息传递的事件驱动型架构。即，我们只需要专注于某一个整个复杂流程的某一个属于自己负责的业务环节即可。

  

关于消息驱动编程，简单地说，可以类比为使用JDK中Stream API编程，我们会从一个数组中获取多个数据元素，每一个元素都是一个消息，然后将消息一个个发出去，这里还会使用到某种类型的队列，这有点像在1.1节中提到的events queue，接着，我们通过一个线程池从该队列中取出元素进行并行处理。这就是我们通过借鉴前面的内容总结出来的，要在应用程序中实现的事情。

  

## **1.4 背压控制**

  

通过这种基于消息传递的事件驱动类型架构，我们可以很轻松的实现非阻塞。但我们要做的不仅仅是消息的传递，而是基于它，对消息去做类似于Stream API给出的加工处理，即，专注于应用程序中的业务逻辑处理，同时不希望每一个业务逻辑过于复杂。

  

但在这种架构下，一旦遇到超大事件流，我们的WorkerEventLoop可能会处理不过来，那就需要一种机制来对此进行控制。如果你告诉数据源，自己并没有准备好去处理这些数据元素，要知道，这并不是阻塞式IO场景，会在你写阻塞的时候，上游无法发送任何事件，在非阻塞式场景下，你需要一种方式告诉上游，不要再发送事件了。这里就需要Reactive Streams技术标准了，使用该标准，我们可以通过发起一次请求来控制上游Publisher来给下游提供所需数量的数据元素，这些元素只有在我们请求它们的时候，才会真正的下发到我们手上，这就是背压的概念。从某种意义上，给予了我们一种限流手段来控制事件元素的数量，来避免局面超出我们处理能力范围之外。

  

接下来结合一个小的例子来简单演示下背压的控制。本书默认大家掌握了Project Reactor的基本使用知识。于是，可以通过Reactor的相关操作来控制元素请求数量，也可以在自定义订阅者的时候进行限定，这是通过Flux下的limitRate(n)来实现的。首先来看看具体的实现思路，其实这就是一个调度操作，只不过publishOn是一个中间存储站，它将上下游进行了分离，下游的元素请求数量放在这里进行管理，publishOn有一个每次向上游请求元素数量的限制，关于publishOn操作的源码细节，可以去看本人已出版的《Java编程方法论：响应式Spring Reactor 3设计与实现》相关章节的内容。也就是说，只需要在publishOn之上封装一个API即可实现：

  

//reactor.core.publisher.Flux#limitRate(int)
public final Flux<T> limitRate(int prefetchRate) {
 return onAssembly(this.publishOn(Schedulers.immediate(), prefetchRate));
}

  

假如我们有一个包含questions的源，因为解决问题的能力有限，所以想要对其进行限流，于是可以进行如下操作：

  

@PostMapping("/questions")
public Mono<Void> postAllQuestions(Flux<Question> questionsFlux) {

 return questionService.process(questionsFlux.limitRate(10))
                       .then();
}

  

在熟悉publishOn操作后，可以知道limitRate操作首先会从上游获取10个元素存储到其内定义的队列中。这意味着即使我们定义的订阅者所设定的元素请求数量为Long.MAX_VALUE，limitRate操作也会将其拆分为一块一块并请求下发。此处涉及的源码如下，大家可以对照源码进行理解：

  

//reactor.core.publisher.FluxPublishOn.PublishOnSubscriber#runAsync
if (e == limit) {
 if (r != Long.MAX_VALUE) {
        r = REQUESTED.addAndGet(this, -e);
    }
    s.request(e);
    e = 0L;
}

  

上面是提交数据的分块处理过程，有时候还会涉及处理数据库请求的数据，比如查询操作，同时对要发送的数据进行限流并逐步发送，可以进行如下操作：

  

@GetMapping("/questions")
public Flux<Question> getAllQuestions() {

 return questionService.retreiveAll()
                       .limitRate(10);
}

  

由此，我们就能理解背压在WebFlux中的作用了，而Spring MVC很难提供这些特性。

  

于是，我们可以将Reactive Streams与Netty或者Servlet容器结合起来。因为最终目标是实现非阻塞IO，结合前两小节的内容，Servlet 必须选用3.1+的版本。为了降低Netty使用的复杂性，Spring提供了Reactor Netty库，在它之上，有一个WebFlux框架，可以让我们获取到不一样的编程体验。

  

## **1.5 小结**

  

为了将Reactive Streams与Netty或者Servlet容器结合起来，Spring提供了WebFlux框架。同时，为了降低Netty使用的复杂性，Spring提供了Reactor Netty库，可以让我们获取到不一样的编程体验。需要注意的是，因为最终目标是实现非阻塞IO，结合本章的内容，Servlet 必须选用3.1+的版本。最后，本书更关心Spring Webflux基于Netty服务器的运行过程，那么，接下来将讲解Reactor Netty的内在细节。