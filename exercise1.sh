# file name: exercise1
# written by:

#! /bin/bash
if [ $# -ne 1 ]  # 传入参数不是正好为1个
	then
		echo "Illigal input."  # 非法输入
		exit 1  # 异常退出
	else  # 传入参数正好是1个
		ls "$1" 2> /dev/null 1>&2  # 检查目录是否存在，输出重定向
		if [ $? -ne 0 ]  # 异常退出，没有找到文件
			then
				echo "The file $1: not found."  # 打印错误信息
				exit 1  # 异常退出
		elif [ ! -d $1 ]  # 如果目标文件不是目录类型
			then
				echo "The file $1: incorrect file type."  # 错误文件类型
				exit 1  # 异常退出
		else  # 有效且正确的输入
			cd $1  # 进入目录，否则后面wc -c的输入不在当前目录会出错
			set $(pwd)  # 获取当前绝对路径，相对路径会出错
			typeset -i num_ordinary num_dir num_exe  # 普通文件、子目录、可执行文件
			typeset -i wc_out  # wc命令的输出共有多少行，之后要shift
			typeset -i bytes  # 当前目录下的总字节数
			num_ordinary=$(ls -l $1 | grep ^- | wc -l)  # 以-普通文件开头的有多少行
			num_dir=$(ls -l $1 | grep ^d | wc -l)  # 以d普通文件开头的有多少行
			num_exe=$(ls -F $1 | grep "*" | wc -l)  # 给所有可执行文件的名称后都加上*标记再统计
			wc_out=$(ls -F $1 | grep [^/]$ | wc -l)  # 统计输出有多少行
			# 正则表达式的意思是选出所有不是由/结尾的文件，即非目录文件
			set $(wc -c $(ls -F $1 | grep [^/]$))  # 把统计文件字节数的输出赋给参数
			if [ $wc_out -eq 0 ]  # 没有文件，没有输出
				then
					bytes=0
			elif [ $wc_out -eq 1 ]  # 只有1行输出，此时不会有total统计
				then  # 不做shift
					bytes=$1
			else  # 多于1行输出
				shift $((wc_out+wc_out))  # 移动行数乘2，得到总字节数，存在$1
				bytes=$1
			fi
			echo "The number of ordinary files: $num_ordinary"  # 输出普通文件数
			echo "The number of directories: $num_dir"  # 输出子目录数
			echo "The number of executable files: $num_exe"  # 输出可执行文件数
			echo "The total bytes of all files: $bytes"  # 输出总字节数
			exit 0  # 正常退出
		fi
fi