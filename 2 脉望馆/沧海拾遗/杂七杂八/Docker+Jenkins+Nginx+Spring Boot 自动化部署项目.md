---
link: http://mp.weixin.qq.com/s?__biz=MzI5OTIyMjQxMA==&mid=2247484761&idx=1&sn=308a4fcac829eee3bb1393dd0432a945&chksm=ec9891bcdbef18aad18d667c4230f165398f48d3260e34c62f8f7bdeae8dcf24c3cd49781212#rd
title: Docker+Jenkins+Nginx+Spring Boot 自动化部署项目
description: null
keywords: null
author: null
date: null
publisher: 微信公众平台
stats: paragraph=201 sentences=87, words=619
---
今天跟大家分享常用的Docker+Jenkins+Nginx+Spring Boot 自动化部署项目的知识。

**1** **Docker+Jenkins+Nginx+Spring Boot 自动化部署项目**

写在前面

Docker通过linux的namespace实现资源隔离、cgroups实现资源控制，通过写时复制机制(copy-on-write)实现了高效的文件操作，在实际开发中可用于提供一次性的环境、微服务架构的搭建、统一环境的部署。
虽然Docker已经是风靡全球的容器技术了，统一环境避免环境问题上是Docker的主要吸引点之一，但使用时详细还是会遇到不少问题的，比如个人搭建时曾思考过这些问题：Jenkins官网既然有Docker上安装Jenkins的流程了，那我该怎么使用Jenkins容器呢？如果使用Jenkins容器，我该怎么通过Jenkins容器部署SpringBoot项目？是通过Jenkins容器与SpringBoot容器中的文件交互进行项目部署吗？这能做到吗？又或是把SpringBoot项目放到Jenkins容器中管理，那Jenkins中又要安装git、maven等一堆东西，这一点都不方便。使用IDEA Docker插件都可以直接本地连接到服务器的Docker创建镜像并运行容器了，为什么还需要Jenkins？个人在实际搭建部署中也找到了与上相对应的答案：如果使用Jenkins容器，这将使得部署更加麻烦，因Jenkins往往需要配置Maven、git等一系列变量，应另寻出路。Jenkins既然是一款脚本CI工具，而Docker也有自己的脚本，我应该将Docker脚本集成到Docker中这方面考虑。在实际开发中，Jenkins可能不仅需要项目的部署，还需要进行开发人员的鉴权，如开发人员A只能查看部署指定项目，管理员可以查看部署所有项目，但Docker主要用于镜像构建与容器运行，无法像Jenkins一样获取github/gitlab代码，也无法进行开发人员的鉴权，所以Docker可以在Jenkins中只扮演简化部署过程的一个角色。虽然IDEA插件可以直接把本地打包成功的项目部署服务器Dcoker并创建镜像运行容器，但为了安全还需要创建Docker CA认证下载到本地再进行服务器上的Docker连接，十分不便捷。当探索到自我提问的答案时，便确定了各组件的主要职责：Jenkins：接收项目更新信息并进行项目打包与Docker脚本的执行Docker：安装所需应用镜像与运行容器git：项目信息同步搭建环境流程：

1.  安装JDK
2.  安装Maven
3.  安装git
4.  安装Jenkins(该步骤之前的可参考Jenkins安装并部署Java项目完整流程)如有权限问题可将/etc/sysconfig/jenkins文件JENKINS_USER修改为root或手动赋权
5.  Centos安装Docker
6.  安装DockerCompose

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-composesudo chmod +x /usr/local/bin/docker-composesudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-composedocker-compose --version
```

使用DockerCompose可省去容器增多时需多次执行docker run的麻烦配置文件1. SpringBoot项目Dockerfile

```
<span class="code-snippet_outer"><span class="code-snippet__attr">FROM</span> <span class="code-snippet__string">java:8</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">MAINTAINER</span> <span class="code-snippet__string">Wilson</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">ENV</span> <span class="code-snippet__string">TZ=Asia/Shanghai</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">RUN</span> <span class="code-snippet__string">ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">VOLUME</span> <span class="code-snippet__string">/ecs-application-docker</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">RUN</span> <span class="code-snippet__string">mkdir /app</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">WORKDIR</span> <span class="code-snippet__string">/app</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">COPY</span> <span class="code-snippet__string">target/ecs-application.jar ecs-application.jar</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">EXPOSE</span> <span class="code-snippet__string">9090</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">ENTRYPOINT</span> <span class="code-snippet__string">["java","-jar","ecs-application.jar"]</span></span>
```

2. 配置docker-compose.yml

```
<span class="code-snippet_outer"><span class="code-snippet__attr">version</span>: <span class="code-snippet__string">'3.7'</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">services</span>:</span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">app</span>:</span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">restart</span>: <span class="code-snippet__string">always</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">build</span>: <span class="code-snippet__string">./</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">hostname</span>: <span class="code-snippet__string">docker-spring-boot</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">container_name</span>: <span class="code-snippet__string">docker-spring-boot</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">image</span>: <span class="code-snippet__string">docker-spring-boot/latest</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">volumes</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/app:/app</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">nginx</span>:</span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">depends_on</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">app</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">container_name</span>: <span class="code-snippet__string">docker-nginx</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">hostname</span>: <span class="code-snippet__string">docker-nginx</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">image</span>: <span class="code-snippet__string">nginx:1.17.6</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">environment</span>:</span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">TZ</span>: <span class="code-snippet__string">Asia/Shanghai</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">restart</span>: <span class="code-snippet__string">always</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">expose</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">80</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">ports</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">80:80</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">links</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">app</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">volumes</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/nginx/nginx.conf:/etc/nginx/nginx.conf</span></span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/nginx/conf.d:/etc/nginx/conf.d</span></span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/nginx/logs:/var/log/nginx</span></span>
```

3. Nginx

* ./volumes/nginx/nginx.conf

```
<span class="code-snippet_outer"><span class="code-snippet__attr">user</span> <span class="code-snippet__string">nginx;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">worker_processes</span> <span class="code-snippet__string">2; #&#x8BBE;&#x7F6E;&#x503C;&#x548C;CPU&#x6838;&#x5FC3;&#x6570;&#x4E00;&#x81F4;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">error_log</span> <span class="code-snippet__string">/etc/nginx/error.log crit; #&#x65E5;&#x5FD7;&#x4F4D;&#x7F6E;&#x548C;&#x65E5;&#x5FD7;&#x7EA7;&#x522B;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">pid</span> <span class="code-snippet__string">/etc/nginx/nginx.pid;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">events</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">{</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">use</span> <span class="code-snippet__string">epoll;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">worker_connections</span> <span class="code-snippet__string">65535;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">}</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">http{</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">include</span> <span class="code-snippet__string">mime.types;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">default_type</span> <span class="code-snippet__string">application/octet-stream;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">log_format</span> <span class="code-snippet__string">main '$remote_addr - $remote_user [$time_local] "$request" '</span></span>
```

```
<span class="code-snippet_outer">                     <span class="code-snippet__string">$body_bytes_sent "$http_referer" '</span></span>
```

```
<span class="code-snippet_outer">                     <span class="code-snippet__string">"$http_x_forwarded_for" "$http_cookie"';</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">access_log</span> <span class="code-snippet__string">/var/log/nginx/access.log main;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">server_names_hash_bucket_size</span> <span class="code-snippet__string">128;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">client_header_buffer_size</span> <span class="code-snippet__string">32k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">large_client_header_buffers</span> <span class="code-snippet__string">4 32k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">client_max_body_size</span> <span class="code-snippet__string">8m;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">sendfile</span> <span class="code-snippet__string">on;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">tcp_nopush</span> <span class="code-snippet__string">on;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">keepalive_timeout</span> <span class="code-snippet__string">60;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">tcp_nodelay</span> <span class="code-snippet__string">on;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">fastcgi_connect_timeout</span> <span class="code-snippet__string">300;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">fastcgi_send_timeout</span> <span class="code-snippet__string">300;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">fastcgi_read_timeout</span> <span class="code-snippet__string">300;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">fastcgi_buffer_size</span> <span class="code-snippet__string">64k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">fastcgi_buffers</span> <span class="code-snippet__string">4 64k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">fastcgi_busy_buffers_size</span> <span class="code-snippet__string">128k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">fastcgi_temp_file_write_size</span> <span class="code-snippet__string">128k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">gzip</span> <span class="code-snippet__string">on;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">gzip_min_length</span> <span class="code-snippet__string">1k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">gzip_buffers</span> <span class="code-snippet__string">4 16k;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">gzip_http_version</span> <span class="code-snippet__string">1.0;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">gzip_comp_level</span> <span class="code-snippet__string">2;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">gzip_types</span> <span class="code-snippet__string">text/plain application/x-javascript text/css application/xml;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">gzip_vary</span> <span class="code-snippet__string">on;</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">include</span> <span class="code-snippet__string">/etc/nginx/conf.d/*.conf;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">}</span></span>
```

./volumes/nginx/conf.d目录下的default.conf

```
<span class="code-snippet_outer"><span class="code-snippet__attr">upstream</span> <span class="code-snippet__string">application {</span></span>
```

```
<span class="code-snippet_outer">   <span class="code-snippet__attr">server</span> <span class="code-snippet__string">docker-spring-boot:8080;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">}</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">server{</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">listen</span> <span class="code-snippet__string">80;#&#x76D1;&#x542C;&#x7AEF;&#x53E3;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">server_name</span> <span class="code-snippet__string">localhost;#&#x57DF;&#x540D;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">access_log</span> <span class="code-snippet__string">/var/log/nginx/nginx-spring-boot.log;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">location</span> <span class="code-snippet__string">/ {</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_pass</span> <span class="code-snippet__string">http://application;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">Host $host:$server_port;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">X-Real-IP $remote_addr;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">REMOTE-HOST $remote_addr;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">X-Forwarded-For $proxy_add_x_forwarded_for;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">}</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">}</span></span>
```

Jenkins部署执行流程maven打包Spring Boot项目为project.jar，根据是否以第一次项目部署执行以下不同的流程：如当前挂载卷已含项目jar(即非第一次运行)，则运行以下步骤:拷贝project.jar覆盖挂载卷中的project.jar重新运行SpringBoot项目容器如当前挂载卷不含项目jar(即非第一次运行)，则运行以下步骤:创建挂载卷目录拷贝project.jar到挂载卷中通过docker-compose读取docker-compose.yml配置创建镜像启动容器Jenkins脚本(如果Nginx配置更改较多也可添加Nginx容器重启指令)：

```
<span class="code-snippet_outer"><span class="code-snippet__attr">cd</span> <span class="code-snippet__string">/var/lib/jenkins/workspace/docker-spring-boot/spring-boot-nginx-docker-demo</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">mvn</span> <span class="code-snippet__string">clean package</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">if</span> <span class="code-snippet__string">[ -e "./volumes/app/docker-spring-boot.jar" ]</span></span>
```

```
<span class="code-snippet_outer"> <span class="code-snippet__attr">then</span> <span class="code-snippet__string">rm -f ./volumes/app/docker-spring-boot.jar \</span></span>
```

```
<span class="code-snippet_outer">&& cp ./target/docker-spring-boot.jar ./volumes/app/docker-spring-boot.jar \</span>
```

```
<span class="code-snippet_outer">&& docker restart docker-spring-boot \</span>
```

```
<span class="code-snippet_outer"> && echo "update restart success"</span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">else</span> <span class="code-snippet__string">mkdir volumes/app -p \</span></span>
```

```
<span class="code-snippet_outer">&& cp ./target/docker-spring-boot.jar ./volumes/app/docker-spring-boot.jar \</span>
```

```
<span class="code-snippet_outer">&& docker-compose -p docker-spring-boot up -d \</span>
```

```
<span class="code-snippet_outer">&& echo "first start"</span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">fi</span></span>
```

docker-compose up指令可以进行镜像的安装，所以也省去了只用docker指令时需要提前准备好镜像相关指令的麻烦。
查看容器是否皆已启动:docker ps

SpringBoot容器运行结果查看：如容器开放了8080端口则可通过http://url:8080/swagger-ui.html测试，也可通过查看Jenkins工作空间下/volumes/app的SpringBoot日志校验结果(SpringBoot日志的路径配置个人设置为app/logs目录下，前文已把容器中的app目录挂载到当前项目的volumes/app目录下)

Nginx容器运行结果查看：

访问http://url/swagger-ui.html测试是否Nginx容器已成功连通SpringBoot容器并进行了反向代理，也可通过查看Jenkins工作空间下/volumes/nginx/logs的Nginx日志校验结果

添加或删除controller接口再进行推到git，查看更改的接口是否可访问

如需将SpringBoot通过容器集群搭建，只需进行以下更改：docker-compose.yml添加SpringBoot项目冗余，更改冗余容器名，区分日志挂载路径，冗余项目更改容器名

```
<span class="code-snippet_outer"><span class="code-snippet__attr">version</span>: <span class="code-snippet__string">'3.7'</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">services</span>:</span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">app</span>:</span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">restart</span>: <span class="code-snippet__string">always</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">build</span>: <span class="code-snippet__string">./</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">hostname</span>: <span class="code-snippet__string">docker-spring-boot</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">container_name</span>: <span class="code-snippet__string">docker-spring-boot</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">image</span>: <span class="code-snippet__string">docker-spring-boot/latest</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">volumes</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/app/docker-spring-boot.jar:/app/docker-spring-boot.jar</span></span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/app/logs:/app/logs</span></span>
```

```
<span class="code-snippet_outer">  :</span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">restart</span>: <span class="code-snippet__string">always</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">build</span>: <span class="code-snippet__string">./</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">hostname</span>: <span class="code-snippet__string">docker-spring-boot</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">container_name</span>: <span class="code-snippet__string">docker-spring-boot-bak</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">image</span>: <span class="code-snippet__string">docker-spring-boot/latest</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">volumes</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/app/docker-spring-boot.jar:/app/docker-spring-boot.jar</span></span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/app/logs-bak:/app/logs</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">nginx</span>:</span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">depends_on</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">app</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">container_name</span>: <span class="code-snippet__string">docker-nginx</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">hostname</span>: <span class="code-snippet__string">docker-nginx</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">image</span>: <span class="code-snippet__string">nginx:1.17.6</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">environment</span>:</span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">TZ</span>: <span class="code-snippet__string">Asia/Shanghai</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">restart</span>: <span class="code-snippet__string">always</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">expose</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">80</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">ports</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">80:80</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">links</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">app</span></span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">app-bak</span></span>
```

```
<span class="code-snippet_outer">    <span class="code-snippet__attr">volumes</span>:</span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/nginx/nginx.conf:/etc/nginx/nginx.conf</span></span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/nginx/conf.d:/etc/nginx/conf.d</span></span>
```

```
<span class="code-snippet_outer">       <span class="code-snippet__string">./volumes/nginx/logs:/var/log/nginx</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">nginx&#x66F4;&#x6539;default.conf&#x7684;upstream&#xFF0C;&#x6DFB;&#x52A0;&#x5197;&#x4F59;&#x5BB9;&#x5668;&#x914D;&#x7F6E;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">upstream</span> <span class="code-snippet__string">application {</span></span>
```

```
<span class="code-snippet_outer">   <span class="code-snippet__attr">server</span> <span class="code-snippet__string">docker-spring-boot:8080 fail_timeout=2s max_fails=2 weight=1;</span></span>
```

```
<span class="code-snippet_outer">   <span class="code-snippet__attr">server</span> <span class="code-snippet__string">docker-spring-boot-bak:8080 fail_timeout=2s max_fails=2 weight=1;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">}</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">server{</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">listen</span> <span class="code-snippet__string">80;#&#x76D1;&#x542C;&#x7AEF;&#x53E3;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">server_name</span> <span class="code-snippet__string">localhost;#&#x57DF;&#x540D;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">access_log</span> <span class="code-snippet__string">/var/log/nginx/nginx-spring-boot.log;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">location</span> <span class="code-snippet__string">/ {</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_pass</span> <span class="code-snippet__string">http://application;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_connect_timeout</span> <span class="code-snippet__string">2s;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">Host $host:$server_port;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">X-Real-IP $remote_addr;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">REMOTE-HOST $remote_addr;</span></span>
```

```
<span class="code-snippet_outer">      <span class="code-snippet__attr">proxy_set_header</span> <span class="code-snippet__string">X-Forwarded-For $proxy_add_x_forwarded_for;</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">}</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">}</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">Jenkins&#x6DFB;&#x52A0;&#x5197;&#x4F59;&#x5BB9;&#x5668;&#x91CD;&#x542F;&#x811A;&#x672C;</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">BUILD_ID</span>=<span class="code-snippet__string">DONTKILLME</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">cd</span> <span class="code-snippet__string">/var/lib/jenkins/workspace/docker-spring-boot/spring-boot-nginx-docker-demo</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">mvn</span> <span class="code-snippet__string">clean package</span></span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">if</span> <span class="code-snippet__string">[ -e "./volumes/app/docker-spring-boot.jar" ]</span></span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">then</span> <span class="code-snippet__string">rm -f ./volumes/app/docker-spring-boot.jar \</span></span>
```

```
<span class="code-snippet_outer">        && cp ./target/docker-spring-boot.jar ./volumes/app/docker-spring-boot.jar \</span>
```

```
<span class="code-snippet_outer">    && docker-compose -p docker-spring-boot up -d \</span>
```

```
<span class="code-snippet_outer">    && docker restart docker-spring-boot \</span>
```

```
<span class="code-snippet_outer">    && docker restart docker-spring-boot-bak \</span>
```

```
<span class="code-snippet_outer">    && docker restart docker-nginx \</span>
```

```
<span class="code-snippet_outer">        && echo "update restart success"</span>
```

```
<span class="code-snippet_outer">  <span class="code-snippet__attr">else</span> <span class="code-snippet__string">mkdir volumes/app -p \</span></span>
```

```
<span class="code-snippet_outer">        && cp ./target/docker-spring-boot.jar ./volumes/app/docker-spring-boot.jar \</span>
```

```
<span class="code-snippet_outer">    && docker-compose -p docker-spring-boot up -d \</span>
```

```
<span class="code-snippet_outer">        && echo "first start"</span>
```

```
<span class="code-snippet_outer"><span class="code-snippet__attr">fi</span></span>
```

测试集群效果：

* volumes/app放置了不同容器的日志，如该例子的logs、logs-bak
* 停止任一SpringBoot容器docker stop docker-spring-boot，仍可通过url/api通过Nginx访问

可以看出容器配置集群的以下优点：



* 安全性高，每一个应用都只属一个容器，通过特定配置才可与主机、其它容器交互
* 统一配置文件，简单粗暴的方式解决端口、路径、版本等配置问题，如该项目即使运行了2个8080端口的SpringBoot容器而不需担心端口的冲突、暴露问题，一切都在容器内解决
* 省略手动应用安装，易于迁移，由于版本、配置、环境等都已配置在Docker的配置文件中，所以不用担心更换机器后出现的各种配置、环境问题，且通过镜像拉取与容器运行可以省略如Nginx、Redis、Mysql等应用的安装与配置

```
如有收获请划至底部点击"在看"支持，谢谢！关注马士兵每天分享技术干货点赞是最大的支持
```
