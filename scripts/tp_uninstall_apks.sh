#!/bin/bash

all=0

## Getopts
while getopts "a" opt; do
  case $opt in
    a)
      all=1
      ;;
    \?)
      echo " Usage: tp_uninstall_apks.sh [-a]"
      echo "Option: -a For all apks incl ondevice"
      exit 2
      ;;
    esac
done

pocket_apks=`adb shell ps | grep pocket | awk '{gsub(/\./,"@",$0);print $NF}'`
for pock in $pocket_apks; do
    uninst=`echo $pock | sed 's/@/\./g'`
    echo "Uninstall pocket: $uninst"
    adb uninstall $uninst
done

if [ $all -eq 1 ]; then

    ondevice=`adb shell ps | grep ondevice | awk '{gsub(/\./,"@",$0);print $NF}'`
    for od in $ondevice; do
        echo "Uninstall ODM: $od"
        #adb uninstall $od
    done

fi
