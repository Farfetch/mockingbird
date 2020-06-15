#!/bin/sh
activeNetwork=$(route get default | grep interface | awk '{print $2}')
activeNetworkName=$(networksetup -listallhardwareports | grep -B 1 "$activeNetwork" | awk '/Hardware Port/{ print }'|cut -d " " -f3-)
networksetup -setwebproxy "$activeNetworkName" localhost 8080 off
networksetup -setsecurewebproxy "$activeNetworkName" localhost 8080 off
