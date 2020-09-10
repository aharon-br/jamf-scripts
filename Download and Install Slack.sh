#!/bin/zsh


## This will download and copy to applications folder latest version of Slack directly from the  website
## Created by Harry Richman September 2020
## Last updated by Harry Richman September 2020 
## version 1

dmgfile="slack.dmg"
volname="Slack.app"
app="Slack"

## Get current logged in user
currentUser=$( ls -l /dev/console | cut -d " " -f4 )

## Get current version from website
currentVersion=$( curl -s -L 'https://slack.com/downloads/mac' | grep -o "Version [0-9]\.[0-9]\.[0-9]" | tr -d "Version " )

## Check is Slack is installed or not and to show installed version if it is already
	if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
			echo "`date` $app isn't installed, current version of $app is $currentVersion"
	else
		## Get installed version from plist
			installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
		## Check if VPP or not	
			VPPtest=$( mdls /Applications/Slack.app -name kMDItemAppStoreReceiptIsVPPLicensed | cut -d = -f 2 | xargs )
			
			if [[ "VPPtest" == "1" ]]; then
				
				echo "`date` Installed version of $app is $installedVersion and is VPP, current version of $app is $currentVersion"
				
				else
		
				echo "`date` Installed version of $app is $installedVersion, current version of $app is $currentVersion"
				
			fi
	fi

## URL to download DMG from
url="https://downloads.slack-edge.com/releases/macos/$currentVersion/prod/x64/Slack-$currentVersion-macOS.dmg"

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

echo "`date` Setting Slack permissions"
## Slack sometimes loads with strange permissions
chown -R $currentUser:admin "/Applications/Slack.app"

echo "`date` $app $currentVersion installed"

exit 0