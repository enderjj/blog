#!/bin/bash
#
# 脚本功能：
# 1. 查询所有分组：get_all_group
# 2. 根据分组查询所有 process：
# 3. 根据 process 查询 process 的信息：
# 4. 根据 process 查询 process 所属分组：
# 
# 调用脚本：
# 1. 无参数
# 2. 参数为：-g 组名1 组名2 ...
# 3. 参数为：进程名1 进程名2 ...


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
    # echo $process_status $process_cpu $process_mem $process_start_time
}

# 判断组名是否存在
function is_group_exist
{
    for g in $(get_all_group)
    do
        if [ "$g" == "$1" ]; then
            return
        fi
    done
    return 1
}

# 判断进程名是否存在
function is_process_exist
{
    for p in $(get_all_process)
    do
        if [ "$p" == "$1" ]; then
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

# 根据进程名获取对应的组名
# 函数参数：进程名称
# 函数返回值：进程对应的组名
function get_group_by_process
{
    # 根据分组名称获取分组下所有进程名称
    is_process_exist $1
    if [ $? -eq 0 ]; then
        # 获取所有组
        for g in $(get_all_group)
        do
            # 根据组名获取组下所有进程
            for p in $(get_list $g)
            do
                # 判断进程是否存在
                if [ "$p" == "$1" ]; then
                    echo "$g"
                fi
            done
        done
    else
        echo "process $1 is not exist in config"
        exit 1
    fi
}

# 格式化输出
# 函数参数：进程名 组名
function format_print
{
    ps -ef | grep $1 | grep -v grep | grep -v $0 &> /dev/null
    if [ $? -eq 0 ]; then
        pids=$(get_pid_by_process $1)
        for pid in "$pids"
        do
            get_process_info_by_pid $pid
            awk -v p_name=$1 \
                -v g_name=$2 \
                -v p_id=$pid \
                -v p_status=$process_status \
                -v p_cpu=$process_cpu \
                -v p_mem=$process_mem \
                -v p_start_time="$process_start_time" \
                'BEGIN{printf "%-15s %-15s %-10s %-15s %-15s %-15s %-20s\n", p_name, g_name, p_id, p_status, p_cpu, p_mem, p_start_time}'
        done
    else
        awk -v p_name=$1 -v g_name=$2 \
        'BEGIN{printf "%-15s %-15s %-10s %-15s %-15s %-15s %-20s\n", p_name, g_name, "NULL", "NULL", "NULL", "NULL", "NULL"}'
    fi
}

# 判读配置文件是否存在
if [ ! -e "$CONFIG_FILE" ]; then
        # 配置文件不存在
        echo "$CONFIG_FILE is not exsit...please check it..."
fi

printf "%-15s %-15s %-10s %-15s %-15s %-15s %-20s\n" "PROCESS_NAME" "GROUP_NAME" "PROCESS_ID" "PROCESS_STATUS" "PROCESS_CPU" "PROCESS_MEM" "START_TIME"

# 有参数
if [ $# -gt 0 ]; then
    # 如果参数格式是 -g 组名
    if [ "$1" == "-g" ]; then
        # 参数向左位移一个位置，去除了第一个参数 -g
        shift
        # 遍历每个组
        for group in $@
        do
            # 获取分组下所有进程
            for pro in $(get_process_by_group $group)
            do
                format_print $pro $group
            done
        done
    else
        for pro in $@
        do
            group=$(get_group_by_process $pro)
            format_print $pro $group
        done
    fi
# 无参数
else
    for pro in $(get_all_process)
    do
        group=$(get_group_by_process $pro)
        format_print $pro $group
    done
fi