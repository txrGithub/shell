#!/bin/bash
SSH_HOST=root@ip
SSH_PORT=22
SRC_RSA_PUB_NAME=id_rsa.pub
#DIST_RSA_PUB_NAME=$SRC_RSA_PUB_NAME.tmp
RSA_PUB=`cat ~/.ssh/$SRC_RSA_PUB_NAME`
#上传公钥
#scp -P $SSH_PORT ~/.ssh/$SRC_RSA_PUB_NAME $SSH_HOST:/root/$DIST_RSA_PUB_NAME && echo "上传公钥成功！"
#公钥跟authorized_keys取交集并返回计数
#WF="\`grep -wf /root/$DIST_RSA_PUB_NAME ~/.ssh/authorized_keys |wc -l\`"
#服务器上authorized_keys查找公钥字符串并进行计数
CNT="\`grep -n '$RSA_PUB' ~/.ssh/authorized_keys |wc -l\`"
ssh -p $SSH_PORT $SSH_HOST "echo 匹配统计$CNT && [ $CNT = 0 ] && echo $RSA_PUB >> ~/.ssh/authorized_keys" && echo "免密登录配置成功" || echo "已配置免密登录"