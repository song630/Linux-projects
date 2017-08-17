# file name: student
# project: assignment management system
# written by: 3150103990 宋一之

#! /bin/bash

# ============================================ #

assignment_create()  # 新建1个作业文档
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 输入课程和作业
	# 要先获取这门课教师的工号
	# 提取出学生选课文件中含有学号和课程的一行，这行同样含有工号
	temp=`grep $1$'\t'$c_name ~/project/basic_info/takes`
	# awk '{print $1}'作用是提取出第1个字段，即工号
	t_ID=`echo $temp | awk '{print $1}'`  # 得到工号
	if [ -z "$temp" ]  # 为空，没有找到
		then
			echo "The student $1 does not take the course $c_name."
		else
			if [ ! -e "$2/$c_name$t_ID/$a_name" ]
				then
					# 作业目录不存在
					echo "The assignment directory does not exist."
				else  # 满足条件，新建1个以学号命名的作业
					touch "$2/$c_name$t_ID/$a_name/$1"
			fi
	fi
	unset c_name a_name temp t_ID
}

# ============================================ #

assignment_edit()  # 编辑作业文档
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 输入课程和作业
	temp=`grep $1$'\t'$c_name ~/project/basic_info/takes`
	t_ID=`echo $temp | awk '{print $1}'`  # 获取教师工号
	if [ -z "$temp" ]  # 为空，没有找到
		then
			echo "The student $1 does not take the course $c_name."
		else
			if [ ! -e "$2/$c_name$t_ID/$a_name" ]
				then
					# 作业目录不存在
					echo "The assignment directory does not exist."
				else  # 满足条件，打开以学号命名的作业进行编辑
					gedit "$2/$c_name$t_ID/$a_name/$1"

					# 编辑完作业或实验后，提交记录文档submit中的相应行要改
					# awk内部的$1和函数参数的$1矛盾
					touch ~/project/temp_a
					awk 'BEGIN{FS=OFS="\t"}{if($1=="'$1'") $2="submitted"}' \
					"$2/$c_name$t_ID/$a_name/submit" \
					| cat >~/project/temp_a  # 覆盖原文件
					cat ~/project/temp_a>"$2/$c_name$t_ID/$a_name/submit"
					rm ~/project/temp_a
			fi
	fi
	unset c_name a_name temp t_ID
}

# ============================================ #

assignment_query()  # 查询自己的作业完成情况
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 输入课程和作业
	temp=`grep $1$'\t'$c_name ~/project/basic_info/takes`
	t_ID=`echo $temp | awk '{print $1}'`  # 获取教师工号
	if [ -z "$temp" ]  # 为空，没有找到
		then
			echo "The student $1 does not take the course $c_name."
		else
			if [ ! -e "$2/$c_name$t_ID/$a_name" ]
				then
					# 作业目录不存在
					echo "The assignment directory does not exist."
				else  # 从记录作业提交情况的文档中提取含有登录学号的1行
					temp=`grep $1 "$2/$c_name$t_ID/$a_name/submit"`
					echo $temp  # 输出
			fi
	fi
	unset c_name a_name temp t_ID
}

# ============================================ #

echo "Please enter your password as student:"
read password  # 用户输入密码
# 从文件中获取学生学号，-o为只取匹配的部分
s_ID=`grep -o $password ~/project/basic_info/student_accounts`
if [ -z "$s_ID" ]  # 密码输入错误
	then
		echo "Incorrect password."
		exit 1  # 异常退出
fi
# 密码正确
echo "Login success."
quit=0  # 退出标志
option=  # 用户输入的选项
while [ $quit -ne 1 ]  # 没有退出，永真循环
do
	echo "Please enter which object you would like to deal with:"
	echo "(just enter the number)"
	# 2个选项
	echo "1.[assignment management]"  # 作业管理
	echo "2.[lab management]"  # 实验管理
	echo "3.[quit]"  # 退出系统
	read option
	case "$option" in
		1 )  # 作业管理
			echo "Assignment management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回上一级
			do
				echo "Please enter the operation:"
				echo "[create/edit/query/back]"  # 输入具体操作
				path=~/project/assignments
				read operation  # 用户输入操作
				case "$operation" in
					create )  # 新建1个作业文档
						assignment_create $s_ID $path
						;;
					edit )  # 编辑作业文档
						assignment_edit $s_ID $path
						;;
					query )  # 查询自己的作业完成情况
						assignment_query $s_ID $path
						;;
					back )  # 返回上一级
						back=1  # 跳出循环
						;;
					* )
						echo "Invalid input. Please enter again."
						;;
				esac
			done
			;;
		2 )  # 实验管理
			echo "Lab management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回上一级
			do
				echo "Please enter the operation:"
				echo "[create/edit/query/back]"  # 输入具体操作
				path=~/project/labs
				read operation  # 用户输入操作
				case "$operation" in
					create )  # 新建1个实验文档
						assignment_create $s_ID $path
						;;
					edit )  # 编辑实验文档
						assignment_edit $s_ID $path
						;;
					query )  # 查询自己的实验完成情况
						assignment_query $s_ID $path
						;;
					back )  # 返回上一级
						back=1  # 跳出循环
						;;
					* )
						echo "Invalid input. Please enter again."
						;;
				esac
			done
			;;
		3 )
			exit 0  # 正常退出
			;;
		* )  # 非法输入
			echo "Invalid input."  # 再次输入选项
			;;
	esac
done