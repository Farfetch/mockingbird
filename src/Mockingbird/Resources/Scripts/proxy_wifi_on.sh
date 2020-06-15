#!/bin/sh
networksetup -setwebproxy "Wi-Fi" localhost 8080 off
networksetup -setsecurewebproxy "Wi-Fi" localhost 8080 off
