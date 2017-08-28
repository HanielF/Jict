#!/bin/bash
ARGS=1
E_BADARGS=65
TEM_FILE="/tmp/jict.tmp"
 
if [ "$#" -ne "$ARGS" ]
 then
    echo "Usage:`basename $0` word"
    exit $E_BADARGS
fi
 
# 抓取页面，删除html代码，空行等，只留下想要的内容
curl -s 'http://dict.youdao.com/w/jap/'$1'' | awk 'BEGIN{j=0;i=0;} {if(/jcTrans/){i++;} if(i==1){print $0; if(/<\/ul>/){i=0;}}  if(/#examplesToggle/){ j++;print "例句:\n";} if(j==1) {print $0; if(/<\/ul>/){j=0;}}}' | sed 's/<[^>]*>//g' | sed 's/&nbsp;//g'| sed 's/&rarr;//g' | sed 's/^\s*//g' | sed '/^$/d' |awk '!/.com|.org|.net|.cn|.html|www./' > $TEM_FILE

#处理输出

head_flag=1 #头部标识
head="" #头部内容
body="" #栗子内容
eg_flag=0 #栗子开始标志
title_flag=1 #用来去掉第一行
line_num=0 #行号，用来给栗子加上序号
n=1 #栗子序号

while read line 
do
    if [ "$line" == "例句:" ]; then
        body="$body  \033[32;1m\n$line\033[0m"
        eg_flag=1 #判断是栗子内容
        title_flag=0 #说明没有内容，都是例句
        continue
    fi

    if [ $title_flag -eq 1 ]; then
        head="$head $line"
        let title_flag++
        continue
    fi

    if [ $eg_flag -eq 0 ]; then
        head="$head $line"
        continue
    fi

    #head部分结束，开始body
    if [ $eg_flag -eq 1 ];then
        let line_num++
        if [ `expr $line_num % 2 ` -eq 1 ]; then
            line="\033[32;1m\n$n\033[0m\033[32;1m"."\033[0m \033[1m$line\033[0m\n"
            let n++
        else
            line="  \033[33m$line\033[0m\n"
        fi
        body="$body $line"
    fi
done < $TEM_FILE

echo -e "\033[31;1m$head\033[0m$body"| sed  '$d'
  
exit 0

