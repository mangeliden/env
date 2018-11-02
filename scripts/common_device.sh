#!/bin/bash

function num_devices()
{
    num_devs=`adb devices -l | grep "device usb:" | wc -l`
    if [ $num_devs -lt 1 ]; then
        echo "No devices connected!"
        exit 1
    fi
}

function select_devices()
{
    local __input_all=$1
    #local __result_var=$2

    declare -A __device_array
    declare -A __device_index_array

    ## Grab all devices
    device_list=`adb devices | tail -n +2 | awk '{print $1}'`
    index=1
    for dev_id in $device_list
    do
        device_name=`adb devices -l | grep $dev_id | sed 's/.*model:\([a-zA-Z0-9\-\_]*\).*/\1/g'`
        #echo "Device index: $dev_id -> $index"
        __device_array[$dev_id]=$device_name
        __device_index_array[$index]=$dev_id
        let "index += 1"
    done

    index=1
    if [ $__input_all -eq 0 ]; then

        ## Provide selection menu
        echo ""
        for key in "${!__device_index_array[@]}"
        do
            echo "$key. ${__device_array[${__device_index_array[$key]}]} -> ${__device_index_array[$key]}"
            let "index += 1"
        done

        sel_size=${#__device_array[@]}
        echo ""
        echo -n "Enter device 1-$sel_size or 'a' for all: "
        read selection

        selected_devices=`echo $selection | sed 's/,/ /g'`

        ## Process selection
        if [ $selected_devices == "a" ]; then
            all=1
        else
            unset __device_array
            declare -A __device_array
            for sel in $selected_devices
            do
                dev_id=${__device_index_array[$sel]}
                echo "Selected device: $sel - $dev_id"
                name=${__device_index_array[$sel]}
                echo "Name: $name"

                __device_array[$dev_id]=$name
            done

        fi
    fi

    ## Assign to global array
    for key in "${!__device_array[@]}"
    do
        device_array[$key]=${__device_array[$key]}
    done

}

function adb_shell_cmd()
{
    device=$1
    cmd=$2

    echo "Device: $device Cmd: $cmd"
    adb -s $device shell $cmd
}
