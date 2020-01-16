#!/bin/bash
#服务器执行
#release 部署XXX
DIST_JAR_NAME=xxx.jar
DIST_JAR_HOME=/home/xx/xxx/server
SERVER_PORT=8090
SPRING_PROFILES_ACTIVE=dev

echo "release $DIST_JAR_NAME  begin"

PID=`ps -ef | grep -w $DIST_JAR_NAME | grep -v grep | tr -s ' ' | awk -F' ' '{print $2}'`
echo "pid  $PID "
kill -9 $PID

cd $DIST_JAR_HOME
mv $DIST_JAR_NAME $DIST_JAR_NAME.bak$(date +%Y-%m-%d)
cp $DIST_JAR_NAME.new $DIST_JAR_NAME
sleep 1
nohup java -jar $DIST_JAR_NAME --server.port=$SERVER_PORT --spring.profiles.active=$SPRING_PROFILES_ACTIVE &
sleep 2


echo "release $DIST_JAR_NAME done,tail -f nohup.out 200s will exit"
PID=`ps -ef | grep -w $DIST_JAR_NAME | grep -v grep | tr -s ' ' | awk -F' ' '{print $2}'`
echo "pid  $PID "
tail -500 nohup.out
#| sed '/项目启动成功/Q'

#kill -9 $(ps -ef | grep -w $DIST_JAR_HOME/nohup.out | grep -v grep | tr -s ' ' | awk -F' ' '{print $2}')
exit
