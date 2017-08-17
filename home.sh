# file name: home
# project: assignment management system
# written by: 3150103990 宋一之

#! /bin/bash

# 开始先建立目录和记录数据的文件
if [ ! -e ~/project ]  # 如果目录不存在
	then
		mkdir ~/project  # 建立新目录，放所有文件
		# 放所有存放基本信息的文件
		mkdir ~/project/basic_info
		# 存放所有教师的账号信息
		touch ~/project/basic_info/teacher_accounts
		# 存放所有课程信息
		touch ~/project/basic_info/courses
		# 存放所有教师授课信息
		touch ~/project/basic_info/teaches
		# 存放所有学生账号信息
		touch ~/project/basic_info/student_accounts
		# 存放所有学生选课信息
		touch ~/project/basic_info/takes
		# 存放所有作业信息
		mkdir ~/project/assignments
		# 存放所有试验信息
		mkdir ~/project/labs
		# 存放课程说明
		mkdir ~/project/course_info
fi
echo "Please confirm your identity."
# 几个输入选项，确定用户类型，也可以退出
echo "Enter [administrator, teacher, student, or quit]:"
flag=0  # 表示输入是否合法
typeset user_type  # 用户类型，字符串
while [ $flag -ne 1 ]  # 只要输入不合法
do
	read user_type  # 用户输入身份
	case "$user_type" in  # 根据输入内容
		administrator )
			flag=1
			if [ ! -e ~/administrator.sh ]  # 脚本文件不存在
				then
					echo "Script not found."
					exit 1  # 异常退出
			fi
			chmod u=rwx ~/administrator.sh  # 可以执行
			cd ~  # 进入主目录
			./administrator.sh  # 调用管理员系统
			;;
		teacher )
			flag=1
			if [ ! -e ~/teacher.sh ]  # 脚本文件不存在
				then
					echo "Script not found."
					exit 1  # 异常退出
			fi
			chmod u=rwx ~/teacher.sh  # 可以执行
			cd ~  # 进入主目录
			./teacher.sh  # 调用教师系统
			;;
		student )
			flag=1
			if [ ! -e ~/student.sh ]  # 脚本文件不存在
				then
					echo "Script not found."
					exit 1  # 异常退出
			fi
			chmod u=rwx ~/student.sh  # 可以执行
			cd ~  # 进入主目录
			./student.sh  # 调用学生系统
			;;
		quit )
			flag=1
			exit 0  # 退出系统
			;;
		* )  # 所有其它字符串
			flag=0  # 无效输入
			echo "Invalid input. Please enter again:"
			;;
	esac
done