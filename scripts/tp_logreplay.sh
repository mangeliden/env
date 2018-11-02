#!/bin/bash
replay_file=/tmp/replay.cfg
tp_replay_file_dir=/sdcard/pocket
tp_logfile_dir=/sdcard/pocket/logfiles


## Check input
if [ $# -eq 0 ]; then
    echo "Need logfile as input!"
    exit 1
fi

## 1st parameter is the logfile to replay
logfile=$1
stat $logfile &> /dev/null
if [ $? -ne 0 ]; then
    echo "Logfile $logfile does not exist!"
    exit 1
fi
echo "Using file $logfile..."

## Create file replay.cfg  with content:
## radio=/sdcard/pocket/logfiles/<logfile>
echo "Creating $replay_file..."
logfile_base=`basename $logfile`
echo "radio=$tp_logfile_dir/$logfile_base" > $replay_file

## Push logfile to /sdcard/pocket/logfiles
echo "Push $logfile to $tp_logfile_dir..."
adb push $logfile $tp_logfile_dir

## Push replay.cfg to /sdcard/pocket
echo "Push $replay_file to $tp_replay_file_dir..."
adb push $replay_file $tp_replay_file_dir

## Print information about code exclusion


exit 0
