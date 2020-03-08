#!/bin/bash
#
# 计算 student.txt 中每个学生的平均分和每门课程的总分
# 输出格式如下
# name      chinese     math    english    physical     average
# Allen       81        92        97        78           平均分
# Jack        93        76        87        85           平均分
# Rose        96        95        91        89           平均分
# Maggie      79        89        99        87           平均分
#            总分       总分       总分       总分

# 调用方式：
# awk -f student.sh student.txt

BEGIN{
    printf "%-10s%-10s%-10s%-10s%-10s%-10s\n", "name", "chinese", "math", "english", "physical", "average"
}

{
    total=$2+$3+$4+$5
    avg=total/4
    # printf "%-10s%-10d%-10d%-10d%-10d%-0.2f\n", $1, $2, $3, $4, $5, avg
    # score_chinese+=$2
    # score_math+=$3
    # score_english+=$4
    # score_physical+=$5
    # score_avg+=avg

    # 输出平均分 90 分以上的学生信息
    if (avg >= 90) {
        num+=1
        printf "%-10s%-10d%-10d%-10d%-10d%-0.2f\n", $1, $2, $3, $4, $5, avg
        score_chinese+=$2
        score_math+=$3
        score_english+=$4
        score_physical+=$5
        score_avg+=avg
    }
}

END {
    printf "%-10s%-10d%-10d%-10d%-10d%-0.2f\n", "Total", score_chinese, score_math, score_english, score_physical, score_avg/num
}