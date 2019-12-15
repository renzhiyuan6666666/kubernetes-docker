#设置继承镜像
FROM centos:6.6

#作者的信息
MAINTAINER docker_user （renzhiyuan@docker.com）

#kafka和jdk标准化版本
ENV JAVA_VERSION="1.8.0_151"
ENV KAFKA_VERSION="2.2.0"
ENV KAFKA_JDK_HOME=/app
ENV JAVA_HOME=/app/jdk1.8.0_151
ENV KAFKA_HOME=/app/kafka
ENV LANG=en_US.utf8

#基础使用包安装配置
#RUN yum makecache
#RUN yum install lsof yum-utils lrzsz net-tools nc -y &>/dev/null

#创建安装目录
RUN mkdir $KAFKA_JDK_HOME

#权限和变量
RUN chown -R root.root $KAFKA_JDK_HOME && chmod -R 755 $KAFKA_JDK_HOME

#安装配置JDK 
ADD jdk-8u151-linux-x64.tar.gz /app
RUN echo "export JAVA_HOME=/app/jdk1.8.0_151" >>/etc/profile 
RUN echo "export PATH=\$JAVA_HOME/bin:\$PATH" >>/etc/profile 
RUN echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >>/etc/profile 

#安装配置Kafka和创建目录
ADD kafka_2.12-2.2.0.tar.gz /app
RUN ln -s /app/kafka_2.12-2.2.0 /app/kafka

#配置文件，jvm变量单独yaml配置,日志切割整合到压缩包

#开放端口
EXPOSE 9092 9999