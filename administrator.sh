# file name: administrator
# project: assignment management system
# written by:

#! /bin/bash

# ============================================ #

create_teacher_account()  # 创建新的教师账号
{
	echo "Please enter name and ID of the teacher:"
	read name ID  # 用户输入
	if [ -z "$name" -o -z "$ID" ]  # 如果输入有一个为空值
		then
			echo "Invalid input: name or ID."  # 非法输入
		else  # 2个输入都不为空
			# 查询文件中是否已经有了这个账号
			temp=`grep $ID ~/project/basic_info/teacher_accounts`  # 查ID
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
					cat ~/project/basic_info/temp_c>>~/project/basic_info/teacher_accounts
					rm ~/project/basic_info/temp_a  # 删除临时文件
					rm ~/project/basic_info/temp_b
					rm ~/project/basic_info/temp_c
			fi
	fi
	unset name ID  # 删除自定义变量
	unset temp
}

# ============================================ #

modify_teacher_account()  # 修改教师账号
{
	echo "Please enter the current ID, new ID and new name:"
	read c_ID n_ID n_name
	# 查询文件中是否已经有了这个账号
	temp=`grep $c_ID ~/project/basic_info/teacher_accounts`  # 查ID
	if [ -z "$temp" ]  # 为空，说明没找到
		then
			echo "Current ID does not exist."
		else  # 找到了
			temp=`grep $n_ID ~/project/basic_info/teacher_accounts`  # 查新ID
			if [ -n "$temp" -a $n_ID -ne $c_ID ]  # 不为空，说明新ID与已有ID重复
				then
					echo "This new ID already exists."
				else
					touch ~/project/basic_info/temp_a  # 新建临时文件
					# 把其它所有不匹配c_ID的账号转移到临时文件中
					grep -v $c_ID ~/project/basic_info/teacher_accounts \
					| cat >>~/project/basic_info/temp_a
					touch ~/project/basic_info/temp_b
					touch ~/project/basic_info/temp_c
					echo "$n_ID">>~/project/basic_info/temp_b  # 将工号写到第1个临时文件中
					echo "$n_name">>~/project/basic_info/temp_c  # 将姓名写到第2个临时文件中
					# 第3个临时文件用于将两个属性合并为1行，tab分隔
					touch ~/project/basic_info/temp_d
					# 2文件内容合并
					paste ~/project/basic_info/temp_b ~/project/basic_info/temp_c \
					| cat >>~/project/basic_info/temp_d
					# 添加到新文件中的最后一行
					cat ~/project/basic_info/temp_d>>~/project/basic_info/temp_a
					# 覆盖原本的教师账号文件
					cat ~/project/basic_info/temp_a>~/project/basic_info/teacher_accounts
					rm ~/project/basic_info/temp_a  # 删除临时文件
					rm ~/project/basic_info/temp_b
					rm ~/project/basic_info/temp_c
					rm ~/project/basic_info/temp_d

					# 教师账号修改后，对应的assignments中的目录也要修改，
					# teaches和takes文件中的信息也要更新
					if [ $c_ID -ne $n_ID ]  # 新旧工号不一样
						then
							if [ -e ~/project/basic_info/teaches ]  # 如果文件存在
								then  # 更新teaches文件中的旧工号
									touch ~/project/basic_info/temp_a
									# 更新后的内容输出到1个临时文件中
									sed "s/$c_ID/$n_ID/" ~/project/basic_info/teaches \
									| cat >~/project/basic_info/temp_a
									# 覆盖原文件
									cat ~/project/basic_info/temp_a>~/project/basic_info/teaches
									rm ~/project/basic_info/temp_a
							fi
							if [ -e ~/project/basic_info/takes ]  # 如果文件存在
								then  # 更新takes文件中的旧工号
									# 更新第1个字段的工号
									# 注意：awk中使用自定义变量外面必须加上双引号和单引号
									touch ~/project/basic_info/temp_a
									awk 'BEGIN{FS=OFS="\t"}{if($1=="'$c_ID'") $1="'$n_ID'"}1' \
									~/project/basic_info/takes \
									| cat >~/project/basic_info/temp_a
									# 覆盖原文件
									cat ~/project/basic_info/temp_a>~/project/basic_info/takes
									rm ~/project/basic_info/takes
							fi
							# 循环：存放作业的目录的命名格式都是课名+工号，进行更新
							# 注意：sed的正则表达式内用了变量，外面必须用双引号
							for i in `ls -d ~/project/assignments/*$c_ID`
							do
								mv "$i" `echo "$i" | sed "s/$c_ID/$n_ID/"`
							done
							# 存放实验的目录名中的工号进行更新
							for i in `ls -d ~/project/labs/*$c_ID`
							do
								mv "$i" `echo "$i" | sed "s/$c_ID/$n_ID/"`
							done
					fi
			fi
	fi
	unset c_ID n_ID n_name temp i  # 删除自定义变量
}

# ============================================ #

delete_teacher_account()  # 删除教师账号
{
	echo "Please enter the ID of the teacher to be deleted:"
	read ID  # 用户输入
	# 查找输入的账号
	temp=`grep $ID ~/project/basic_info/teacher_accounts`
	if [ -z "$temp" ]  # 没有找到
		then
			echo "The account does not exist."
		else  # 建立1个临时文件
			touch ~/project/basic_info/temp_a
			grep -v $ID ~/project/basic_info/teacher_accounts \
			| cat >>~/project/basic_info/temp_a  # 选出所有不匹配ID的
			# 覆盖原文件
			cat ~/project/basic_info/temp_a>~/project/basic_info/teacher_accounts
			rm ~/project/basic_info/temp_a  # 删除临时文件

			# 教师账号删除后，相应文件中的记录也要删除
			if [ -e ~/project/basic_info/teaches ]  # 如果文件存在
				then
					touch ~/project/basic_info/temp_a  # 创建临时文件
					# 首先删除teaches文件中含有相应工号的记录
					sed "/$ID/d" ~/project/basic_info/teaches \
					| cat >~/project/basic_info/temp_a  # 结果放入临时文件
					# 覆盖原文件
					cat ~/project/basic_info/temp_a>~/project/basic_info/teaches
					rm ~/project/basic_info/temp_a
			fi

			# 删除takes文件中的相应记录，注意与第1个字段匹配
			if [ -e ~/project/basic_info/takes ]  # 如果文件存在
				then
					touch ~/project/basic_info/temp_a
					awk 'BEGIN{FS=OFS="\t"}{if($1!="'$ID'") print}' \
					~/project/basic_info/takes \
					| cat >~/project/basic_info/temp_a  # 结果放入临时文件
					cat ~/project/basic_info/temp_a>~/project/basic_info/takes
					rm ~/project/basic_info/temp_a
			fi

			# 删除所有对应的作业目录
			for i in `ls -d ~/project/assignments/*$ID`
			do
				rm -rf "$i"
			done

			# 删除所有对应的实验目录
			for i in `ls -d ~/project/labs/*$ID`
			do
				rm -rf "$i"
			done
	fi
	unset ID temp i  # 删除自定义变量
}

# ============================================ #

create_course()  # 创建课程
{
	echo "Please enter the course name:"
	read name  # 用户输入
	temp=`grep $name ~/project/basic_info/courses`  # 查找输入的课程
	if [ -n "$temp" ]  # 课程已经存在
		then
			echo "The course already exists."
		else  # 添加到课程文件的最后一行
			echo "$name">>~/project/basic_info/courses
	fi
	unset name temp  # 删除自定义变量
}

# ============================================ #

modify_course()  # 修改课程
{
	echo "Please enter the current course and the new one:"
	read c_name n_name  # 用户输入
	temp=`grep $c_name ~/project/basic_info/courses`  # 查找输入的课程
	if [ -z "$temp" ]  # 没有找到待修改的课程
		then
			echo "Current course not found."
		else  # 待修改的课程存在
			# 查找新课程是否已经存在
			temp=`grep $n_name ~/project/basic_info/courses`
			if [ -n "$temp" ]  # 存在
				then
					echo "New course already exists."
				else  # 课程名没有重复
					# 建立1个临时文件
					touch ~/project/basic_info/temp_a
					grep -v $c_name ~/project/basic_info/courses \
					| cat >>~/project/basic_info/temp_a  # 相当于删除旧的课程
					# 添加到文件最后一行
					echo "$n_name">>~/project/basic_info/temp_a
					# 覆盖旧的的文件
					cat ~/project/basic_info/temp_a>~/project/basic_info/courses
					rm ~/project/basic_info/temp_a  # 删除临时文件

					# teaches, takes, assignments, labs内的内容也要改变
					# 替换teaches内的数据
					if [ -e ~/project/basic_info/teaches ]  # 如果文件存在
						then
							touch ~/project/basic_info/temp_a
							sed "s/$c_name/$n_name/" ~/project/basic_info/teaches \
							| cat >~/project/basic_info/temp_a  # 存入临时文件
							# 覆盖原文件
							cat ~/project/basic_info/temp_a>~/project/basic_info/teaches
							rm ~/project/basic_info/temp_a
					fi

					# 替换takes中的数据
					if [ -e ~/project/basic_info/takes ]  # 如果文件存在
						then
							touch ~/project/basic_info/takes
							sed "s/$c_name/$n_name/" ~/project/basic_info/takes \
							| cat >~/project/basic_info/temp_a  # 存入临时文件
							# 覆盖原文件
							cat ~/project/basic_info/temp_a>~/project/basic_info/takes
							rm ~/project/basic_info/temp_a
					fi

					# 循环：存放作业的目录的命名格式都是课名+工号，进行更新
					for i in `ls -d ~/project/assignments/$c_name*`
					do
						mv "$i" `echo "$i" | sed "s/$c_name/$n_name/"`
					done

					# 循环：存放实验的目录的命名格式都是课名+工号，进行更新
					for i in `ls -d ~/project/labs/$c_name*`
					do
						mv "$i" `echo "$i" | sed "s/$c_name/$n_name/"`
					done					
			fi
	fi
	unset c_name n_name temp i  # 删除自定义变量
}

# ============================================ #

delete_course()
{
	echo "Please enter the course to be deleted:"
	read name  # 用户输入待删除的课程
	# 查找课程名
	temp=`grep $name ~/project/basic_info/courses`
	if [ -z "$temp" ]  # 没有找到
		then
			echo "Course not found."
		else  # 能找到
			# 建立1个临时文件
			touch ~/project/basic_info/temp_a
			grep -v $name ~/project/basic_info/courses \
			| cat >>~/project/basic_info/temp_a  # 删除旧的课程
			# 覆盖原文件内容
			cat ~/project/basic_info/temp_a>~/project/basic_info/courses
			rm ~/project/basic_info/temp_a

			# 删除teaches, takes, assignments, labs中包含旧课程的相关内容
			# 删除teaches中所有含有旧课程名的记录
			if [ -e ~/project/basic_info/teaches ]  # 文件存在
				then
					touch ~/project/basic_info/temp_a
					sed "/$name/d" ~/project/basic_info/teaches \
					| cat >~/project/basic_info/temp_a  # 结果存到临时文件中
					cat ~/project/basic_info/temp_a>~/project/basic_info/teaches
					rm ~/project/basic_info/temp_a
			fi

			# 删除takes内所有含有旧课程的记录
			if [ -e ~/project/basic_info/takes ]  # 文件存在
				then
				touch ~/project/basic_info/temp_a
					sed "/$name/d" ~/project/basic_info/takes \
					| cat >~/project/basic_info/temp_a  # 结果存到临时文件中
					cat ~/project/basic_info/temp_a>~/project/basic_info/takes
					rm ~/project/basic_info/temp_a
			fi

			# 删除assignments中所有含有旧课程的目录
			for i in `ls -d ~/project/assignments/$name*`
			do
				rm -rf "$i"
			done

			# 删除labs中所有含有旧课程的目录
			for i in `ls -d ~/project/labs/$name*`
			do
				rm -rf "$i"
			done
	fi
	unset name temp i  # 删除自定义变量
}

# ============================================ #

add_teacher_course()  # 添加一组教师和课程的绑定
{
	echo "Please enter ID and course:"
	read ID name  # 用户输入教师工号和课程名
	# 查找教师工号
	temp1=`grep $ID ~/project/basic_info/teacher_accounts`
	# 查找课程
	temp2=`grep $name ~/project/basic_info/courses`
	if [ -z "$temp1" -o -z "$temp2" ]  # 两者中有1个不存在
		then  # 不能添加绑定
			echo "Either ID or course does not exist."
		else  # 两者都存在
			touch ~/project/basic_info/temp_a  # 新建临时文件
			touch ~/project/basic_info/temp_b
			echo "$ID">>~/project/basic_info/temp_a  # 工号存到第1个文件中
			echo "$name">>~/project/basic_info/temp_b  # 姓名存到第2个文件中
			# 组合2个属性，添加到原文件的最后一行
			paste ~/project/basic_info/temp_a ~/project/basic_info/temp_b \
			| cat >>~/project/basic_info/teaches
			rm ~/project/basic_info/temp_a  # 删除临时文件
			rm ~/project/basic_info/temp_b
			# 建立1个目录，存放这名教师开设的课程的作业
			mkdir ~/project/assignments/"$name$ID"
			# 建立1个目录，存放这名教师开设的课程的实验
			mkdir ~/project/labs/"$name$ID"
	fi
	unset ID name temp1 temp2  # 删除自定义变量
}

# ============================================ #

delete_teacher_course()  # 删除一组教师和课程的绑定
{
	echo "Please enter ID and course:"
	read ID name  # 用户输入工号和课程名
	# 找出匹配工号课程名的一组绑定，中间有tab
	temp=`grep $ID$'\t'$name ~/project/basic_info/teaches`
	if [ -z "$temp" ]  # 没有找到
		then
			echo "Object does not exist."
		else  # 存在
			touch ~/project/basic_info/temp_a  # 建立临时文件
			grep -v "$ID"$'\t'"$name" ~/project/basic_info/teaches \
			| cat >>~/project/basic_info/temp_a  # 删除这一行
			# 覆盖原文件内容
			cat ~/project/basic_info/temp_a>~/project/basic_info/teaches
			rm ~/project/basic_info/temp_a
			rm -rf ~/project/assignments/"$name$ID"  # 删除存放作业的目录
			rm -rf ~/project/labs/"$name$ID"  # 删除存放实验的目录
	fi
	unset ID name temp  # 删除自定义变量
}

# ============================================ #

typeset password  # 保存用户输入的密码
echo "Please enter your password as administrator:"
read password  # 输入密码
if [ $password -ne 123456 ]  # 密码错误
	then
		echo "Incorrect password."
		exit 1  # 异常退出
fi
# 密码正确：
echo "Login success."
typeset quit=0  # 退出标志
typeset option  # 用户输入的选项
while [ $quit -ne 1 ]  # 没有退出，永真循环
do
	echo "Please enter which object you would like to deal with:"
	echo "(just enter the number)"
	# 3个选项
	echo "[1.teacher account management]"  # 教师账号
	echo "[2.courses management]"  # 课程信息
	echo "[3.teacher-course management]"  # 教师和课程绑定
	echo "[4.quit]"  # 退出系统
	read option  # 用户输入选项
	case "$option" in
		1 )  # 教师账号管理
			echo "Teacher account management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回上一级
			do
				echo "Please enter the operation:"
				echo "[create/modify/delete/list/back]"  # 输入具体操作
				read operation  # 用户输入操作
				case "$operation" in
					create )  # 创建新教师账号
						create_teacher_account  # 调用函数
						;;
					modify )  # 改变教师账号
						modify_teacher_account  # 调用函数
						;;
					delete )  # 删除教师账号
						delete_teacher_account  # 调用函数
						;;
					list )  # 显示所有教师账号
						# 显示文件内容
						cat ~/project/basic_info/teacher_accounts
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
		2 )  # 课程信息管理
			echo "Courses management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回
			do
				echo "Please enter the operation:"
				echo "[create/modify/delete/list/back]"  # 输入具体操作
				read operation  # 用户输入操作
				case "$operation" in
					create )
						create_course  # 调用函数
						;;
					modify )
						modify_course  # 调用函数
						;;
					delete )
						delete_course  # 调用函数
						;;
					list )
						cat ~/project/basic_info/courses  # 显示文件内容
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
		3 )  # 教师和课程绑定
			echo "teacher-course management:"
			back=0  # 是否返回上一级的标志
			while [ $back -ne 1 ]  # 不返回
			do
				echo "Please enter the operation:"
				echo "[add/delete/list/back]"  # 输入具体操作
				read operation  # 用户输入操作
				case "$operation" in
					add )  # 添加一组绑定
						add_teacher_course  # 调用函数
						;;
					delete )  # 删除一组绑定
						delete_teacher_course  # 调用函数
						;;
					list )
						cat ~/project/basic_info/teaches  # 显示文件内容
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
		4 )  # 退出
			exit 0  # 正常退出
			;;
		* )  # 不合法输入
			echo "Invalid input."  # 再次输入选项
	esac
done