#!/bin/bash
lowerLetters=("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z")
upperLetters=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")
numbers=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")

whitelistUsers=("root" "sysadmin" "sshd" "sync" "_apt" "nobody")
suspiciousFileNames=("shell.php" "template.php")
suspiciousServices=("minecraft" "discord" "snapchat" "systemb")
getFileContAsArray() #usage: "getFileCont {file name} {array variable name}"
{
	local fileName="$1"
	local -n arr="$2"
	if [[ ! -f "$fileName" ]]; then
		return 1
	fi
	mapfile -t arr < "$fileName"
}
getLoginList() {
    login_output=$(who 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo ""
        return
    fi
    IFS=$'\n' read -r -d '' -a login_array <<< "$login_output"$'\n'
    echo "${login_array[@]}"
}
getFileContAsStr()
{
	local fileName="$1"
	local -n fileCont="$2"
	if [[ ! -f "$fileName" ]]; then
        fileCont=""
	else
		fileCont=$(<"$fileName")
    fi
}
getCommandOutputAsStr()
{
	local -n output="$2"
	output="$($1)"
}
getCommandOutputAsArray()
{
	local -n output="$2"
    mapfile -t output < <("$1")
}
userInWhitelist() 
{
    local user="$1"
	local -n result="$2"
	result="4"
    for entry in "${whitelistUsers[@]}"; do
        if [[ "$entry" == "$user" ]]; then
            result="2"
        fi
    done
    if [[ ! $result == "2" ]]; then
		result="3"
	fi
}
while true; do
#Checking for unknown users
getFileContAsArray "/etc/passwd" passwdConts
for line in "${passwdConts[@]}"; do
	IFS=":" read -ra userInfo <<< "$line"
	username=${userInfo[0]}
    declare -i uid=${userInfo[2]}
    declare -i gid=${userInfo[3]}
	userInWhitelist $username isInWhitelist
	if [[ $uid -gt 999 || $gid -gt 999 ]] && [[ $isInWhitelist == "3" ]]; then
		userdel -f $username
		current_time=$(date +"%H:%M:%S")
		log="[ $current_time ] - An unknown user with UID/GID above 999 was found and removed: $username"
		echo $log >> /var/log/gemini.log
	fi
isInWhitelist=""
done
#Checking for malicious services
getCommandOutputAsArray "systemctl list-unit-files" serviceList
for line in "${serviceList[@]}"; do
	for maliciousService in "${suspiciousServices[@]}"; do
		if [[ "$line" == *"$maliciousService"* ]]; then
			systemctl stop "$maliciousService"
            systemctl disable "$maliciousService"
            mkdir /.quarantine/Q-S-"$maliciousService"
            mv /etc/systemd/system/"$maliciousService".service /.quarantine/Q-S-"$maliciousService"
            mv /usr/lib/systemd/system/"$maliciousService".service /.quarantine/Q-S-"$maliciousService"
            systemctl daemon-reload
            systemctl reset-failed
			current_time=$(date +"%H:%M:%S")
            log = "[ $current_time ] - A suspicious service was found and quarintined: $maliciousService"
            echo "$log" >> /var/log/gemini.log
		fi
	done
done
#Checking for crontab changes
getFileContAsStr "/etc/crontab" crontabCont
if [[ ! "${#crontabCont}" == 0 ]]; then
	if [[ ! "$crontabCont" == "\n" ]]; then
		echo "" > /etc/crontab
		current_time=$(date +"%H:%M:%S")
		log="[ $current_time ] - Changes were detected in /etc/crontab and removed: $crontabCont"
		echo $log >> /var/log/gemini.log
	fi
fi
#Checking for common reverse shell practices

#Checking for remote logins
loginList=($(getLoginList))
#Checking for suspicious files in a webserver

sleep 60
done