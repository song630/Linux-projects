# file name: exercise3
# written by: 3150103990 宋一之

#! /bin/bash

typeset string=  # 字符串初始化
if [ $# -ne 0 ]  # 参数个数不是1
	then
		echo "Illigal input."
		exit 1  # 异常退出
fi
read string  # 输入字符串
typeset -i length  # 字符串的长度
typeset -i iter  # 循环次数
string=$(echo $string | grep -o [a-zA-Z])
# 过滤掉所有不是字母的字符
# 注意：过滤后字符间多了空格
length=${#string}  # 得到字符串长度
iter=$((length/2))  # 取除以2的下界
echo "iter is $iter"
typeset flag=1  # 是否为回文的标志
for (( i=0; i<=$((iter-1)); i=$((i+2)) ))  # 由两端向中间遍历
do  # 左边的字符分别与右边镜像位置上的字符对比
	if [ ${string:$i:1} != ${string:$((length-i-1)):1} ]
		then
			flag=0  # 不是回文
			break  # 立即结束循环
	fi
done
if [ $flag -eq 1 ]  # 是回文
	then
		echo "The string is a palindrome."
else
	echo "The string is not a palindrome."
fi
exit 0  # 正常退出