#!/bin/sh
activeNetwork="Wi-Fi"
activeNetworkName=$(networksetup -listallhardwareports | grep -B 1 "$activeNetwork" | awk '/Hardware Port/{ print }'|cut -d " " -f3-)
echo "$activeNetworkName:"
networksetup -getinfo "$activeNetworkName"
echo "\n"
activeNetwork=$(route get default | grep interface | awk '{print $2}')
activeNetworkName=$(networksetup -listallhardwareports | grep -B 1 "$activeNetwork" | awk '/Hardware Port/{ print }'|cut -d " " -f3-)
echo "$activeNetworkName:"
networksetup -getinfo "$activeNetworkName"


