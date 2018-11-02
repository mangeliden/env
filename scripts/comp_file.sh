#!/bin/bash



the_file=$1
curr_secs=`date +%s`

## Calc file timestamp
file_timestamp=`stat $the_file | grep -i change | awk '{print $2 " " $3}'`
file_secs=`date -d "$file_timestamp" +%s`


diff=`expr $curr_secs - $file_secs`

if [ $diff -gt 300 ]; then
    echo ""
    echo "Warning! The file $the_file is more than 5 minutes old. ($file_timestamp)"
    echo ""
    exit 1
else
    exit 0
fi
