#!/bin/bash

## Check input
if [ $# -eq 0 ]; then
    echo "Need text as input"
    exit 1
fi

text=$1
escaped=`echo $text | sed "s/\s/\%s/g"`
adb shell input text "$escaped"
