#!/bin/bash

## Vars
declare rats
declare -A rat_array
declare model
declare device_data
declare devroot

devroot="DeviceConfigurations"



function print_devices()
{
    devices=`xmlstarlet sel -t -v "$devroot/DeviceConfiguration/@name" $devicefile`
    device_count=`xmlstarlet sel -t -v "count($devroot/DeviceConfiguration/@name)" $devicefile`
    echo ""
    echo "## DEVICE LIST ##"
    echo "$devices"
    echo ""
    echo "Device count: $device_count"
    echo ""
}


## Getopts
while getopts "a" opt; do
  case $opt in
    a)
      print_devices
      exit 0
      ;;
    \?)
      echo "Usage: tp_device.sh [--list | -l]"
      exit 2
      ;;
    esac
  done

  ## Usage
  if [ $# -eq 0 ]; then
      echo "Usage:"
      echo "tp_device.sh \"<device>\""
      echo ""
      exit 0
  fi


function get_device_data()
{
    device_data=`xmlstarlet sel -t -c "$devroot/DeviceConfiguration[@name=\"$device\"]" $devicefile `
}


## Model
function get_model()
{
    local device_data=$1
    model=`echo $device_data | xmlstarlet sel -t -v "DeviceConfiguration/Model" `
}

function set_rat_lock()
{
    ##local data=$1
    local rat=$1
    echo $(ctrl_func_xml) | xmlstarlet ed -u "ControlFunction/RatLock/RAT" -v $rat
}

## Gather rats for device
function get_rats()
{
    rats=`echo $1 | xmlstarlet sel -t -v "DeviceConfiguration/RadioAccessTechonologies/RAT_GROUP/RAT" `
}


## Gather bands of rats
function get_bands()
{
    local lrats=$1
    for rat in $lrats;
    do
        rat_array[$rat]=`echo $device_data | xmlstarlet sel -t -c "DeviceConfiguration/SupportedBands/$rat/Band" | sed -e 's/<Band>//g' | sed -e 's/<\/Band>/ /g' `
    done
}


function gen_rat_lock()
{
    local rat=$1
}

function gen_band_lock()
{
    local band=$1
}

function ctrl_func_xml()
{
    "<ControlFunction><RatLock><RAT>Off</RAT></RatLock></ControlFunction>"
}


## PreChecks

## First check for xmllint
depcmd=xmlstarlet
which $depcmd &>/dev/null
if [ $? -ne 0 ]; then
    echo "$depcmd not found ->  sudo apt-get install xmlstarlet"
    exit 1
fi

## Check for first occurence of device config
devfile="DeviceConfigurations.xml"
devicefile=`find . -name $devfile | head -1`

if [ -z "$devicefile" ]; then
    echo "Could not find $devfile, exiting!"
    exit 2
else
    echo "Found device cfg: $devicefile"
fi





## Input args
device=$1



## MAIN
get_device_data
get_model "$device_data"

echo ""
echo "Config file: $devicefile"
echo "Device:      $device"
echo "Model:       $model"
echo ""


get_rats "$device_data"
get_bands "$rats"

for i in "${!rat_array[@]}"
do
  echo "RAT  : $i"
  echo "Band : ${rat_array[$i]}"
done

myrat="LTE"
set_rat_lock "$myrat"
echo "LOCK: $lock"


echo ""
