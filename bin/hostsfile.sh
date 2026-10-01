#!/bin/bash

# todo rewrite
exit 1

host=$1

if [[ "$host" = "-h" ]]; then
	echo -e 'Usage:  hosts domain ip.address  --  bind domain to ip
        hosts delete domain                  --  delete bind
        hosts domain|ip.address              --  show filterd lines
        hosts                                --  show hosts file

# do not use comments in hosts file.'
fi


if echo $host | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' 1>/dev/null 2>&1
then
	IS_IP=1
else
	IS_IP=
fi

run(){
	while read line
	do
		if [ -z "$line" ]; then
			continue
		fi
		each_line $line
	done < "/etc/hosts"
}


res=$2

if [ -z "$host" ]; then
	each_line(){ # 显示全部
		echo -en "$1\r\t\t"
		shift
		echo $*
	}
	run
	exit 0
fi



if [ "$host" = "delete" -o "$host" = "-d" ]; then # 删除一行
	each_line(){
		if [ $IS_IP ]; then
			if [ "$1" != "$res" ]; then
				echo $*
			fi
		else
			if [ "$2" != "$res" ]; then
				echo $*
			fi
		fi
	}
	exec 1> /tmp/hosts
	run
	cat /etc/hosts > ${MY_SCRIPT_ROOT}/temp/hosts.`date +%s`
	cat /tmp/hosts > /etc/hosts
	exit 0
fi
	
if [ -n "$res" ]; then # 修改
	EDIT=""
	each_line(){
		if [ "$2" = "$host" ]; then
			oip=$1
			ohost=$2
			shift ; shift
			echo -e "${res}\t${host}\t${*}"
			EDIT=1
			echo "修改了${ohost} : ${oip} -> ${res}" >&2
		else
			echo -ne "$1\t$2"
			shift ; shift
			if [[ -n "$*" ]]; then
				echo -e "\t$*"
			else
				echo
			fi
		fi
	}

	exec 1> /tmp/hosts
	run
	if [[ "$EDIT" -ne 1 ]]; then
		echo -e "${res}\t${host}"
		echo "添加了${host} : ${res}" >&2
	fi

	cat /etc/hosts > ${MY_SCRIPT_ROOT}/temp/hosts.`date +%s`
	cat /tmp/hosts > /etc/hosts
	exit 0
fi

 # 显示部分
if [ $IS_IP ]; then
	each_line(){
		case $1 in
		*"$host"*)
			echo $2
		esac
	}
else
	each_line(){
		case $2 in
		*"$host"*)
			echo $1
		esac
	}
fi
run
exit 0
