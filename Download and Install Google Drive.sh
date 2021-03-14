#!/bin/zsh


## This will download and copy to applications folder latest version of Google Drive directly from the developer website
## Created by Harry Richman March 2021
## version 1

dmgfile="GoogleDrive.dmg"
volname="Install Google Drive"
app="Google Drive"

## URL to download DMG from
url="https://dl.google.com/drive-file-stream/GoogleDriveFileStream.dmg"

echo "`date` Downloading $app $currentVersion"
## Download silently and allow redirects
curl -L -s -o  /tmp/${dmgfile} ${url}

echo "`date` Mounting disk"
## Silently mount DMG
hdiutil attach /tmp/${dmgfile} -nobrowse -quiet

# get PKG name
installerPKG=$( ls "/Volumes/${volname}" | grep ".pkg" )
echo "package is ${installerPKG}"

echo "`date` Installing $app to applications"
## Install using package on the disk
installer -pkg "/Volumes/${volname}/GoogleDrive.pkg" -target /

sleep 10

echo "`date` Unmounting disk"
## Unmount volume
hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet

sleep 10

echo "`date` Deleting disk"
## Delete disk image and clean up
rm /tmp/"${dmgfile}"

echo "`date` $app installed"

exit 0