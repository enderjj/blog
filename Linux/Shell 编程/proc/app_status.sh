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

# 获取两个 [..]、[..]之间的名称列表
# 函数可以传递参数，也可以不传参数
function get_list
{
    # 如果传递参数，则表示获取组下的 process 信息
    if [ $# -eq 1 ]; then
        echo $(sed -n "/\[$1\]/,/\[.*\]/p" "$CONFIG_FILE" | egrep -v "^$|^#|\[.*\]")
    # 如果没有传递参数，则表示获取所有 group 信息
    else
        echo $(sed -n "/\[GROUP_LIST\]/,/\[.*\]/p" "$CONFIG_FILE" | egrep -v "^$|^#|\[.*\]")
    fi
}

# 获取所有组名称
# 函数返回值：所有组的字符串
function get_all_group
{
    # 获取所有组
    echo $(get_list)
}

# 获取所有进程名称
# 函数返回值：所有进程名称的字符串
function get_all_process
{
    for g in $(get_all_group)
    do
        g_list=$(get_list "$g")
        echo $g_list
    done
}

# 根据进程名称获取进程 pid
# 函数参数：进程名称
# 函数返回值：进程 pid
function get_pid_by_process
{
    pids=$(ps -ef | grep "$1" | grep -v grep | grep -v $0 | awk '{print $2}')
    echo $pids
}

# 根据进程 pid 获取进程信息
# 函数参数：进程 pid
# 函数返回值：进行运行状态、进程内存占有、进程 cpu 占有、进程开始运行时间
function get_process_info_by_pid
{

    # 获取进程运行状态
    process_num=$(ps -ef | awk -v pid=$1 '$2==pid{print}' | wc -l)
    if [ $process_num -ne 0 ]; then
        process_status="RUNNING"
    else
        process_status="STOPED"
    fi
    process_cpu=$(ps aux | awk -v pid=$1 '$2==pid{print $3}')
    process_mem=$(ps aux | awk -v pid=$1 '$2==pid{print $4}')
    process_start_time=$(ps -p $1 -o lstart | grep -v "STARTED")
    echo $process_status $process_cpu $process_mem $process_start_time
}

# 判断组名是否存在
function is_group_exist
{
    for g in $(get_list)
    do
        if [ "$g" == "$1" ]; then
            return
        fi
    done

    return 1
}

# 根据进程分组名称获取所有该分组的进程名称
# 函数参数：分组名称
# 函数返回值：分组下所有进程名称
function get_process_by_group
{
    # 根据分组名称获取分组下所有进程名称
    is_group_exist $1
    if [ $? -eq 0 ]; then
        echo $(get_list $1)
    else
        echo "group $1 is not exist in config"
        exit 1
    fi
}

if [ ! -e "$CONFIG_FILE" ]; then
        # 配置文件不存在
        echo "$CONFIG_FILE is not exsit...please check it..."
fi

# pid=$(get_pid_by_process $1)
# echo $(get_process_info_by_pid "$pid")