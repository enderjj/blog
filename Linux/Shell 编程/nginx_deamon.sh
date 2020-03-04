#!/bin/bash

# $$ 用于获取执行脚本自身的子进程 pid
this_pid=$$

# -v 表示不查询
ps -ef | grep nginx | grep -v grep | grep -v ${this_pid} &> /dev/null

# $? 用于获取上个命令执行的结果
if [ $? -eq 0 ]; then
	echo "nginx is running well..."
else
	echo "nginx is down, starting it now..."
	service nginx start
fi