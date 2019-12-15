#设置继承镜像
FROM centos:6.6

#作者的信息
MAINTAINER docker_user （renzhiyuan@docker.com）

#Zookeeper和jdk标准化版本
#ENV JAVA_VERSION="1.8.0_151"
#ENV ZK_VERSION="3.4.12"
ENV ZK_JDK_HOME=/app
ENV JAVA_HOME=/app/jdk1.8.0_151
ENV ZK_HOME=/app/zookeeper
ENV LANG=en_US.utf8

#基础使用包安装配置
#RUN yum makecache
#RUN yum install lsof yum-utils lrzsz net-tools nc -y &>/dev/null

#创建安装目录
RUN mkdir $ZK_JDK_HOME  

#权限和变量
RUN chown -R root.root $ZK_JDK_HOME && chmod -R 755 $ZK_JDK_HOME

#安装配置JDK 
ADD jdk-8u151-linux-x64.tar.gz /app
RUN echo "export JAVA_HOME=/app/jdk1.8.0_151" >>/etc/profile 
RUN echo "export PATH=\$JAVA_HOME/bin:\$PATH" >>/etc/profile 
RUN echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >>/etc/profile && source /etc/profile

#安装配置zookeeper-3.4.12,相关目录整合到安装包
ADD zookeeper-3.4.12.tar.gz /app
RUN ln -s /app/zookeeper-3.4.12 /app/zookeeper

#配置文件,日志切割，jvm标准化单独在zkGenConfig.sh配置
COPY zkGenConfig.sh /app/zookeeper/bin/ 

#开放端口
EXPOSE 2181 10052
