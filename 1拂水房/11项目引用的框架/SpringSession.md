SpringSession.md
# Session会话管理概述
## Web中的Session和Cookie回顾
### Session机制
由于HTTP协议是无状态的协议，一次浏览器和服务器的交互过程就是：
浏览器：你好吗？
服务器：很好！
这就是一次会话，对话完成后，这次会话就结束了，服务器端并不能记住这个人，下次再对话时，服务器端并不知道是上一次的这个人，所以服务端需要记录用户的状态时，就需要用某种机制来识别具体的用户，这个机制就是Session。
### Cookie
服务端如何识别特定的客户？
这个时候需要使用Cookie。每次HTTP请求的时候，客户端都会发送相应的Cookie信息到服务端。
实际上大多数的应用都是用 Cookie 来实现Session跟踪的，第一次创建Session时，服务端会在HTTP协议中向客户端 Cookie 中记录一个Session ID，以后每次请求把这个会话ID发送到服务器，这样服务端就知道客户端是谁了。
### url重写
那么如果客户端的浏览器禁用了 Cookie 怎么办？
一般这种情况下，会使用一种叫做URL重写的技术来进行session会话跟踪，即每次HTTP交互，URL后面都会被附加上一个诸如 sessionId=xxxxx 这样的参数，服务端据此来识别客户端是谁
## Session会话管理及带来的问题
在Web项目开发中，Session会话管理是一个很重要的部分，用于存储与记录用户的状态或相关的数据。
通常情况下session交由容器（tomcat）来负责存储和管理，但是如果项目部署在多台tomcat中，则session管理存在很大的问题

- 多台tomcat之间无法共享session，比如用户在tomcat A服务器上已经登录了，但当负载均衡跳转到tomcat B时，由于tomcat B服务器并没有用户的登录信息，session就失效了，用户就退出了登录
- 一旦tomcat容器关闭或重启也会导致session会话失效

因此如果项目部署在多台tomcat中，就需要解决session共享的问题
## Session会话共享方案

- 第一种是使用容器扩展插件来实现，比如基于Tomcat的tomcat-redis-session-manager插件，基于Jetty的jetty-session-redis插件、memcached-session-manager插件；这个方案的好处是对项目来说是透明的，无需改动代码，但是由于过于依赖容器，一旦容器升级或者更换意味着又得重新配置
- 其实底层是，复制session到其它服务器，所以会有一定的延迟，也不能部署太多的服务器。
   - 第二种是使用Nginx负载均衡的ip_hash策略实现用户每次访问都绑定到同一台具体的后台tomcat服务器实现session总是存在
   - 这种方案的局限性是ip不能变，如果手机从北京跳到河北，那么ip会发生变化；另外负载均衡的时候，如果某一台服务器发生故障，那么会重新定位，也会跳转到别的机器。
   - 第三种是自己写一套Session会话管理的工具类，在需要使用会话的时候都从自己的工具类中获取，而工具类后端存储可以放到Redis中，这个方案灵活性很好，但开发需要一些额外的时间。
   - 第四种是使用框架的会话管理工具，也就是我们要介绍的Spring session，这个方案既不依赖tomcat容器，又不需要改动代码，由Spring session框架为我们提供，可以说是目前非常完美的session共享解决方案
# Spring Session入门
## Spring Session简介
Spring Session 是Spring家族中的一个子项目，它提供一组API和实现，用于管理用户的session信息
它把servlet容器实现的httpSession替换为spring-session，专注于解决 session管理问题，Session信息存储在Redis中，可简单快速且无缝的集成到我们的应用中；
官网：[https://spring.io/](https://spring.io/)
**Spring Session的特性**

- 提供用户session管理的API和实现
- 提供HttpSession，以中立的方式取代web容器的session，比如tomcat中的session
- 支持集群的session处理，不必绑定到具体的web容器去解决集群下的session共享问题
## 入门案例
### 环境配置
#### 创建一个空的Maven project，名字及路径根据自己的情况定。
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485844451-438134dc-dab5-414a-9ed2-d6094b8df300.png#align=left&display=inline&height=589&margin=%5Bobject%20Object%5D&originHeight=589&originWidth=819&status=done&style=none&width=819)


#### 空project创建好后，会提示创建模块，我们暂时先取消
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485844758-8ba2acd4-de4c-4b11-bff1-d2330f0d8293.png#align=left&display=inline&height=728&margin=%5Bobject%20Object%5D&originHeight=728&originWidth=1040&status=done&style=none&width=1040)


#### 设置字体
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485845256-d10709b7-e30c-4386-996c-6b8741514e28.png#align=left&display=inline&height=276&margin=%5Bobject%20Object%5D&originHeight=276&originWidth=969&status=done&style=none&width=969)


#### 设置编码方式
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485845817-d1ab5847-7224-4acd-9c2b-77bfa3d2c6d0.png#align=left&display=inline&height=616&margin=%5Bobject%20Object%5D&originHeight=616&originWidth=960&status=done&style=none&width=960)


#### 设置maven信息
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485846357-2ba4076b-4b4c-4566-9a87-4d2da6852933.png#align=left&display=inline&height=519&margin=%5Bobject%20Object%5D&originHeight=519&originWidth=959&status=done&style=none&width=959)


#### 创建一个Maven的web module，名字为01-springsession-web
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485846920-becacf46-139e-4bc7-919e-798058934476.png#align=left&display=inline&height=595&margin=%5Bobject%20Object%5D&originHeight=595&originWidth=821&status=done&style=none&width=821)


![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485847225-a0032414-7277-47bd-8a4f-c3f19e56c47f.png#align=left&display=inline&height=217&margin=%5Bobject%20Object%5D&originHeight=217&originWidth=801&status=done&style=none&width=801)


#### 完善Maven项目的结构
##### 在main目录下，创建java目录，并标记为Sources Root
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485847486-4cdb2981-53e4-4cea-9b3e-d28b465293ed.png#align=left&display=inline&height=585&margin=%5Bobject%20Object%5D&originHeight=585&originWidth=786&status=done&style=none&width=786)


##### 在main目录下，创建resources目录，并标记为Resources Root
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485848038-592663c0-1af1-4f02-9cc3-1a108f5b36a6.png#align=left&display=inline&height=609&margin=%5Bobject%20Object%5D&originHeight=609&originWidth=735&status=done&style=none&width=735)


### 代码开发
#### 创建向session放数据的servlet

- 在java目录下创建包com.bjpowernode.session.servlet包
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485848476-a25202d5-d97d-419e-9c86-51ad4db464eb.png#align=left&display=inline&height=161&margin=%5Bobject%20Object%5D&originHeight=161&originWidth=644&status=done&style=none&width=644)
- 

- 在servlet包下创建SetSessionServlet
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485849154-5851c07d-3c45-4da6-b9d1-2df0db9a0c32.png#align=left&display=inline&height=678&margin=%5Bobject%20Object%5D&originHeight=678&originWidth=570&status=done&style=none&width=570)
- 

- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485849539-af260781-04ed-407e-b7af-a6cf03db00df.png#align=left&display=inline&height=278&margin=%5Bobject%20Object%5D&originHeight=278&originWidth=354&status=done&style=none&width=354)
- 

- 在Servlet中通过注解指定urlPatterns，并编写代码
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485850019-207f9afe-b634-411c-b673-52d0d297b3e3.png#align=left&display=inline&height=406&margin=%5Bobject%20Object%5D&originHeight=406&originWidth=1227&status=done&style=none&width=1227)
- 

#### 创建从session放数据的servlet

- 在servlet包下创建GetSessionServlet
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485850587-edc39102-7382-40ae-ad7d-7b278c0a6bb4.png#align=left&display=inline&height=678&margin=%5Bobject%20Object%5D&originHeight=678&originWidth=570&status=done&style=none&width=570)
- 

- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485851054-eac63f76-9db1-4094-8ee7-9cbcf7203f15.png#align=left&display=inline&height=278&margin=%5Bobject%20Object%5D&originHeight=278&originWidth=354&status=done&style=none&width=354)
- 

- 在Servlet中通过注解指定urlPatterns，并编写代码
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485851583-01ca9d4d-1ac6-4d44-a4ee-89ef9d94bd4a.png#align=left&display=inline&height=403&margin=%5Bobject%20Object%5D&originHeight=403&originWidth=1228&status=done&style=none&width=1228)
- 

#### 向pom.xml文件中添加servlet及jsp的配置
<dependencies>
<!-- servlet依赖的jar包start -->
<dependency>
<groupId>javax.servlet</groupId>
<artifactId>javax.servlet-api</artifactId>
<version>3.1.0</version>
</dependency>
<!-- servlet依赖的jar包start --> 
<!-- jsp依赖jar包start -->
<dependency>
<groupId>javax.servlet.jsp</groupId>
<artifactId>javax.servlet.jsp-api</artifactId>
<version>2.3.1</version>
</dependency>
<!-- jsp依赖jar包end --> 
<!--jstl标签依赖的jar包start -->
<dependency>
<groupId>javax.servlet</groupId>
<artifactId>jstl</artifactId>
<version>1.2</version>
</dependency>
<!--jstl标签依赖的jar包end -->
</dependencies>
#### 部署访问测试（目前无法实现session共享）
##### 配置tomcat9100服务器

- 打开Edit Configurations选项
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485851809-a55d0539-d6b3-4c70-843d-4be61f9d84c4.png#align=left&display=inline&height=159&margin=%5Bobject%20Object%5D&originHeight=159&originWidth=571&status=done&style=none&width=571)
- 

- 添加tomcat配置
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485852108-97b3a198-a78b-4aa6-bc91-791877c04395.png#align=left&display=inline&height=495&margin=%5Bobject%20Object%5D&originHeight=495&originWidth=477&status=done&style=none&width=477)
- 

- 给tomcat服务器取名，并修改端口号
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485852641-8555861c-bd2e-4279-8419-491d48b07e11.png#align=left&display=inline&height=631&margin=%5Bobject%20Object%5D&originHeight=631&originWidth=1086&status=done&style=none&width=1086)
- 

- 将项目部署到tomcat9100上
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485853184-537c860a-7169-45bb-ac08-3cd364225e2b.png#align=left&display=inline&height=632&margin=%5Bobject%20Object%5D&originHeight=632&originWidth=1081&status=done&style=none&width=1081)
- 

- 指定项目的上下文根为/01-springsession-web
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485853667-3cc8cef6-28cc-47fd-9d68-ec9389e2a02a.png#align=left&display=inline&height=271&margin=%5Bobject%20Object%5D&originHeight=271&originWidth=767&status=done&style=none&width=767)
- 

- 为了实现热部署，在Server选项卡中，配置以下两个选项
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485854206-21d77de7-e72d-498c-a92f-11209cf73f0e.png#align=left&display=inline&height=311&margin=%5Bobject%20Object%5D&originHeight=311&originWidth=759&status=done&style=none&width=759)
- 

##### 配置tomcat9200服务器
操作步骤同配置tomcat9100，配完之后在Application Servers窗口中如下
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485854639-1e840125-f436-42db-b23b-2c7b943fdae8.png#align=left&display=inline&height=81&margin=%5Bobject%20Object%5D&originHeight=81&originWidth=486&status=done&style=none&width=486)


### SpringSession集成配置
#### 在pom.xml文件中，添加Spring Session相关的依赖
<!-- Spring session redis 依赖start -->
<dependency>
<groupId>org.springframework.session</groupId>
<artifactId>spring-session-data-redis</artifactId>
<version>1.3.1.RELEASE</version>
</dependency>
<!-- Spring session redis 依赖end -->
<!-- spring web模块依赖 start -->
<dependency>
<groupId>org.springframework</groupId>
<artifactId>spring-web</artifactId>
<version>4.3.16.RELEASE</version>
</dependency>
<!-- spring web模块依赖end -->
#### 在web.xml文件中配置springSessionRepositoryFilter过滤器
<filter>
<filter-name>springSessionRepositoryFilter</filter-name>
<filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
</filter>
<filter-mapping>
<filter-name>springSessionRepositoryFilter</filter-name>
<url-pattern>/*</url-pattern>
</filter-mapping>
#### 在web.xml文件中加载Spring配置文件
<context-param>
<param-name>contextConfigLocation</param-name>
<param-value>classpath:applicationContext.xml</param-value>
</context-param>
<listener>
<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
#### 创建applicationContext-session.xml
##### 配置一个RedisHttpSessionConfiguration类
<context:annotation-config/>：用于激活已经在Spring容器中注册的bean或者注解，因为我们通过容器创建的bean中，底层有可能使用了其它的注解，我们通过<context:component-scan>就不能指定具体的包了，所以可以使用<context:annotation-config/>激活
<!-- spring注解、bean的处理器 -->
<context:annotation-config/> 
<!-- Spring session 的配置类 -->
<bean class="org.springframework.session.data.redis.config.annotation.web.http.RedisHttpSessionConfiguration"/>
##### 配置Spring-data-redis
<!-- 配置jedis连接工厂，用于连接redis -->
<bean id="jedisConnectionFactory" class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
<property name="hostName" value="${redis.hostName}"/>
<property name="port" value="${redis.port}"/>
<property name="password" value="${redis.password}"/>
<property name="usePool" value="${redis.usePool}"/>
<property name="timeout" value="${redis.timeout}"/>
</bean> 
<!--读取redis.properties属性配置文件-->
<context:property-placeholder location="classpath:redis.properties"/>
#### 配置redis.properties文件
redis.hostName=192.168.235.128
redis.port=6379
redis.password=123456
redis.usePool=true
redis.timeout=15000
#### 在applicationContext.xml中导入applicationContext-session.xml
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485854933-ce6d3aee-f812-477f-ab7e-0baf7ed27991.png#align=left&display=inline&height=171&margin=%5Bobject%20Object%5D&originHeight=171&originWidth=919&status=done&style=none&width=919)


点击config将这两个配置文件进行关联
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485855309-9886f645-d133-4352-9317-78538a41d571.png#align=left&display=inline&height=31&margin=%5Bobject%20Object%5D&originHeight=31&originWidth=974&status=done&style=none&width=974)


![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485855845-6a36694e-4466-40f7-8cf9-d4b442640bef.png#align=left&display=inline&height=236&margin=%5Bobject%20Object%5D&originHeight=236&originWidth=810&status=done&style=none&width=810)


### 部署测试
#### 思路
为了演示session的共享，我们这里配置两个tomcat服务器，端口号分别为9100和9200，将我们上面创建好的项目分别部署到这两台服务器上。一台服务器执行放session，另一台服务器执行取session的操作
#### 启动Linux上的redis服务器
#### 启动两台tomcat服务器

- 在浏览器中访问tomcat9100服务器的setSession
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485856340-1fc3f1d7-a9c9-4f4d-9178-fdf1036080b7.png#align=left&display=inline&height=133&margin=%5Bobject%20Object%5D&originHeight=133&originWidth=729&status=done&style=none&width=729)
- 

- 在浏览器中访问tomcat9200服务器的getSession
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485856856-ff91a39e-688a-4641-b343-e73f3f84882c.png#align=left&display=inline&height=105&margin=%5Bobject%20Object%5D&originHeight=105&originWidth=669&status=done&style=none&width=669)
- 

#### 分析
tomcat9200服务器上的项目可以访问tomcat9100上的session，说明session共享成功
#### 进一步验证
打开Resis客户端工具（RedisDesktopManager），查看Redis里面的session数据
其实标准的redis的key格式就是用冒号分割，客户端工具会以目录的形式展示
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485857409-e08eb257-c291-4f1a-97fb-f188aad50456.png#align=left&display=inline&height=174&margin=%5Bobject%20Object%5D&originHeight=174&originWidth=1131&status=done&style=none&width=1131)


# Spring Session常见的应用场景
## 同域名下相同项目（集群环境）实现Session共享
在同一个域名下，比如：[www.p2p.com](http://www.p2p.com)
同一个项目，部署了多台tomcat，这就是典型的集群。我们的入门案例就属于这种应用场景，只不过在实际开发的过程中，我们如果存在了tomcat集群，那么肯定会使用nginx进行负载均衡，那么这种情况下我们该如何处理。
### 案例设计思路
我们将上一个阶段的p2p项目实现集群部署下的Session共享，因为我们只是演示Session共享，所以我们试用一个简易版本的p2p，在我给大家提供的资料中，该p2p中只包含p2p和dataservice，在Linux服务器上，我们准备三台tomcat，其中两台部署p2p，并实现session共享，另一台部署dataservice
### 架构图
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485857879-c9516860-56b9-4390-bcc0-8b7e21879156.png#align=left&display=inline&height=369&margin=%5Bobject%20Object%5D&originHeight=369&originWidth=759&status=done&style=none&width=759)


### 实现步骤
#### 使用Xftp将p2p上传到tomcat9100和9200的webapps目录下
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485858416-b467e298-c1ff-4e8e-b56b-917312cb463f.png#align=left&display=inline&height=387&margin=%5Bobject%20Object%5D&originHeight=387&originWidth=1357&status=done&style=none&width=1357)


![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485858939-a6926559-5d2b-43e5-9341-2bf532bbf380.png#align=left&display=inline&height=336&margin=%5Bobject%20Object%5D&originHeight=336&originWidth=1353&status=done&style=none&width=1353)


#### 使用Xftp将dataservice上传到tomcat9300的webapps目录下
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485859484-5fe1a2a6-eac6-42fe-8003-d67568347ca0.png#align=left&display=inline&height=325&margin=%5Bobject%20Object%5D&originHeight=325&originWidth=1363&status=done&style=none&width=1363)


#### 使用资源下的SQL脚本，重新创建数据库的表
因为目前这个p2p的项目表结构和上一个阶段的稍微有些区别，所以我们这里更新一下
##### 启动mysql数据库
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485859943-9ca1cf3a-2e9f-49a7-badb-14cc001b6290.png#align=left&display=inline&height=76&margin=%5Bobject%20Object%5D&originHeight=76&originWidth=512&status=done&style=none&width=512)


##### 通过MySQL客户端工具Navivat创建新的库
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485860411-218d2ac4-9d71-4d1d-9bd9-edbb67549a5e.png#align=left&display=inline&height=391&margin=%5Bobject%20Object%5D&originHeight=391&originWidth=317&status=done&style=none&width=317)


##### 指定数据库名字为p2p2，字符集编码为utf-8
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485861022-257f0eae-f5ae-4c5c-af32-54718dc8b9d8.png#align=left&display=inline&height=398&margin=%5Bobject%20Object%5D&originHeight=398&originWidth=456&status=done&style=none&width=456)


##### 新建查询，执行p2p-data.sql脚本
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485861567-1cb51aef-3210-4566-a1be-0a834cf004ef.png#align=left&display=inline&height=654&margin=%5Bobject%20Object%5D&originHeight=654&originWidth=1337&status=done&style=none&width=1337)


##### 执行成功后，表结构如下
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485862067-a31920f8-d965-4899-b6b2-cfbb79d7e14a.png#align=left&display=inline&height=447&margin=%5Bobject%20Object%5D&originHeight=447&originWidth=1087&status=done&style=none&width=1087)


#### 通过Xftp工具连接Linux，修改tomcat9300下的dataservice的连接信息
##### 使用记事本打开，修改redis.properties，保存
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485862622-b2a1e92f-f0cf-4e17-89f4-8ffb9e00b24e.png#align=left&display=inline&height=485&margin=%5Bobject%20Object%5D&originHeight=485&originWidth=678&status=done&style=none&width=678)


##### 修改datasource.properties，保存
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485863031-b31c0bbd-8c36-4609-859e-c8407cfe654c.png#align=left&display=inline&height=492&margin=%5Bobject%20Object%5D&originHeight=492&originWidth=788&status=done&style=none&width=788)


##### 修改applicationContext-dubbo-provide.xml注册中心的地址，并保存
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485863627-e7f79ecd-5890-4d74-b1c9-5d6ead726fe1.png#align=left&display=inline&height=400&margin=%5Bobject%20Object%5D&originHeight=400&originWidth=1017&status=done&style=none&width=1017)


#### 通过Xftp工具连接Linux，修改tomcat9100下的p2p的连接信息
这里只需要修改applicationContext-dubbo-consumer.xml文件中zk注册中心的地址即可
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485864048-ef4ad986-8c5f-46b4-aba0-5cf8ea664877.png#align=left&display=inline&height=400&margin=%5Bobject%20Object%5D&originHeight=400&originWidth=931&status=done&style=none&width=931)


#### 通过Xftp工具连接Linux，修改tomcat9200下的p2p的连接信息
这里只需要修改applicationContext-dubbo-consumer.xml文件中zk注册中心的地址即可
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485864399-b74d0763-b253-42c7-9a79-fac07cc11564.png#align=left&display=inline&height=523&margin=%5Bobject%20Object%5D&originHeight=523&originWidth=999&status=done&style=none&width=999)


#### 确保Linux系统上的各应用服务器启动
注意：先通过ps –ef | grep XXX命令查看，如果已经启动，就不需要再启动了
##### 启动ZooKeeper服务器
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485864722-7af3305f-fb0d-4410-b42a-cdff7ceef2fe.png#align=left&display=inline&height=236&margin=%5Bobject%20Object%5D&originHeight=236&originWidth=904&status=done&style=none&width=904)


##### 启动MySQL服务器
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485865259-e3d86046-3502-4295-b7ab-44e60ad416f8.png#align=left&display=inline&height=351&margin=%5Bobject%20Object%5D&originHeight=351&originWidth=1041&status=done&style=none&width=1041)


##### 启动Redis服务器
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485865775-10c4f106-fc48-4beb-b21a-307a1be9af5f.png#align=left&display=inline&height=101&margin=%5Bobject%20Object%5D&originHeight=101&originWidth=835&status=done&style=none&width=835)


##### 启动tomcat9300服务器（为了避免出错先关闭，再启动）
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485866321-9eed484c-0dc9-465b-8d94-7982349a6285.png#align=left&display=inline&height=218&margin=%5Bobject%20Object%5D&originHeight=218&originWidth=1080&status=done&style=none&width=1080)


##### 启动tomcat9100服务器（为了避免出错先关闭，再启动）
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485866780-67f5d625-e8f0-4d55-a2bf-1ff1ea01a01f.png#align=left&display=inline&height=234&margin=%5Bobject%20Object%5D&originHeight=234&originWidth=1077&status=done&style=none&width=1077)


##### 启动tomcat9200服务器（为了避免出错先关闭，再启动）
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485867266-21fa6a59-a1b9-4377-8d22-52f687997d40.png#align=left&display=inline&height=221&margin=%5Bobject%20Object%5D&originHeight=221&originWidth=1077&status=done&style=none&width=1077)


##### 直接访问tomcat的方式，在浏览器输入地址访问tomcat9100和tomcat9200
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485868446-b35e846d-5e9e-4018-9acc-745156a6772e.png#align=left&display=inline&height=673&margin=%5Bobject%20Object%5D&originHeight=673&originWidth=1350&status=done&style=none&width=1350)


![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485869945-acef4dd3-205c-4ebc-892a-3ceba732b4fb.png#align=left&display=inline&height=678&margin=%5Bobject%20Object%5D&originHeight=678&originWidth=1350&status=done&style=none&width=1350)


#### 使用Nginx对tomcat9100和tomcat9200进行负载均衡
##### 负载均衡的配置，这里使用的是轮询策略
**upstream www.p2p.com{**
**server 127.0.0.1:9100;**
**server 127.0.0.1:9200;**
**}**
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485870428-764da423-f6e8-440d-8c34-fbf94b888ae2.png#align=left&display=inline&height=98&margin=%5Bobject%20Object%5D&originHeight=98&originWidth=310&status=done&style=none&width=310)


##### location匹配的配置，注意：这里对静态资源的处理，我们暂时先注释掉
**location /p2p{**
**proxy_pass [http://www.p2p.com;](http://www.p2p.com;)**
**}**
**如果要是实现了静态代理，别忘了启动所有的nginx服务器（负载|代理）**
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485870921-fdfd9b3a-7280-45cc-9bb7-259760fd1444.png#align=left&display=inline&height=217&margin=%5Bobject%20Object%5D&originHeight=217&originWidth=772&status=done&style=none&width=772)


##### 重启Nginx
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485871420-51608af3-78af-482b-9375-657508e994c1.png#align=left&display=inline&height=279&margin=%5Bobject%20Object%5D&originHeight=279&originWidth=1073&status=done&style=none&width=1073)


##### 在浏览器中输入地址，直接访问Nginx服务器，实现负载均衡
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485872314-9693ba08-4082-4b60-ad96-327b04d9c09d.png#align=left&display=inline&height=725&margin=%5Bobject%20Object%5D&originHeight=725&originWidth=1349&status=done&style=none&width=1349)


#### Nginx对集群负载均衡之后，登录不成功，但是直接访问tomcat9100或者tomcat9200都是可以成功登录的（Session丢失）
账号：13700000000 密码：123456
**分析原因**
因为默认我们负载均衡使用的是轮询策略，每次发送请求给nginx服务器，都会切换tomcat服务器，这个时候没有使用任何session共享策略，所以登录不成功
#### Nginx对集群负载均衡之后，Session共享方案
##### 修改nginx.conf配置文件，将轮询策略修改为ip_hash
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485872616-d1339fb5-785f-409a-aeaf-9963c8e82f7a.png#align=left&display=inline&height=129&margin=%5Bobject%20Object%5D&originHeight=129&originWidth=357&status=done&style=none&width=357)


但是这种情况，一旦ip发生变化，或者某台服务器出现故障，会重新分配，不稳定
所以我们看下这种情况后，将ip_hash注释掉
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485873100-b374a264-a754-40bd-8fff-8b41fca0ea12.png#align=left&display=inline&height=120&margin=%5Bobject%20Object%5D&originHeight=120&originWidth=308&status=done&style=none&width=308)


##### 使用SpringSession
使用Spring Session实现session共享，我们不需要修改代码，只要修改一些配置文件即可，为了演示方便，我们直接使用Xftp修改已经发布到tomcat上的项目

- 向tomcat9100和tomcat9200的p2p项目中加jar包，这个jar包我已经准备好了
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485873758-5ab18b8f-0656-4bd5-99cf-000c2cba59e0.png#align=left&display=inline&height=512&margin=%5Bobject%20Object%5D&originHeight=512&originWidth=1357&status=done&style=none&width=1357)
- 

- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485874254-af2c4491-e93a-48b3-a615-a428b10b3c1b.png#align=left&display=inline&height=520&margin=%5Bobject%20Object%5D&originHeight=520&originWidth=1353&status=done&style=none&width=1353)
- 

- 修改tomcat9100和tomcat9200的p2p项目的web.xml配置文件，添加Spring Session过滤器，因为我们项目本身已经通过springMVC启动了容器，所以spring监听器不需要加了，直接从01-springsession-web中拷贝即可
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485874734-9db24935-355b-45de-b721-2267e4d18314.png#align=left&display=inline&height=550&margin=%5Bobject%20Object%5D&originHeight=550&originWidth=963&status=done&style=none&width=963)
- 

- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485875282-7231d8ae-0c4d-4dab-8672-72a3212de93f.png#align=left&display=inline&height=547&margin=%5Bobject%20Object%5D&originHeight=547&originWidth=979&status=done&style=none&width=979)
- 

- 将01-springsession-web项目中resources下的applicationContext-session.xml和redis.properties拷贝到tomcat9100和tomcat9200的p2p项目WEB-INF/classes下
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485875722-4c54b410-c4c3-4e49-a346-c157b260b94b.png#align=left&display=inline&height=277&margin=%5Bobject%20Object%5D&originHeight=277&originWidth=671&status=done&style=none&width=671)
- 

- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485876166-4ac51b9f-948c-423b-8073-d236eb4bcf63.png#align=left&display=inline&height=267&margin=%5Bobject%20Object%5D&originHeight=267&originWidth=677&status=done&style=none&width=677)
- 

- 修改tomcat9100和tomcat9200的p2p项目WEB-INF/classes下的applicationContext.xml文件，引入applicationContext-session.xml
- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485876456-c8da36aa-be69-4fee-af61-60cff772976e.png#align=left&display=inline&height=415&margin=%5Bobject%20Object%5D&originHeight=415&originWidth=685&status=done&style=none&width=685)
- 

- ![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485876773-5d184e9f-b046-40e6-9d51-b39bf29c24c9.png#align=left&display=inline&height=377&margin=%5Bobject%20Object%5D&originHeight=377&originWidth=686&status=done&style=none&width=686)
- 

- 重启三台tomcat服务器，浏览器访问进行登录测试，可以实现Session共享
## 同域名下不同项目实现Session共享
在同一个域名下，有多个不同的项目（项目的上下文根不一样）比如：
www.web.com/p2p
www.web.com/shop
如图：
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485877336-8b227d72-b230-453c-b8ff-70d9df8db510.png#align=left&display=inline&height=274&margin=%5Bobject%20Object%5D&originHeight=274&originWidth=649&status=done&style=none&width=649)


### 做法：设置Cookie路径为根/上下文
### 案例设计思路
在01-springsession-web项目的基础上，将本地tomcat9100的上下文根修改为p2p，将本地tomcat9200的上下文根修改为shop
### 实现步骤
#### 打开Edit Configurations进行配置
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485877773-174d04d0-0b2e-45fe-a21e-19fa05c514ec.png#align=left&display=inline&height=92&margin=%5Bobject%20Object%5D&originHeight=92&originWidth=163&status=done&style=none&width=163)


#### 在Deployment选项卡下，设置本地tomcat9100的Application context为/p2p
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485878246-ae217c34-3513-478b-b5ce-8448f2a7a45e.png#align=left&display=inline&height=250&margin=%5Bobject%20Object%5D&originHeight=250&originWidth=766&status=done&style=none&width=766)


#### 在Deployment选项卡下，设置本地tomcat9200的Application context为/shop
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485878786-9045961a-5de2-4f66-a4d2-804eb454dd1a.png#align=left&display=inline&height=239&margin=%5Bobject%20Object%5D&originHeight=239&originWidth=767&status=done&style=none&width=767)


#### 在idea中重新启动本地的两台tomcat服务器
#### 在浏览器中访问tomcat9100（p2p），设置session
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485879048-22b0f6e3-eaa0-4882-96f0-8bf36115bfac.png#align=left&display=inline&height=101&margin=%5Bobject%20Object%5D&originHeight=101&originWidth=642&status=done&style=none&width=642)


#### 在浏览器中访问tomcat9200（shop），获取session
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485879342-1a539b4b-113a-45e1-a885-0a723fb18275.png#align=left&display=inline&height=102&margin=%5Bobject%20Object%5D&originHeight=102&originWidth=744&status=done&style=none&width=744)


#### 分析Session共享失败原因
我们通过浏览器提供的开发人员工具可以发现，这两个请求的cookie的路径(path)不一致，虽然我们已经加了Spring Session共享机制，但是后台服务器认为这是两个不同的会话(session)，可以通过Redis客户端工具（Redis Destop Mananger）查看，先清空，然后访问，发现是维护了两个不同的session，所以不能实现共享
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485879877-457f6303-6d35-4f15-acbd-df19aad5cc3f.png#align=left&display=inline&height=189&margin=%5Bobject%20Object%5D&originHeight=189&originWidth=1366&status=done&style=none&width=1366)


#### 解决方案 设置Cookie路径为根/上下文
在applicationContext-session.xml文件中，加如下配置：
<!-- Spring session 的配置类 -->
<bean class="org.springframework.session.data.redis.config.annotation.web.http.RedisHttpSessionConfiguration">
<!--设置cookie的存放方式-->
<property name="cookieSerializer" ref="defaultCookieSerializer"/>
</bean>
<!--设置cookie的存放方式具体实现-->
<bean id="defaultCookieSerializer" class="org.springframework.session.web.http.DefaultCookieSerializer">
<property name="cookiePath" value="/"/>
</bean>
#### 在idea中重新启动本地的两台tomcat服务器
#### 在浏览器中访问tomcat9100（p2p），设置session
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485880382-d2aa6933-fc01-4623-adbe-8d3792a046d4.png#align=left&display=inline&height=101&margin=%5Bobject%20Object%5D&originHeight=101&originWidth=642&status=done&style=none&width=642)


#### 在浏览器中访问tomcat9200（shop），获取session
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485880613-d751bc64-2fae-456a-985c-42fac6ec4612.png#align=left&display=inline&height=94&margin=%5Bobject%20Object%5D&originHeight=94&originWidth=637&status=done&style=none&width=637)


**注意：测试的时候要先清空浏览器缓存**
## 同根域名不同二级子域名下的项目实现Session共享
同一个根域名，不同的二级子域名
比如：
www.web.com
beijing.web.com
nanjing.web.com
如图：
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485880956-efecfa2e-e533-43e5-8df9-92e0876fee68.png#align=left&display=inline&height=345&margin=%5Bobject%20Object%5D&originHeight=345&originWidth=615&status=done&style=none&width=615)


### 做法

- 设置Cookie路径为根/上下文，项目名一样的话，此步骤可以省略
- 设置cookie的域名为根域名 web.com
### 案例设计思路
在01-springsession-web项目的基础上，将本地tomcat9100的上下文根修改为p2p，将本地tomcat9200的上下文根修改为shop；在本机host文件中修改127.0.0.1的映射关系模拟不同的域名访问
### 实现步骤
#### 延续上面的案例的配置，两台本地tomcat服务器9100和9200，上下文根分别是p2p和shop
#### 修改本地hosts文件，加入如下配置
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485881417-fbd9cb1d-9922-472f-b254-5b6c87f58035.png#align=left&display=inline&height=26&margin=%5Bobject%20Object%5D&originHeight=26&originWidth=227&status=done&style=none&width=227)


![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485881605-a8974894-915e-4cc0-b1dc-0f54321e08d9.png#align=left&display=inline&height=72&margin=%5Bobject%20Object%5D&originHeight=72&originWidth=336&status=done&style=none&width=336)


#### 在idea中重新启动本地的两台tomcat服务器
#### 在浏览器中访问tomcat9100（p2p），设置session
**注意，这里不再使用localhost访问，而是使用我们映射的域名**
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485881900-14f5cdc8-e95a-4188-a57f-14963b613969.png#align=left&display=inline&height=102&margin=%5Bobject%20Object%5D&originHeight=102&originWidth=584&status=done&style=none&width=584)


#### 在浏览器中访问tomcat9200（shop），获取session
**注意，这里也不再使用localhost访问，而是使用我们映射的域名**
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485882207-282fe199-2f25-481f-a14a-bca42aa22682.png#align=left&display=inline&height=108&margin=%5Bobject%20Object%5D&originHeight=108&originWidth=622&status=done&style=none&width=622)


#### 分析Session共享失败原因
我们通过浏览器提供的开发人员工具可以发现，虽然这两个cookie的路径(path)都设置为了“/”，但是这两个cookie的域名不一致，虽然我们已经加了Spring Session共享机制，但是后台服务器同样认为这是两个不同的会话(session)，可以通过Redis客户端工具（Redis Destop Mananger）查看，先清空，然后访问，发现是维护了两个不同的session，所以不能实现共享，也就是说后台区分是否同一个session和路径和域名有关。
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485882955-06219d9f-a18a-45c4-9cfc-073a70c971ee.png#align=left&display=inline&height=48&margin=%5Bobject%20Object%5D&originHeight=48&originWidth=1366&status=done&style=none&width=1366)


![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485883180-7e6dd6f1-e096-42d4-9e86-b2a851f6c3d7.png#align=left&display=inline&height=73&margin=%5Bobject%20Object%5D&originHeight=73&originWidth=1360&status=done&style=none&width=1360)


#### 解决方案 设置Cook ie的域名为根域名 web.com
在applicationContext-session.xml文件中，加如下配置：
**注意:域名要和hosts文件中配置的域名后面一样**
<!--设置cookie的存放方式具体实现-->
<bean id="defaultCookieSerializer" class="org.springframework.session.web.http.DefaultCookieSerializer">
<property name="cookiePath" value="/"/>
<property name="domainName" value="web.com"/>
</bean>
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485883545-a0b07dd4-c706-4b12-a939-640e0d4777ab.png#align=left&display=inline&height=144&margin=%5Bobject%20Object%5D&originHeight=144&originWidth=1045&status=done&style=none&width=1045)


#### 在idea中重新启动本地的两台tomcat服务器
#### 在浏览器中访问tomcat9100（p2p），设置session
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485883781-880c766b-75ce-4a44-aa26-d5fff60de09e.png#align=left&display=inline&height=96&margin=%5Bobject%20Object%5D&originHeight=96&originWidth=603&status=done&style=none&width=603)


#### 在浏览器中访问tomcat9200（shop），获取session
![](https://cdn.nlark.com/yuque/0/2021/png/21566525/1620485883994-a93d46a2-c6df-4e30-a775-f8948ce4a9ff.png#align=left&display=inline&height=98&margin=%5Bobject%20Object%5D&originHeight=98&originWidth=580&status=done&style=none&width=580)


**注意：清空浏览器缓存**
## 单点登录（了解）
不同根域名下的项目实现Session共享，
比如阿里巴巴这样的公司，有多个业务线，多个网站，用户在一个网站登录，那么其他网站也会是登录了的状态，比如：登录了淘宝网，则天猫网也是登录的；
www.taobao.com
www.tmall.com
比如：
www.web.com
www.p2p.com
www.dai.com
对于不同根域名的场景，要实现一处登录，处处登录，**Spring Session不支持**
单点登录(Single Sign On)，简称为 SSO，是流行的企业业务整合的解决方案之一，SSO是指在多个应用系统中，用户只需要登录一次就可以访问所有相互信任的应用系统
# Spring Session的执行流程（源码分析）

- 页面请求被全局的过滤器org.springframework.web.filter.DelegatingFilterProxy过滤
- 全局的过滤器是一个代理过滤器，它不执行真正的过滤逻辑，它代理了一个Spring容器中的名为：springSessionRepositoryFilter 的一个过滤器
- 代理的这个 springSessionRepositoryFilter 过滤器是从spring容器中获取的，真正执行过滤逻辑的是 SessionRepositoryFilter
- \@Bean注解
- 相当于:
- <bean id="springSessionRepositoryFilter" class="xx.xxx.xx.SessionRepositoryFilter">
- ........
- </bean>
- 该SessionRepositoryFilter过滤器覆盖了原来servlet中的request和response接口中定义的操作session方法，替换成自己的session方法
- 在过滤的时候，总是会执行一个finally语句块，在finally中提交session，保存到Redis

session以hash结构存放在redis

- 默认的过期时间30分钟
- <!-- Spring session 的配置类 -->
<bean class="org.springframework.session.data.redis.config.annotation.web.http.RedisHttpSessionConfiguration">
<!--设置session过期时间，单位是秒，默认是30分钟-->
<property name="maxInactiveIntervalInSeconds" value="3600"/>
<!--设置cookie的存放方式-->
<property name="cookieSerializer" ref="defaultCookieSerializer"/>
</bean>
