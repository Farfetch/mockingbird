#!/bin/sh
if [ -z "$2" ]
then
    ~/.mockingbird/mitmproxy/mitmdump_mb
else
    ~/.mockingbird/mitmproxy/mitmdump_mb --allow-hosts "$2"
fi
