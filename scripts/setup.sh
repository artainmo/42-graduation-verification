if [ "$(uname)" = "Darwin" ]; then #mac
	jq --version &>/dev/null
	if [ $? -ne 0 ]; then
		brew install jq
	fi
elif [ "$(uname)" = "Linux" ]; then #linux
	jq --version &>/dev/null
	if [ $? -ne 0 ]; then
		sudo apt-get install jq
	fi
else #windows
	jq --version &>/dev/null
	if [ $? -ne 0 ]; then
		curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
	fi
fi
