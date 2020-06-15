#!/bin/sh
/usr/local/bin/mitmdump --set upstream_cert=false --ssl-insecure -s $1
