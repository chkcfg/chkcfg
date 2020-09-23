#!/bin/bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
		SYSTEM="linux"
	    ;;
    Darwin*)
		SYSTEM="macos"
	    ;;
    *)
	    echo "Unknown OS"
	    exit
	    ;;
esac

TITLE()
{
	echo ""
	echo ""
	echo "============================================"
	echo "$*"
	echo "============================================"
}

{
	echo "Creation Date:"
	date +"%A %d/%m/%Y %H:%M %z"

	TITLE "System Info"
	if [[ "$SYSTEM" = "macos" ]]; then
		sw_vers
		system_profiler SPHardwareDataType | grep 'Model\|Processor\|Memory'
		diskutil info /dev/disk1 | grep 'Disk Size'
	elif [[ "$SYSTEM" = "linux" ]]; then
		lshw -short
	fi

	TITLE "Check HostName"
	if [[ "$SYSTEM" = "macos" ]]; then
		hostname
	elif [[ "$SYSTEM" = "linux" ]]; then
		echo "-RESERVED-"
	fi

	if [[ "$SYSTEM" = "macos" ]]; then
		TITLE "Check Filevault Status"
		fdesetup status
	elif [[ "$SYSTEM" = "linux" ]]; then
		TITLE "-LINUX DISK ENCRYPTION RESERVED-"
	fi

	if [[ "$SYSTEM" = "macos" ]]; then
		TITLE "Check Avira Free Antivirus"
		if launchctl list | grep -q avira; then
			echo "App is running"
		else
			echo "App is not running"
		fi
	elif [[ "$SYSTEM" = "linux" ]]; then
		TITLE "-LINUX ANTIVIRUS RESERVED-"
	fi

	if [[ "$SYSTEM" = "macos" ]]; then
		TITLE "Check Firewall Status"
		if [ $(defaults read /Library/Preferences/com.apple.alf globalstate) -eq 0 ]; then
			echo "Firewall is disabled"
		else
			echo "Firewall is enabled"
		fi
	elif [[ "$SYSTEM" = "linux" ]]; then
		TITLE "- LINUX FIREWALL RESERVED-"
	fi


	TITLE "List Of All Network Hardware Ports"
	if [[ "$SYSTEM" = "macos" ]]; then
		networksetup -listallhardwareports
	elif [[ "$SYSTEM" = "linux" ]]; then
		nmcli device status
	fi

	TITLE "ifconfig"
	if [[ "$SYSTEM" = "macos" ]]; then
		ifconfig
	elif [[ "$SYSTEM" = "linux" ]]; then
		ip a
	fi

	TITLE "/etc/hosts"
	cat /etc/hosts | grep -v "#"

	TITLE "/etc/resolv.conf"
	cat /etc/resolv.conf | grep -v "#"

	TITLE "nslookup cisco-vpn.itransition.com"
	nslookup cisco-vpn.itransition.com

#	TITLE "traceroute -m5 cisco-vpn.itransition.com"
#	traceroute -m5 cisco-vpn.itransition.com

	TITLE "Test connection to cisco-vpn.itransition.com"
	nc -z -v -G5 cisco-vpn.itransition.com 443 &> /dev/null
	result1=$?
	if [  "$result1" != 0 ]; then
  		echo "Website unavailable"
	else
		echo "Website available"
	fi

	TITLE "Route Print"
	if [[ "$SYSTEM" = "macos" ]]; then
		netstat -nr
	elif [[ "$SYSTEM" = "linux" ]]; then
		ip ro list table all
	fi

	TITLE "Proxy"
	if [[ "$SYSTEM" = "macos" ]]; then
		scutil --proxy
	elif [[ "$SYSTEM" = "linux" ]]; then
		env | grep -i proxy
	fi
} > $HOME/Desktop/REPORT.txt
# $HOME/Desktop/REPORT-"`date +"%Y-%m-%d-%H%M%S"`".txt