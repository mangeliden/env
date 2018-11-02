#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Provide integration build number";
    exit 2
fi

build=$1
wget http://jenkins.ascom.ads/job/pocket/$build/artifact/applications/pocketservice/android-build/bin/PocketService.apk
wget http://jenkins.ascom.ads/job/pocket/$build/artifact/applications/pocketui/android-build/bin/Pocket.apk
