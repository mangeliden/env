#!/bin/bash
interval=0

## Check for interval parameter
if [ $# -eq 1 ]; then
    if [ $1 -gt 0 ]; then
        interval=$1
    else
        interval=1
    fi
fi

proc=`adb shell "ps" | grep com.ascom.pocket`
if [ $? -ne 0 ]; then
    echo "Pocket process not found"
    exit 1
fi

#echo "Process: $proc"
pid=`echo $proc | awk '{print $2}'`
#echo "PID: $pid"

cmd="adb shell ps $pid"
if [ $interval -gt 0 ]; then
    watch -n $interval $cmd
else
    eval $cmd
fi
