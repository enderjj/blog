#!/bin/bash

find_all_users() {
    users=$(cat /etc/passwd | cut -d: -f1)
    # 返回所有用户
    echo "$users"
}

# 执行函数
user_list=$(find_all_users)
index=1

for user in $user_list
do
    echo "The $index user: $user"
    index=$((index+1))
done