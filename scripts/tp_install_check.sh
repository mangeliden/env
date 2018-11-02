#!/bin/bash

for i in ~/Desktop/pocketinstaller/apk
  do for j in "$i"/*.apk;
    do
      LOCAL_VN="$(aapt dump badging "$j" | tr " " \\n | tr -d "'" | grep versionName)"
      LOCAL_VC="$(aapt dump badging "$j" | tr " " \\n | tr -d "'" | grep versionCode)"
      echo "$j $LOCAL_VN $LOCAL_VC"
  done
done


for i in ~/Desktop/pocketinstaller/apk
  do for j in "$i"/*.apk;
    do
      LOCAL_VN="$(aapt dump badging "$j" | tr " " \\n | tr -d "'" | grep versionName)"
      PCK_ID="$(aapt dump badging "$j" | grep package:\ name | tr " " \\n | tr -d "'" | sed 's/name=//g' | grep com.)"
      DEVICE_VN="$(adb shell dumpsys package "$PCK_ID" | tr " " \\n | grep versionName)"
      if [[ $j != *"apkversion"* ]] && [[  $j != *"DeviceId"* ]] ; then
          DIFF="$(diff -w <(echo "$LOCAL_VN") <(echo "$DEVICE_VN"))"
      fi
      if [ "$DIFF" != "" ]  ; then
         echo "$(tput setaf 1)" "$j" "mismatch:" $DIFF
      else
         if [[ $j != *"apkversion"* ]] && [[  $j != *"DeviceId"* ]] ; then
           echo "$(tput setaf 2)" "$j"
         fi
      fi
  done
done
