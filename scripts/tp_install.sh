#!/bin/bash
def_apk=QtApp-debug.apk

## Check input
reinstall=0
apk=$def_apk
## Getopts
while getopts "ra:" opt; do
  case $opt in
    r)
      reinstall=1
      ;;
    a)
      $apk=$OPTARG
      ;;
    \?)
      echo "Usage: tp_input.sh [-r] [filename]"
      exit 2
      ;;
    esac
done


device_list=`adb devices | tail -n +2 | awk '{print $1}'`
for d in $device_list;
do
    echo "DEV: $d"
done;
## adb devices -l | grep 9b6cc6ac | sed 's/.*model.\([a-zA-Z0-9\-\_]*\).*/\1/g'
## adb devices | tail -n +2 | awk '{print $1}'

## Check connected devices
num_devs=`adb devices -l | grep device: | wc -l`
if [ $num_devs -gt 1 ]; then
    echo "Multiple devices not supported yet, please unplug!"
    exit 1
elif [ $? -eq 0 ]; then
    echo "Please plug in device!"
    exit 1
fi



## Find APK
find_apk=`find . -name $apk`
if [ "x$find_apk" = "x" ]; then
    echo "Could not find $apk!"
    exit 1
fi


## Check build time
which comp_file.sh &> /dev/null
if [ $? -eq 0 ]; then
    comp_file.sh $find_apk
    ##if [ $? -ne 0 ]; then
    ##    echo ""
    ##fi
else
    echo "Please check build timestamp!"
fi


## Print timestamp
date

## Check package and uninstall, skip if -r
if [ $reinstall -eq 0 ]; then
    adb shell 'pm list packages' | grep com.ascom.pocket &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Skip uninstall of pocket, since not found."
    else
        ## Uninstall
        echo -n "Uninstalling com.ascom.pocket..."
        uninst=`adb uninstall com.ascom.pocket`
        echo "$uninst"
    fi
fi

## If uninstall fails...


## Install
echo -n "Installing $find_apk..."
if [ $reinstall -eq 0 ]; then
    inst=`adb install $find_apk`
else
    inst=`adb install -r $find_apk`
fi
echo "Result: $inst"



exit 0
