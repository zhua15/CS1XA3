How to use script:
First, type ./project_analyze.sh into the command line. You will be prompted with a list of features, and you will
need to type in the number corresponding to the feature in order to run that feature.
1. TODO Log
	The TODO Log feature recursively searches through all files within the repo and outputs all cases of the 
	string "#TODO" into a file named todo.log in REPO/Project01/logs.
2. Compile Error Log
	The Compile Error Log feature recursively searches through all files within the repo and outputs all python
	and haskell files where there is a syntax error. It then puts the files with syntax errors into a file named
	compileError.log in REPO/Project01/logs.
3. Delete Temporary Files
	The Delete Temporary Files feature recursively searches through all files within the repo and deletes all
	files ending with .tmp
4. Find Big Files
	The Find Big Files feature finds files with sizes greater than 20MB within the repo
