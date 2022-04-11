#!/bin/sh
if [ -z "$2" ]
then
    ~/.mockingbird/mitmproxy/mitmdump_mbv2
else
    ~/.mockingbird/mitmproxy/mitmdump_mbv2 --allow-hosts "$2"
fi
