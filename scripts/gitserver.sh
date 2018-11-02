#!/bin/bash

## Checking repo
if [ -s /usr/local/bin/repo ]
then
 echo "Correct size on repo"
else
 sudo rm /usr/local/bin/repo
 wget -O /usr/local/bin/repo http://commondatastorage.googleapis.com/git-repo-downloads/repo
 sudo chmod a+x /usr/local/bin/repo
fi


## Setting PATH
grep -qb "PATH" ~/.bashrc || sudo sed -i '$ a PATH=$PATH:/development/android-sdk/tools:/development/Qt/qt-ubuntu/bin:/development/QtExtension/bin/unix' ~/.bashrc 
grep -qb "export PATH" ~/.bashrc || sudo sed -i '$ a export PATH' ~/.bashrc
grep -qb "LD_LIBRARY_PATH" ~/.bashrc || sudo sed -i '$ a LD_LIBRARY_PATH=/development/QtExtension/bin/unix' ~/.bashrc
grep -qb "export LD_LIBRARY_PATH" ~/.bashrc || sudo sed -i '$ a export LD_LIBRARY_PATH' ~/.bashrc

add_to_path() 
  {
    echo "Add $1 to path"
    if [ -d "$1" ] && [[ ! $PATH =~ (^|:)$1(:|$) ]]; then 
       PATH+=:$1      
    fi
  }

add_to_path /development/android-sdk/tools
add_to_path /development/Qt/qt-ubuntu/bin
add_to_path /development/QtExtension/bin/unix

sed -i 's;^PATH=.*;PATH='"$PATH"';' ~/.bashrc

## Checking Ascom development environment
DEVDIR=/development
ANDROID_NDK_VERSION=r12b
ANDROID_SDK_VERSION=r20.0.3

# Check that git is installed
if dpkg -l git | grep git > /dev/null 2>&1 ; then
  echo "Git is installed. Good."
else
  echo "Installing git"
  sudo apt-get install git gitk git-gui
fi

# Check that git is configured
if git config --list | grep user > /dev/null 2>&1 ; then
  echo "Git is configured. Good."
else
  echo "Configuring git"
  MAIL=`ldapsearch -LLL -Q "(name=$USER)" | grep mail: | sed 's/.*[:]//'`
  git config --global user.name $USER
  git config --global user.email $MAIL
fi

# Create directory structure
echo "Checking ${DEVDIR}"
[ -d "${DEVDIR}" ] || sudo mkdir "${DEVDIR}"
sudo chmod 777 "${DEVDIR}"

pushd "${DEVDIR}" > /dev/null

# If exist SMB path to repos, change to gitserver
line_old='/home/'$USER'/media/LOCAL-RD/SK_Pocket/repos'
line_new='git@gitserver.ascom.ads:/repos/pocket'

for file in $(find . \( -type f -and -path '*/.git/*' -and -name config \))
do 
  echo "Checking remotes: "$file
  sed -i "s%$line_old%$line_new%g" $file 
done

# Install QT
[ -d Qt ] || mkdir Qt
pushd Qt > /dev/null
if [ -d qt5-android ]; then
  echo "QT5 is already installed. Running git pull..."
  pushd qt5-android > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning QT5"
  git clone -b 5.4.1_ascom_clang git@gitserver.ascom.ads:/repos/pocket/qt5_bin.git qt5-android
fi
if [ -d qt5.7-android ]; then
  echo "QT5.7 is already installed. Running git pull..."
  pushd qt5.7-android > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning QT5.7"
  git clone -b 5.7.0 git@gitserver.ascom.ads:/repos/pocket/qt5_bin.git qt5.7-android
fi
if [ -d qt5.7-ubuntu ]; then
  echo "QT5.7 Ubuntu is already installed. Running git pull..."
  pushd qt5.7-ubuntu > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning QT5 for Ubuntu"
  git clone -b 5.7.0 git@gitserver.ascom.ads:/repos/pocket/qt5_ubuntu_bin.git qt5.7-ubuntu
fi
popd > /dev/null
sudo apt-get install -y libc++1

# Install QT Mobility
[ -d QtMobility ] || mkdir QtMobility
pushd QtMobility > /dev/null
if [ -d qt-mobility-android ]; then
  echo "QTMobility already installed. Running git pull..."
  pushd qt-mobility-android > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning QtMobility"
  git clone -b build-qt-mobility-android git@gitserver.ascom.ads:/repos/pocket/qt-mobility-1.2.0.git qt-mobility-android
fi
popd > /dev/null

# Install 
if [ -d  QtExtension ] ; then
  echo "QtExtension is already installed. Running git pull..."
  pushd QtExtension > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning QTExtension"
  git clone git@gitserver.ascom.ads:/repos/pocket/g4qt-extension.git QtExtension
fi

# NDK
ANDROID_NDK=android-ndk-$ANDROID_NDK_VERSION
if [ -d $ANDROID_NDK ]; then
  echo "Android NDK $ANDROID_NDK_VERSION is already installed. Running git pull..."
  pushd $ANDROID_NDK > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning NDK $ANDROID_NDK_VERSION"
  git clone -b $ANDROID_NDK git@gitserver.ascom.ads:/repos/pocket/externals-android-ndk-r12b.git $ANDROID_NDK

  # Update softlink to NDK
  [ -L android-ndk ] && rm android-ndk
  ln -s /development/${ANDROID_NDK} android-ndk
fi

# SDK
ANDROID_SDK=android-sdk-$ANDROID_SDK_VERSION
if [ -d $ANDROID_SDK ]; then
  echo "Android SDK $ANDROID_SDK_VERSION is already installed. Running git pull..."
   pushd $ANDROID_SDK > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning Android SDK $ANDROID_SDK_VERSION"
  git clone -b ubuntu git@gitserver.ascom.ads:/repos/pocket/externals-android-sdk-$ANDROID_SDK_VERSION.git $ANDROID_SDK

  # Update sdk soft link
  [ -L android-sdk ] && rm android-sdk
  ln -s $ANDROID_SDK android-sdk
fi

ADB=$ANDROID_SDK/platform-tools/adb
if [ -u $ADB ] ; then
  echo "adb has SUID set. Good."
else
  echo "Setting SUID on adb"
  chmod 4550 $ADB
fi;

# Install EnsureIT
if [ -d EnsureIT ]; then
  echo "EnsureIT is already installed, running git pull"
  pushd EnsureIT > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning EnsureIT"
  git clone -b master git@gitserver.ascom.ads:/repos/pocket/ensureit.git EnsureIT
fi

# Install android utils
if [ -d android-utils ]; then
  echo "android-utils is already installed"
  pushd android-utils > /dev/null && git pull; popd > /dev/null
else
  echo "Cloning android-utils"
  git clone -b master git@gitserver.ascom.ads:/repos/pocket/externals-android-utils.git android-utils
fi

# Eclipse Luna
#cd /tmp/
#if [ -d ntseskrdp06.ascom.ads/eclipseLuna ]; then
#  echo "Eclipse Luna already downloaded"
#else
  #echo "Downloading Eclipse Luna" 
  #wget -r --no-parent --reject="index.html*" -c http://ntseskrdp06.ascom.ads/eclipseLuna/
  #sudo cp -Rf ntseskrdp06.ascom.ads/eclipseLuna /opt/eclipse
  #echo "Creating link"
  #sudo ln -sf "/opt/eclipse/eclipse" /usr/bin/eclipse
  #echo "Creating eclipse.desktop file"
  #sudo cp -f ntseskrdp06.ascom.ads/eclipse/eclipse.desktop /usr/share/applications/eclipse.desktop
  ## Add ADT & TFS Plugins to Eclipse
  #eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/luna/,http://dl-ssl.google.com/android/eclipse,https://dl-ssl.google.com/android/eclipse/site.xml.developer -installIU com.android.ide.eclipse.adt.feature.feature.group
  #eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/luna/,http://dl-ssl.google.com/android/eclipse,https://dl-ssl.google.com/android/eclipse/site.xml.ndk -installIU com.android.ide.eclipse.ndk.feature.feature.group
  #eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/luna/,http://dl.microsoft.com/eclipse/tfs/ -installIU com.microsoft.tfs.client.eclipse.category
#fi

# Download VMwarePLayer
#cd /tmp/
#if [ VMware-Player-6.0.4-2249910.x86_64.bundle ]; then
#  echo "VMware player already downloaded"
#else
#  wget -c http://ntseskrdp06.ascom.ads/vmware/VMware-Player-6.0.4-2249910.x86_64.bundle
#  sudo chmod +x VMware-Player-6.0.4-2249910.x86_64.bundle
#fi

#Download QtCreator setup file
cd /tmp/
#if [ -d qt-creator-opensource-linux-x86_64-3.3.2.run ]; then
#  echo "QtCreator already downloaded"
#else
  wget -c http://ntseskrdp06.ascom.ads/qtcreator/qt-creator-opensource-linux-x86_64-3.3.2.run
  sudo chmod +x qt-creator-opensource-linux-x86_64-3.3.2.run
#fi
