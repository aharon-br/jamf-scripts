#!/bin/zsh


## This will download and copy to applications folder latest version of Sublime Text directly from the developer website
## Created by Harry Richman August 2020
## Last updated by Harry Richman August 2020 
## version 1

dmgfile="sublimetext.dmg"
volname="Sublime Text"
app="Sublime Text"

## Get current version from website
currentVersion=$( curl -s 'https://www.sublimetext.com/' | grep -o "Build [0-9][0-9][0-9][0-9]" | head -1 )

## Edit current version variable to use in URL for download with version number (Sublime User build number in their download URL)
currentVersionURL=$( curl -s 'https://www.sublimetext.com/' | grep -o "Build [0-9][0-9][0-9][0-9]" | head -1 | tr -d "Build " )


## Check is Sublime Text is installed or not and to show installed version if it is already
	if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
			echo "`date` $app isn't installed, current version of $app is $currentVersion"
	else
	
	## Get installed version from plist
		installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
		
		echo "`date` Installed version of $app is $installedVersion, current version of $app is $currentVersion"
	fi

## URL to download DMG from
url="https://download.sublimetext.com/Sublime%20Text%20Build%20$currentVersionURL.dmg"

echo "`date` Downloading $app $currentVersion"
## Download silently and allow redirects
curl -L -s -o  /tmp/${dmgfile} ${url}

echo "`date` Mounting disk"
## Silently mount DMG
hdiutil attach /tmp/${dmgfile} -nobrowse -quiet

echo "`date` Copying $app $currentVersion to applications"
## Copy app bundle from disk image to Applications folder
ditto -rsrc "/Volumes/${volname}/$app.app" "/Applications/$app.app"

sleep 10

echo "`date` Unmounting disk"
## Unmount volume
hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet

sleep 10

echo "`date` Deleting disk"
## Delete disk image and clean up
rm /tmp/"${dmgfile}"

echo "`date` $app $currentVersion installed"

exit 0