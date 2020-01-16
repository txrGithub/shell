#!/bin/bash
SRC_JAR_HOME=../target
SRC_JAR_NAME=xxx.jar
DIST_JAR_HOME=/home/xx/xxx/server
DIST_JAR_NAME=xxx.jar
SRC_SHELL_HOME=./deploy
DIST_SHELL_HOME=/home/xx/xxx/deploy
SHELL_FILE=release_server.sh
SSH_HOST=root@ip
SSH_PORT=22

echo '部署脚本开始执行 jar名称:'$SRC_JAR_NAME
git pull origin dev
mvn clean package -DskipTests -f ../pom.xml

echo "执行免密登录配置"
sh copy-id_rsa.pub-to_remote.sh

echo "判断$DIST_JAR_HOME 是否存在"
echo "------------------"
ssh -p $SSH_PORT $SSH_HOST "[ -d $DIST_JAR_HOME ] && echo $DIST_JAR_HOME is exists || (mkdir -p $DIST_JAR_HOME && echo 目录创建成功)"
sleep 1
echo "------------------"

echo "远程copy JAR 包"
echo "------------------"
#检查源jar包字节数
SRC_BYTES=`cksum $SRC_JAR_HOME/$SRC_JAR_NAME | awk -F " " '{print $2}'`
echo "源jar包字节数:"$SRC_BYTES
#检查目标jar包字节数
DIST_CHKSUM="\`cksum $DIST_JAR_HOME/$DIST_JAR_NAME | awk -F ' '  '{print \$2}' \`"
DIST_BYTES=`ssh -p $SSH_PORT $SSH_HOST " echo $DIST_CHKSUM"`
echo "目标jar包字节数:"$DIST_BYTES
if ssh -p $SSH_PORT $SSH_HOST [ ! $SRC_BYTES -eq $DIST_BYTES ]
then
scp -P $SSH_PORT $SRC_JAR_HOME/$SRC_JAR_NAME $SSH_HOST:$DIST_JAR_HOME/$DIST_JAR_NAME.new && echo "jar包拷贝成功" || (echo "jar包拷贝失败" && exit)
else
  echo "jar包没有变化！"
fi
sleep 2
echo "------------------"

echo "远程copy release_server.sh 脚本"
#脚本目录是否存在
echo "判断$DIST_SHELL_HOME 是否存在"
ssh -p $SSH_PORT $SSH_HOST "[ -d $DIST_SHELL_HOME ] && echo $DIST_SHELL_HOME is exists || (mkdir -p $DIST_SHELL_HOME && echo  目录创建成功 )"
#如果脚本存在是否覆盖
echo "判断$DIST_SHELL_HOME/$SHELL_FILE 脚本是否存在"
if ssh -p $SSH_PORT $SSH_HOST test -e $DIST_SHELL_HOME/$SHELL_FILE; then
  if read -t 5 -p "Warnning: 服务器上脚本已经存在，是否需要覆盖？[y|n] :" yn; then
    if [[ $yn == [Yy] ]]; then
      scp -P $SSH_PORT $SRC_SHELL_HOME/$SHELL_FILE $SSH_HOST:$DIST_SHELL_HOME && echo "shell脚本覆盖成功!" || (echo "shell脚本覆盖失败!" && exit)
    elif [[ $yn == [Nn] ]];then
      echo "不覆盖shell脚本 ..."
    else
      [[ $yn != [YyNn] ]]
      echo "Please check what you input !"
    fi
  else
    echo " "
    echo "TimeOut ..."
  fi
else
  scp -P $SSH_PORT $SRC_SHELL_HOME/$SHELL_FILE $SSH_HOST:$DIST_SHELL_HOME && echo "shell脚本上传成功" || (echo "shell脚本上传失败" && exit)
fi

echo "执行远程启动脚本"
echo "------------------"
ssh -p $SSH_PORT $SSH_HOST "sh $DIST_SHELL_HOME/$SHELL_FILE" && echo "脚本执行成功" || (echo "脚本执行失败" && exit)
