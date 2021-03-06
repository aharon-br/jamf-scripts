#!/bin/zsh


## This will download and copy to applications folder latest version of Slack directly from the  website
## If an App Store version or VPP version is detected script will not install
## Created by Harry Richman September 2020
## Last updated by Harry Richman January 2021 
## version 2, revision 1

dmgfile="slack.dmg"
volname="Slack.app"
app="Slack"

## Get current logged in user
currentUser=$( ls -l /dev/console | cut -d " " -f4 )

## Get current version from website
currentVersion=$( curl -s -L 'https://slack.com/downloads/mac' | egrep -o "Version [[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}" | tr -d "Version " )

## Check is Slack is installed 
	if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
		echo "`date` $app isn't installed, current version of $app is $currentVersion, proceeding with install"
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
		chown -R $currentUser\:admin "/Applications/Slack.app"
		
		echo "`date` $app $currentVersion installed"

	else
		## Get installed version from plist
		installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
		
		## First check if from App Store
		AppStore=$( mdls /Applications/Slack.app -name kMDItemAppStoreIsAppleSigned | cut -d = -f 2 | xargs )
		if [[ "$AppStore" == "(null)" ]]; then
			## If not from App Store show installed version and install
			echo "`date` Installed version of $app is $installedVersion, current version of $app is $currentVersion"
			if [[ "$installedVersion" != "$currentVersion" ]]; then	
				echo "`date` $app is not up to date, updating to $currentVersion"	
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
				chown -R $currentUser\:admin "/Applications/Slack.app"
				
				echo "`date` $app $currentVersion installed"
			
			else 
				echo "`date` $app is $currentVersion, up to date"
			fi	
				
		else 
			## Check if VPP or not	
			VPPtest=$( mdls /Applications/Slack.app -name kMDItemAppStoreReceiptIsVPPLicensed | cut -d = -f 2 | xargs )
			
			if [[ "$VPPtest" != "0" ]]; then
				## If is VPP show that it is and installed version
				echo "`date` Installed version of $app is $installedVersion and is VPP - not updating"
				
			else
				## Show installed version and that it is App Store but not VPP
				echo "`date` Installed version of $app is $installedVersion and is from App Store but not VPP - not updating"
			fi
				
		fi
	fi

exit 0