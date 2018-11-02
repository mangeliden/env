#!/bin/bash
echo "Source: /sdcard/pocket/logfiles/$1"
echo "Dest:  ~/vm_shared/logs/$1"
adb pull /sdcard/pocket/logfiles/$1 ~/vm_shared/logs/
