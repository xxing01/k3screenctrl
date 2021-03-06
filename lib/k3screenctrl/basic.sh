#!/bin/sh
. /etc/openwrt_release

PRODUCT_NAME_FULL=$(cat /etc/board.json | jsonfilter -e "@.model.name")
PRODUCT_NAME=${PRODUCT_NAME_FULL#* } # Remove first word to save space
router_uptime=$(uci get k3screenctrl.@general[0].router_uptime)
disp=$(uci get k3screenctrl.@general[0].cputemp)
HW_VERSION=$(cat /etc/openwrt_release | grep -w "DISTRIB_RELEASE"| awk '{print $1}' |awk -F"'" '{print $2}')
FW_VERSION=$HW_VERSION" By stones"

echo $PRODUCT_NAME

if [ "$disp" -eq 1 ]; then
	CPU_TEMP=$(awk 'BEGIN{printf "%.2f\n",'$(cat /sys/class/thermal/thermal_zone0/temp)'/1000}')"'C"
	echo $CPU_TEMP
else
	echo $HW_VERSION
fi

echo $FW_VERSION

if [ "$router_uptime" -eq 0 ]; then
	LAN_ADDR=`ifconfig br-lan |grep -w "inet addr"| awk '{print $2}'|awk -F':' '{print $2}' 2>/dev/null`
	[ -z "$LAN_ADDR" ] && LAN_ADDR=`uci get network.lan.ipaddr 2>/dev/null`
	[ -z "$LAN_ADDR" ] && LAN_ADDR="p.to"
	echo $LAN_ADDR
elif [ "$router_uptime" -eq 1 ]; then
	RUPTIME=$(awk '{print int($1/86400)"days "int($1%86400/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime)
	echo $RUPTIME
else
	WAN_IFNAME=$(uci get network.wan.ifname)
	MAC_ADDR=$(ifconfig $WAN_IFNAME 2>/dev/null | grep -oE "([0-9A-Z]{2}:){5}[0-9A-Z]{2}")
	[ -z "$MAC_ADDR" ] && MAC_ADDR=$(ifconfig eth0 2>/dev/null | grep -oE "([0-9A-Z]{2}:){5}[0-9A-Z]{2}")
	echo $MAC_ADDR
fi
