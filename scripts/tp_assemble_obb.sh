#!/bin/bash
export PATH=$PATH:/development/android-sdk/build-tools/22.0.1:/development/android-sdk/tools/jobb
echo $PATH
echo "TEMS Pocket OBB packaging"

WORKSPACE=/home/semali/git/pocket/playinstaller16_main
workdir=$WORKSPACE/pocket_install


## Path to install script
install_script=$WORKSPACE/app/src/main/res/raw/installation.xml
install_schema=$WORKSPACE/app/src/main/res/raw/installation_schema.xsd
xmllint $install_script --schema $install_schema --noout
if [ $? -ne 0 ]; then
   echo "installation.xml failed validation!"
   exit 1;
fi

## Create working directory
if [ ! -d "$workdir" ]; then
    ## Directory does not exist
    mkdir -p $workdir
fi
cd $workdir


## Get install script APKs
apks=`xmlstarlet sel -t -v //_:FileName $install_script`
for apk in $apks; do
    dir=`dirname $apk`
    echo "Create dir: $dir"
    mkdir -p $dir

    echo "Fetching APK: $apk"
    cp "$WORKSPACE/pocketinstaller/$apk" "$apk"
done;

## Get install script resources
resources=`xmlstarlet sel -t -v //_:InstallerModule//_:InputFile $install_script`
for res in $resources; do
    dir=`dirname $res`
    echo "Create dir: $dir"
    mkdir -p $dir

    echo "Fetching file: $res"
    cp "$WORKSPACE/pocketinstaller/$res" "$res"
done;


## Copy install script
script_base_name=`basename $install_script`
rm -f "$workdir/$script_base_name"
cp $install_script $workdir
if [ $? -ne 0 ]; then
    echo "Could not copy install script $install_script to $workdir!"
    exit 2
fi

## VersionCode from APK
playinstaller_apk=`find $WORKSPACE -name PlayInstaller.apk`
echo "Grab package version from: $playinstaller_apk"
pv=`/development/android-sdk/build-tools/22.0.1/aapt dump badging $playinstaller_apk | sed '/^package/ !d' | sed 's/.*versionCode=.\([0-9]*\).*/\1/g'`
echo "Package version for OBB file: $pv"

# Parameters
## Package Name
pn="com.ascom.playinstaller16"

## Future
key="password"
out="$WORKSPACE/main.$pv.$pn.obb"

## Run JOBB
/development/android-sdk/tools/jobb -v -pn $pn -pv $pv -d $workdir -o $out

## Dump OBB info
if [ $? -eq 0 ]; then
    echo "Created file: $out"
    /development/and#!/bin/bash
export PATH=$PATH:/development/android-sdk/build-tools/23.0.3/development/android-sdk/tools/jobb
echo $PATH
echo "TEMS Pocket OBB packaging"

workdir=/home/semali/vm_shared/installers/16.3.4_RC5/pocketinstaller/apk


## Path to install script
install_script=$WORKSPACE/app/src/main/res/raw/installation.xml
install_schema=$WORKSPACE/app/src/main/res/raw/installation_schema.xsd
xmllint $install_script --schema $install_schema --noout
if [ $? -ne 0 ]; then
   echo "installation.xml failed validation!"
   exit 1;
fi

## Create working directory
if [ ! -d "$workdir" ]; then
    ## Directory does not exist
    mkdir -p $workdir
fi
cd $workdir


## Get install script APKs
apks=`xmlstarlet sel -t -v //_:FileName $install_script`
for apk in $apks; do
    dir=`dirname $apk`
    echo "Create dir: $dir"
    mkdir -p $dir

    echo "Fetching APK: $apk"
    cp "$WORKSPACE/pocketinstaller/$apk" "$apk"
done;

## Get install script resources
resources=`xmlstarlet sel -t -v //_:InstallerModule//_:InputFile $install_script`
for res in $resources; do
    dir=`dirname $res`
    echo "Create dir: $dir"
    mkdir -p $dir

    echo "Fetching file: $res"
    cp "$WORKSPACE/pocketinstaller/$res" "$res"
done;


## Copy install script
script_base_name=`basename $install_script`
rm -f "$workdir/$script_base_name"
cp $install_script $workdir
if [ $? -ne 0 ]; then
    echo "Could not copy install script $install_script to $workdir!"
    exit 2
fi

## VersionCode from APK
playinstaller_apk=`find $WORKSPACE -name PlayInstaller.apk`
echo "Grab package version from: $playinstaller_apk"
pv=`/development/android-sdk/build-tools/22.0.1/aapt dump badging $playinstaller_apk | sed '/^package/ !d' | sed 's/.*versionCode=.\([0-9]*\).*/\1/g'`
echo "Package version for OBB file: $pv"

# Parameters
## Package Name
pn="com.ascom.playinstaller16"

## Future
key="password"
out="$WORKSPACE/main.$pv.$pn.obb"

## Run JOBB
/development/android-sdk/tools/jobb -v -pn $pn -pv $pv -d $workdir -o $out

## Dump OBB info
if [ $? -eq 0 ]; then
    echo "Created file: $out"
    /development/android-sdk/tools/jobb -k $key -dump $out
fi
