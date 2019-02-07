#!/bin/bash
cd ..
printf "Please select a feature:\n1:TODO Log\n2:\n3:\n4:\n5:\nSelection:"
read input
if [ $input = "1" ];then
	if [ -f Project01/logs/todo.log ];then
		rm -r Project01/logs
		mkdir -p Project01/logs
		touch Project01/logs/todo.log
	else
		mkdir -p Project01/logs
		touch Project01/logs/todo.log
	fi
	grep -rh "#TODO" > Project01/logs/todo.log
fi
if [ $input = "2" ];then
	printf "that feature doesn't exist yet\n"
fi
if [ $input = "3" ];then
	printf "that feature doesn't exist yet\n"
fi
if [ $input = "4" ];then
	printf "that feature doesn't exist yet\n"
fi
if [ $input = "5" ];then
	printf "that feature doesn't exist yet\n"
fi
