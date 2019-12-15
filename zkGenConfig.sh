# !/usr/bin/env
# Copyright 2016 The Kubernetes Authors.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#配置参考
#https://github.com/kubernetes-retired/contrib/tree/master/statefulsets/zookeeper

#配置ZK相关变量
#ZK_USER=${ZK_USER:-"root"}
#ZK_LOG_LEVEL=${ZK_LOG_LEVEL:-"INFO"}
#ZK_HOME=${ZK_HOME:-"/app/zookeeper"}
ZK_DATA_DIR=${ZK_DATA_DIR:-"/app/zookeeper/data"}
ZK_DATA_LOG_DIR=${ZK_DATA_LOG_DIR:-"/app/zookeeper/datalog"}
ZK_LOG_DIR=${ZK_LOG_DIR:-"/app/zookeeper/logs"}
ZK_CONF_DIR=${ZK_CONF_DIR:-"/app/zookeeper/conf"}
LOGGER_PROPS_FILE="$ZK_CONF_DIR/log4j.properties"
#ZK_CLIENT_PORT=${ZK_CLIENT_PORT:-2181}
#ZK_SERVER_PORT=${ZK_SERVER_PORT:-2222}
#ZK_ELECTION_PORT=${ZK_ELECTION_PORT:-2223}
#ZK_TICK_TIME=${ZK_TICK_TIME:-3000}
#ZK_INIT_LIMIT=${ZK_INIT_LIMIT:-10}
#ZK_SYNC_LIMIT=${ZK_SYNC_LIMIT:-5}
#ZK_MAX_CLIENT_CNXNS=${ZK_MAX_CLIENT_CNXNS:-100}
#ZK_MIN_SESSION_TIMEOUT=${ZK_MIN_SESSION_TIMEOUT:- $((ZK_TICK_TIME*2))}
#ZK_MAX_SESSION_TIMEOUT=${ZK_MAX_SESSION_TIMEOUT:- $((ZK_TICK_TIME*20))}
#ZK_SNAP_RETAIN_COUNT=${ZK_SNAP_RETAIN_COUNT:-3}
#ZK_PURGE_INTERVAL=${ZK_PURGE_INTERVAL:-0}
ID_FILE="$ZK_DATA_DIR/myid"
ZK_CONFIG_FILE="$ZK_CONF_DIR/zoo.cfg"
JAVA_ENV_FILE="$ZK_CONF_DIR/java.env"

#副本数
#ZK_REPLICAS=3

#配置主机名和domain
HOST=`hostname -s`
DOMAIN=`hostname -d`
#ipdrr=`ip a|grep eth1|grep inet|awk '{print $2}'|awk -F"/" '{print $1}'`

#配置选举端口和数据同步端口
function print_servers() {
    for (( i=1; i<=$ZK_REPLICAS; i++ ))
    do
        echo "server.$i=$NAME-$((i-1)).$DOMAIN:$ZK_SERVER_PORT:$ZK_ELECTION_PORT"
    done
}

#获取hostName的最后一位，比如zookeeper-0获取到0作为myid
function validate_env() {
    echo "Validating environment"

    if [ -z $ZK_REPLICAS ]; then
        echo "ZK_REPLICAS is a mandatory environment variable"
        exit 1
    fi

    if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
        NAME=${BASH_REMATCH[1]}
        ORD=${BASH_REMATCH[2]}
    else
        echo "Failed to extract ordinal from hostname $HOST"
        exit 1
    fi
	
    MY_ID=$((ORD+1))
	
	if [ ! -f $ID_FILE ]; then
        echo $MY_ID >> $ID_FILE
    fi
    #echo "ZK_REPLICAS=$ZK_REPLICAS"
    #echo "MY_ID=$MY_ID"
    #echo "ZK_LOG_LEVEL=$ZK_LOG_LEVEL"
    #echo "ZK_DATA_DIR=$ZK_DATA_DIR"
    #echo "ZK_DATA_LOG_DIR=$ZK_DATA_LOG_DIR"
    #echo "ZK_LOG_DIR=$ZK_LOG_DIR"
    #echo "ZK_CLIENT_PORT=$ZK_CLIENT_PORT"
    #echo "ZK_SERVER_PORT=$ZK_SERVER_PORT"
    #echo "ZK_ELECTION_PORT=$ZK_ELECTION_PORT"
    #echo "ZK_TICK_TIME=$ZK_TICK_TIME"
    #echo "ZK_INIT_LIMIT=$ZK_INIT_LIMIT"
    #echo "ZK_SYNC_LIMIT=$ZK_SYNC_LIMIT"
    #echo "ZK_MAX_CLIENT_CNXNS=$ZK_MAX_CLIENT_CNXNS"
    #echo "ZK_MIN_SESSION_TIMEOUT=$ZK_MIN_SESSION_TIMEOUT"
    #echo "ZK_MAX_SESSION_TIMEOUT=$ZK_MAX_SESSION_TIMEOUT"
    #echo "ZK_HEAP_SIZE=$ZK_HEAP_SIZE"
    #echo "ZK_SNAP_RETAIN_COUNT=$ZK_SNAP_RETAIN_COUNT"
    #echo "ZK_PURGE_INTERVAL=$ZK_PURGE_INTERVAL"
    #echo "ENSEMBLE"
    #print_servers
    #echo "Environment validation successful"
}
	
#配置ZK配置文件变量
function create_config() {

    #rm -f $ZK_CONFIG_FILE
    echo "dataDir=$ZK_DATA_DIR"                >>$ZK_CONFIG_FILE
    echo "dataLogDir=$ZK_DATA_LOG_DIR"         >>$ZK_CONFIG_FILE
    echo "tickTime=$ZK_TICK_TIME"              >>$ZK_CONFIG_FILE
    echo "initLimit=$ZK_INIT_LIMIT"            >>$ZK_CONFIG_FILE
    echo "syncLimit=$ZK_SYNC_LIMIT"            >>$ZK_CONFIG_FILE
    echo "clientPort=$ZK_CLIENT_PORT"          >>$ZK_CONFIG_FILE
    echo "maxClientCnxns=$ZK_MAX_CLIENT_CNXNS" >>$ZK_CONFIG_FILE

    if [ $ZK_REPLICAS -gt 1 ]; then
        print_servers                          >> $ZK_CONFIG_FILE
    fi

    echo "Write ZooKeeper configuration file to $ZK_CONFIG_FILE"
}

#创建ZK相关目录和myid
#function create_data_dirs() {
#    echo "Creating ZooKeeper data directories and setting permissions"
#
#    if [ ! -d $ZK_DATA_DIR  ]; then
#        mkdir -p $ZK_DATA_DIR
#        chown -R $ZK_USER:$ZK_USER $ZK_DATA_DIR
#    fi
#
#    if [ ! -d $ZK_DATA_LOG_DIR  ]; then
#        mkdir -p $ZK_DATA_LOG_DIR
#        chown -R $ZK_USER:$ZK_USER $ZK_DATA_LOG_DIR
#    fi
#
#    if [ ! -d $ZK_LOG_DIR  ]; then
#        mkdir -p $ZK_LOG_DIR
#        chown -R $ZK_USER:$ZK_USER $ZK_LOG_DIR
#    fi 
#
#    echo "Created ZooKeeper data directories and set permissions in $ZK_DATA_DIR"
#}

#配置日志切割
#function create_log_props () {
#    rm -f $LOGGER_PROPS_FILE
#    echo "Creating ZooKeeper log4j configuration"
#    echo "zookeeper.root.logger=CONSOLE" >> $LOGGER_PROPS_FILE
#    echo "zookeeper.console.threshold="$ZK_LOG_LEVEL >> $LOGGER_PROPS_FILE
#    echo "log4j.rootLogger=\${zookeeper.root.logger}" >> $LOGGER_PROPS_FILE
#    echo "log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender" >> $LOGGER_PROPS_FILE
#    echo "log4j.appender.CONSOLE.Threshold=\${zookeeper.console.threshold}" >> $LOGGER_PROPS_FILE
#    echo "log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout" >> $LOGGER_PROPS_FILE
#    echo "log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n" >> $LOGGER_PROPS_FILE
#    echo "Wrote log4j configuration to $LOGGER_PROPS_FILE"
#}

#配置启动jmx配置
function create_java_env() {
    rm -f $JAVA_ENV_FILE
    echo "Creating JVM configuration file"
    echo '#!/bin/bash'          >> $JAVA_ENV_FILE
    echo "export JMXPORT=10052" >> $JAVA_ENV_FILE
    echo "JVMFLAGS=\"\$JVMFLAGS -Xms512m -Xmx512m -Djute.maxbuffer=5000000 -Xloggc:gc.log -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGC -XX:+PrintGCTimeStamps -XX:+PrintGCDetails -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC\""    >> $JAVA_ENV_FILE
    echo "Wrote JVM configuration to $JAVA_ENV_FILE"
}

validate_env && create_config  && create_java_env &&  cat $ZK_CONFIG_FILE && cat $JAVA_ENV_FILE
