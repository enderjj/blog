#!/bin/bash
#
# 使用 sed 进行查找, 统计 my.conf 文件中的配置字段以及每个字段下面的配置项个数

FILE_NAME=my.conf

# 统计所有字段列表
function get_all_segments
{
    # 利用 echo 返回所有字段列表
    echo "`sed -n '/^\[.*\]/p' $FILE_NAME | sed -e 's/\[//' -e 's/\]//'`"

    # 方法二, 利用反向引用
    # sed -n 's/^\[\(.*\)\]/\1/p' $FILE_NAME
}

# 统计每个字段的配置项个数
function count_items_of_segment
{
    echo "`sed -n "/^\[$1\]/,/^\[.*\]/p" $FILE_NAME | grep -v '^#' | grep -v '^$' | grep -v '^\[' | wc -l`"
    
    # 方法二：先获取所有配置项，然后 for 循环统计配置项个数
    # 获取所有配置项
    # items="`sed -n "/^\[$1\]/,/^\[.*\]/p" $FILE_NAME | grep -v '^#' | grep -v '^$' | grep -v '^\['`"

    # 统计配置项个数
    # count=0
    # for item in $items
    # do
    #     count=`expr $count + 1`
    # done

    # echo $count
}

# echo `get_all_segments`

index=0
for segment in `get_all_segments`
do
    index=`expr $index + 1`
    items_count=`count_items_of_segment $segment`
    echo "$index: $segment $items_count"
done
