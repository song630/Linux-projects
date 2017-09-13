# file name: teacher
# project: assignment management system
# written by:

#! /bin/bash

# ============================================ #

# 和create_teacher_account()相比，只有第1行的输出和2处路径不同
create_student_account()  # 创建学生账号
{
	echo "Please enter name and ID of the student:"
	read name ID  # 用户输入
	if [ -z "$name" -o -z "$ID" ]  # 如果输入有一个为空值
		then
			echo "Invalid input: name or ID."  # 非法输入
		else  # 2个输入都不为空
			# 查询文件中是否已经有了这个账号
			temp=`grep $ID ~/project/basic_info/student_accounts`  # 查ID
			if [ -n "$temp" ]  # 不为空，即账号已存在
				then
					echo "The account already exists."
				else  # 没有相同账号，创建一个新的
					touch ~/project/basic_info/temp_a
					touch ~/project/basic_info/temp_b
					echo "$ID">>~/project/basic_info/temp_a  # 将工号写到第1个临时文件中
					echo "$name">>~/project/basic_info/temp_b  # 将姓名写到第2个临时文件中
					# 第3个临时文件用于将两个属性合并为1行，tab分隔
					touch ~/project/basic_info/temp_c
					# 2文件内容合并
					paste ~/project/basic_info/temp_a ~/project/basic_info/temp_b \
					| cat >>~/project/basic_info/temp_c
					# 添加到新文件中的最后一行
					cat ~/project/basic_info/temp_c>>~/project/basic_info/student_accounts
					rm ~/project/basic_info/temp_a  # 删除临时文件
					rm ~/project/basic_info/temp_b
					rm ~/project/basic_info/temp_c
			fi
	fi
	unset name ID  # 删除自定义变量
	unset temp
}

# ============================================ #

import_student_account()  # 导入学生账号
{
	echo "Please enter ID and course:"
	read s_ID c_name  # 用户输入学号和课程名
	# 找出匹配工号和课程名的一组绑定，中间有tab
	temp=`grep $1$'\t'$c_name ~/project/basic_info/teaches`
	if [ -z "$temp" ]  # 字符串为空，没有找到
		then  # 没有这组教师和课程的绑定
			echo "Cannot find the course $c_name given by teacher $1."
		else  # 找到了绑定
			# 找学生的账号
			temp=`grep $s_ID ~/project/basic_info/student_accounts`
			if [ -z "$temp" ]  # 字符串为空，没有找到
				then
					echo "Cannot find the student."
				else  # 满足所有前提
					touch ~/project/basic_info/temp_a  # 建立临时文件存放字段
					touch ~/project/basic_info/temp_b
					touch ~/project/basic_info/temp_c
					echo "$1">>~/project/basic_info/temp_a
					echo "$s_ID">>~/project/basic_info/temp_b
					# 连接2个文件
					paste ~/project/basic_info/temp_a \
					~/project/basic_info/temp_b >~/project/basic_info/temp_c
					echo "$c_name">~/project/basic_info/temp_a  # 覆盖
					# 最后的字段顺序是：工号、学号、课程，最后在文件temp_b中
					paste ~/project/basic_info/temp_c \
					~/project/basic_info/temp_a >~/project/basic_info/temp_b
					# 添加到原文件的最后1行
					cat ~/project/basic_info/temp_b>>~/project/basic_info/takes
					rm ~/project/basic_info/temp_a
					rm ~/project/basic_info/temp_b
					rm ~/project/basic_info/temp_c
			fi
	fi
	unset s_ID c_name temp
}

# ============================================ #

# 和modify_teacher_account()的区别：改了4处路径
modify_student_account()  # 修改学生账号
{
	echo "Please enter the current ID, new ID and new name:"
	read c_ID n_ID n_name
	# 查询文件中是否已经有了这个账号
	temp=`grep $c_ID ~/project/basic_info/student_accounts`  # 查ID
	if [ -z "$temp" ]  # 为空，说明没找到
		then
			echo "Current ID does not exist."
		else  # 找到了
			temp=`grep $n_ID ~/project/basic_info/student_accounts`  # 查新ID
			if [ -n "$temp" -a $n_ID -ne $c_ID ]  # 不为空，说明新ID与已有ID重复
				then
					echo "This new ID already exists."
				else  # 新ID没有重复或者新ID等于旧ID
					touch ~/project/basic_info/temp_a  # 新建临时文件
					# 把其它所有不匹配c_ID的账号转移到临时文件中
					grep -v $c_ID ~/project/basic_info/student_accounts \
					| cat >>~/project/basic_info/temp_a
					touch ~/project/basic_info/temp_b
					touch ~/project/basic_info/temp_c
					echo "$n_ID">>~/project/basic_info/temp_b  # 将学号写到第1个临时文件中
					echo "$n_name">>~/project/basic_info/temp_c  # 将姓名写到第2个临时文件中
					# 第3个临时文件用于将两个属性合并为1行，tab分隔
					touch ~/project/basic_info/temp_d
					# 2文件内容合并
					paste ~/project/basic_info/temp_b ~/project/basic_info/temp_c \
					| cat >>~/project/basic_info/temp_d
					# 添加到新文件中的最后一行
					cat ~/project/basic_info/temp_d>>~/project/basic_info/temp_a
					# 覆盖原本的学生账号文件
					cat ~/project/basic_info/temp_a>~/project/basic_info/student_accounts
					rm ~/project/basic_info/temp_a  # 删除临时文件
					rm ~/project/basic_info/temp_b
					rm ~/project/basic_info/temp_c
					rm ~/project/basic_info/temp_d

					# 更新takes, submit中的内容
					# 更新takes中的学号
					if [ -e ~/project/basic_info/takes ]  # 文件存在
						then  # 处理的是文件中的第2个字段
							touch ~/project/basic_info/temp_a
							awk 'BEGIN{FS=OFS="\t"}{if($2=="'$c_ID'") $2="'$n_ID'"}1' \
							~/project/basic_info/takes \
							| cat >~/project/basic_info/temp_a
							# 覆盖原文件
							cat ~/project/basic_info/temp_a>~/project/basic_info/takes
							rm ~/project/basic_info/temp_a
					fi

					# 更新~/project/assignments/课程工号/assignment-x/submit
					touch ~/project/basic_info/temp_a
					for i in `find ~/project/assignments -name submit`
					do  # 查找到的每个文件都更新
						sed "s/$c_ID/$n_ID/" "$i" \
						| cat >~/project/basic_info/temp_a
						cat ~/project/basic_info/temp_a>"$i"  # 覆盖原文件
					done

					# 更新~/project/labs/课程工号/lab-x/submit
					for i in `find ~/project/labs -name submit`
					do  # 查找到的每个文件都更新
						sed "s/$c_ID/$n_ID/" "$i" \
						| cat >~/project/basic_info/temp_a
						cat ~/project/basic_info/temp_a>"$i"  # 覆盖原文件
					done
					rm ~/project/basic_info/temp_a
			fi
	fi
	unset c_ID n_ID n_name temp  # 删除自定义变量
}

# ============================================ #

delete_student_account()  # 删除学生账号
{
	echo "Please enter the ID of the student to be deleted:"
	read ID  # 用户输入
	# 查找输入的账号
	temp=`grep $ID ~/project/basic_info/student_accounts`
	if [ -z "$temp" ]  # 没有找到
		then
			echo "The account does not exist."
		else  # 建立1个临时文件
			touch ~/project/basic_info/temp_a
			grep -v $ID ~/project/basic_info/student_accounts \
			| cat >>~/project/basic_info/temp_a  # 选出所有不匹配ID的
			# 覆盖原文件
			cat ~/project/basic_info/temp_a>~/project/basic_info/student_accounts
			rm ~/project/basic_info/temp_a  # 删除临时文件

			# 删除takes中含有已删学号的记录
			if [ -e ~/project/basic_info/takes ]  # 文件存在
				then
					touch ~/project/basic_info/temp_a
					# 不满足的提取出来，相当于删除满足的
					awk 'BEGIN{FS=OFS="\t"}{if($2!="'$ID'") print}' \
					~/project/basic_info/takes \
					| cat >~/project/basic_info/temp_a
					# 覆盖原文件
					cat ~/project/basic_info/temp_a>~/project/basic_info/takes
					rm ~/project/basic_info/temp_a
			fi

			# 删除作业提交记录文件submit中的相关记录
			touch ~/project/basic_info/temp_a
			for i in `find ~/project/assignments -name submit`
			do  # 查找到的每个文件都删除相应行
				sed "/$ID/d" "$i" \
				| cat >~/project/basic_info/temp_a
				cat ~/project/basic_info/temp_a>"$i"  # 覆盖原文件
			done

			# 删除实验提交记录文件submit中的相关记录
			for i in `find ~/project/labs -name submit`
			do  # 查找到的每个文件都删除相应行
				sed "/$ID/d" "$i" \
				| cat >~/project/basic_info/temp_a
				cat ~/project/basic_info/temp_a>"$i"  # 覆盖原文件
			done
			rm ~/project/basic_info/temp_a
	fi
	unset ID temp i  # 删除自定义变量
}

# ============================================ #

search_student_account()  # 查找学生账号
{
	echo "Please enter ID of the student:"
	read ID  # 用户输入学号
	# 查找与学号匹配的行
	temp=`grep $ID ~/project/basic_info/student_accounts`
	if [ -z "$temp" ]  # 没有找到
		then
			echo "The student does not exist."
		else
			echo $temp  # 输出这1行
	fi
	unset ID temp  # 删除自定义变量
}

# ============================================ #

add_course_info()  # 创建课程信息文件
{
	echo "Please enter the course:"
	read name  # 用户输入课程
	# 查找文件中是否记录了课程名
	temp=`grep $name ~/project/basic_info/courses`
	if [ -z "$temp" ]  # 不存在这个课程
		then
			echo "The course does not exist."
		else
			if [ -e ~/project/course_info/$name ]  # 文件已经存在
				then
					echo "The file already exists."
				else  
					touch ~/project/course_info/$name  # 创建
			fi
	fi
	unset name temp  # 删除自定义变量
}

# ============================================ #

edit_course_info()  # 编辑课程信息文件
{
	echo "Please enter the course:"
	read name  # 用户输入课程
	if [ ! -e ~/project/course_info/$name ]  # 没有这个文件
		then  # 提示要先创建
			echo "The file does not exist, create it first."
		else  # 打开文档开始编辑
			gedit ~/project/course_info/$name
	fi
	unset name
}

# ============================================ #

delete_course_info()  # 删除课程信息文件
{
	echo "Please enter the course:"
	read name
	if [ ! -e "~/project/course_info/$name" ]  # 没有这个文件
		then
			echo "The file does not exist."
		else
			rm "~/project/course_info/$name"  # 删除文件
	fi
	unset name
}

# ============================================ #

create_assignment()  # 创建新作业。接受了工号作为参数
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 读取用户输入
	if [ ! -e "$2/$c_name$1" ]  # 目录不存在
		then
			echo "The directory does not exist."
		else
			mkdir "$2/$c_name$1/$a_name"  # 建立这个作业目录
			touch "$2/$c_name$1/$a_name/instructions"  # 作业说明
			touch "$2/$c_name$1/$a_name/submit"  # 作业上交情况

			# 自动在takes文件中找出所有上这门课的学生，
			# 添加初始记录：1010	null
			# 注意：正则表达式中*不是任意数量任意字符，而是重复前面的
			touch ~/project/temp_file
			touch ~/project/temp_a
			touch ~/project/temp_b
			grep $1.*$c_name ~/project/basic_info/takes>~/project/temp_file
			while read line  # 按行而不是按字段读取
			do  # 获取每行第2个字段，即学号
				s_ID=`echo $line | awk '{print $2}'`
				echo $s_ID>>~/project/temp_a  # 学号存入文件
				echo "null">>~/project/temp_b  # 上交情况存入文件
			done <~/project/temp_file
			paste ~/project/temp_a ~/project/temp_b \
			| cat >"$2/$c_name$1/$a_name/submit"  # 合并2个字段
			rm ~/project/temp_a ~/project/temp_b
			rm ~/project/temp_file
	fi
	unset c_name a_name s_ID line
}

# ============================================ #

edit_assignment_info()  # 编辑作业信息。接受了工号作为参数
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 读取用户输入
	if [ ! -e "$2/$c_name$1/$a_name" ]  # 作业目录不存在
		then
			echo "The directory does not exist."
		else  # 打开文档进行编辑
			gedit "$2/$c_name$1/$a_name/instructions"
	fi
	unset c_name a_name
}

# ============================================ #

delete_assignment()  # 删除作业目录。接受工号参数
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 读取用户输入
	if [ ! -e "$2/$c_name$1/$a_name" ]  # 作业目录不存在
		then
			echo "The directory does not exist."
		else  # 存在，删除整个目录
			rm -rf "$2/$c_name$1/$a_name"
	fi
	unset c_name a_name
}

# ============================================ #

list_one_assignment()  # 显示作业信息。接受工号参数
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 读取用户输入
	if [ ! -e "$2/$c_name$1/$a_name" ]  # 作业目录不存在
		then
			echo "The directory does not exist."
		else  # 显示文件内容
			cat "$2/$c_name$1/$a_name/instructions"
	fi
	unset c_name a_name
}

# ============================================ #

list_all_assignment()  # 显示所有布置过的作业
{
	echo "Please enter the course:"
	read name  # 输入课程名
	if [ ! -e "$2/$name$1" ]  # 目录不存在
		then
			echo "The directory does not exist."
		else  # 显示当前课程下所有作业目录
			ls "$2/$name$1"
	fi
	unset name
}

# ============================================ #

search_one_student()  # 查找1个学生某项作业完成情况
{
	echo "Please enter the course, assignment and student ID:"
	read c_name a_name ID  # 输入课程、作业名和学号
	# 取出选课文件中含有工号、学号、课程的1行
	temp=`grep $1$'\t'$ID$'\t'$c_name ~/project/basic_info/takes`
	if [ -z "$temp" ]  # 为空，没找到
		then
			echo "The student $ID does not take course $c_name."
		else
			if [ ! -e "$2/$c_name$1/$a_name" ]  # 作业目录不存在
				then
					echo "The directory does not exist."
				else  # 作业目录存在，提取出作业提交记录文件中的相应行
					temp=`grep "$ID" "$2/$c_name$1/$a_name/submit"`
					echo $temp  # 相关信息输出到屏幕
			fi
	fi
	unset c_name a_name ID temp
}

# ============================================ #

search_all_student()  # 列出所有学生某项作业的完成情况
{
	echo "Please enter the course and assignment:"
	read c_name a_name  # 用户输入课程和作业
	if [ ! -e "$2/$c_name$1/$a_name" ]  # 作业目录不存在
		then
			echo "The directory does not exist."
		else  # 直接显示文件的所有内容
			cat "$2/$c_name$1/$a_name/submit"
	fi
	unset c_name a_name
}

# ============================================ #

echo "Please enter your password as teacher:"
read password  # 用户输入密码
# 从文件中获取教师工号，-o为只取匹配的部分
t_ID=`grep -o $password ~/project/basic_info/teacher_accounts`
if [ -z "$t_ID" ]  # 密码输入错误
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
	# 3个选项
	echo "[1.student account management]"  # 学生账号
	echo "[2.courses info management]"  # 课程信息编辑
	echo "[3.assignments management]"  # 作业管理
	echo "[4.labs management]"  # 实验管理
	echo "[5.quit]"  # 退出系统
	read option  # 用户输入选项
	case "$option" in
		1 )  # 学生账号
			echo "Teacher account management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回上一级
			do
				echo "Please enter the operation:"
				echo "[create/import/modify/delete/search/list/back]"  # 输入具体操作
				read operation  # 用户输入操作
				case "$operation" in
					create )  # 创建新学生账号
						create_student_account  # 调用函数
						;;
					import )  # 导入学生账号
						# 把教师工号传给函数参数
						import_student_account $t_ID
						;;
					modify )  # 改变学生账号
						modify_student_account  # 调用函数
						;;
					delete )  # 删除学生账号
						delete_student_account  # 调用函数
						;;
					search )  # 查找学生账号
						search_student_account  # 调用函数
						;;
					list )  # 显示所有学生账号
						# 显示文件内容
						cat ~/project/basic_info/student_accounts
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
		2 )  # 课程信息编辑
			echo "Course info management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回上一级
			do
				echo "Please enter the operation:"
				echo "[add/edit/delete/back]"  # 输入具体操作
				read operation  # 用户输入操作
				case "$operation" in
					add )  # 创建课程信息文档
						add_course_info  # 调用函数
						;;
					edit )  # 编辑课程信息
						edit_course_info  # 调用函数
						;;
					delete )  # 删除课程信息文档
						delete_course_info  # 调用函数
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
		3 )  # 作业管理
			echo "Assignment management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回上一级
			do
				echo "Please enter the operation:"
				echo "[create/edit/delete/list-one/list-all/search-one/search-all/back]"
				path=~/project/assignments
				read operation  # 用户输入操作
				case "$operation" in
					create )  # 创建新作业
						create_assignment $t_ID $path
						;;
					edit )  # 编辑作业信息
						edit_assignment_info $t_ID $path
						;;
					delete )  # 删除作业目录
						delete_assignment $t_ID $path
						;;
					list-one )  # 显示作业信息
						list_one_assignment $t_ID $path
						;;
					list-all )  # 显示所有布置过的作业
						list_all_assignment $t_ID $path
						;;
					search-one )  # 查找单个学生是否完成了某项作业
						search_one_student $t_ID $path
						;;
					search-all )  # 查找这项作业所有学生的完成情况
						search_all_student $t_ID $path
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
		4 )  # 实验管理，与上面的作业管理完全相同
			echo "Lab management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回上一级
			do
				echo "Please enter the operation:"
				echo "[create/edit/delete/list-one/list-all/search-one/search-all/back]"
				path=~/project/labs
				# 函数参数：一个是教师工号，一个是作业或实验路径
				read operation  # 用户输入操作
				case "$operation" in
					create )  # 创建新实验
						create_assignment $t_ID $path
						;;
					edit )  # 编辑实验信息
						edit_assignment_info $t_ID $path
						;;
					delete )  # 删除实验目录
						delete_assignment $t_ID $path
						;;
					list-one )  # 显示实验信息
						list_one_assignment $t_ID $path
						;;
					list-all )  # 显示所有布置过的实验
						list_all_assignment $t_ID $path
						;;
					search-one )  # 查找单个学生是否完成了某项实验
						search_one_student $t_ID $path
						;;
					search-all )  # 查找这项实验所有学生的完成情况
						search_all_student $t_ID $path
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
		5 )  # 退出系统
			exit 0  # 正常退出
			;;
		* )  # 非法输入
			echo "Invalid input."  # 再次输入选项
			;;
	esac
done