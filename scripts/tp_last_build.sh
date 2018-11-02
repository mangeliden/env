#!/bin/bash

## Check input
if [ $# -eq 0 ]; then
    echo "Using integration as default branch"
    APK="http://ntseskrdp34.ascom.ads/job/pocket/lastSuccessfulBuild/artifact/android-build/bin/Pocket.apk"
else
    echo "Fetching apk from feature $1..."
    APK="http://ntseskrdp34.ascom.ads/view/Feature%20$1/job/Feature$1-Android-Pocket/lastSuccessfulBuild/artifact/android-build/bin/Pocket.apk"
fi
echo "APK: $APK"

wget $APK
