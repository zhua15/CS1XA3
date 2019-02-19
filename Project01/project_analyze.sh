#/bin/bash
cd ..
printf "Please select a feature:\n1:TODO Log\n2:Compile Error Log\n3:Delete Temporary Files\n4:Find Big File\n5:\nSelection:"
read input
if [ $input = "1" ];then
	if [ -f Project01/logs/todo.log ];then
		rm Project01/logs/todo.log
		touch Project01/logs/todo.log
	else
		touch Project01/logs/todo.log
	fi
	grep -rh "#TODO" > Project01/logs/todo.log
fi
if [ $input = "2" ];then
	if [ -f Project01/logs/compileError.log ];then
		rm Project01/logs/compileError.log
		touch Project01/logs/compileError.log
	else
		touch Project01/logs/compileError.log
	fi
	find . -name '*.py' -type f -print0 | while IFS= read -d $'\0' file
	do
		output="$(python $file)"
		if echo "SyntaxError: invalid syntax" | grep -q "$output";then
			echo $file >> Project01/logs/compileError.log
		fi
	done
	find . -name '*.hs' -type f -print0 | while IFS= read -d $'\0' file
        do
                output="$(runhaskell $file)"
                if echo "Not in scope:" | grep -q "$output";then
                        echo $file >> Project01/logs/compileError.log
                fi
        done
fi
if [ $input = "3" ];then
	find . -name '*.tmp' -type f -print0 | while IFS= read -d $'\0' file
	do
		rm $file
	done
fi
if [ $input = "4" ];then
	count=0
	find . -size +20M -type f -print0 | while IFS= read -d $'\0' file
	do
		echo $file
	done
fi
if [ $input = "5" ];then
	printf "that feature doesn't exist yet\n"
fi
