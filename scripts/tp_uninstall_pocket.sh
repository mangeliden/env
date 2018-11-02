#!/bin/sh
#

echo "com.tems.pocket.service"
adb uninstall com.tems.pocket.service
echo "com.tems.pocket"
adb uninstall com.tems.pocket
echo "com.tems.workflow"
adb uninstall com.tems.workflow
