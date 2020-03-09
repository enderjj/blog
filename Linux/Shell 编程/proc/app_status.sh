#!/bin/bash
#
# 脚本功能：
# 1. 查询所有分组：get_all_group
# 2. 根据分组查询所有 process：
# 3. 根据 process 查询 process 的信息：
# 4. 根据 process 查询 process 所属分组：
# 

# 定义配置文件位置
HOME_DIR="脚本所在目录"
CONFIG_FILE="process.cfg"

# 获取所有组名称
# 函数返回值：所有组的字符串
function get_all_group
{
    if [ ! -e "$CONFIG_FILE" ]; then
        # 配置文件不存在
        echo "$CONFIG_FILE is not exsit...please check it..."
    else
        # 获取所有组
        echo $(sed -n "/\[GROUP_LIST\]/,/\[.*\]/p" "$CONFIG_FILE" | egrep -v "^$|\[.*\]")
    fi
}

for group in $(get_all_group)
do
    echo "$group"
done