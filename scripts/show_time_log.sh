#!/bin/bash
filename=$TIME_LOG
month="$1"
echo "FILE: $filename"
while read -r line
do
    date1=`echo $line | awk -F',' '{ print $1 }'`
    date2=`echo $line | awk -F',' '{ print $2 }'`
    datediff=`date -d @$(( $(date -d "$date2" +%s) - $(date -d "$date1" +%s))) -u +'%H:%M:%S'`
    dateover=`date -d @$(( $(date -d "$date2" +%s) - $(date -d "$date1" +%s) - 27900 )) -u +'%H:%M:%S'`
#    dateover=`expr $(( $(date -d "$date2" +%s) - $(date -d "$date1" +%s) - 27900 - 2700 ))`
#    if [ $dateover -gt 0 ]; then
#        dateover=`date -d $dateover -u +'%H:%M:%S'`
#    fi
    echo "$date1 -> $date2 = $datediff excl 45min lunch ($dateover)"
done < "$filename"
