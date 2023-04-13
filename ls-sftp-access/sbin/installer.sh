#!/bin/bash

toInstall=""

which rpm 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    which yum 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        rpm -q jq 2>&1 >/dev/null
        if [ $? -ne 0 ]; then
           toInstall="$toInstall jq" 
        fi

        rpm -q autofs 2>&1 >/dev/null
        if [ $? -ne 0 ]; then
           toInstall="$toInstall autofs" 
        fi

        if [ "$toInstall" != "" ]; then
            yum install -y $toInstall
        fi
    else
        echo "Error: no yum"
    fi
else
    echo "Error: no rpm"
fi

