# file name: exercise2
# written by: 3150103990 宋一之

#! /bin/bash

typeset -a array arr_copy
# 存放输入整数的数组，另一个是用于排序的副本
typeset -i min max  # 最大值，最小值
declare total=10  # 总元素数
declare average=0  # 平均值，也是总和
read -a array  # 输入所有元素
# 原判断条件：${#array[*]} -ne $total
if [ $(echo "${#array[*]} != $total" | bc) -eq 1 ]  # 输入不是100个
	then
		echo "Illigal input."
		exit 1  # 异常退出
fi
min=${array[0]}  # 最小值初始化
max=${array[0]}  # 最大值初始化
average=$((average+array[0]))  # 更新总和

for (( i=1; i<=$((total-1)); i++ ))  # i是数组下标
do
	average=$((average+array[$i]))  # 更新总和
	if [ ${array[$i]} -lt $min ]  # 若小于最小值
		then
			min=${array[$i]}  # 更新
	fi
	if [ ${array[$i]} -gt $max ]  # 若大于最大值
		then
			max=${array[$i]}  # 更新
	fi
done
average=$(echo "scale=2;$average / $total" | bc)
# 求出平均值。bc为浮点运算
arr_copy=($(for val in "${array[@]}"  # 遍历数组
do
	echo "$val"
done | sort -n))  # 输出所有元素，利用管道排序
echo "The sorted input: "
echo "${arr_copy[@]}"  # 输出排序结果
echo "The maximum is $max."
echo "The minimum is $min."
echo "The average is $average."
exit 0  # 正常退出