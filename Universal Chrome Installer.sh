#!/bin/zsh

## This will download the latest, universal, version of Google Chrome. This will work on Apple Silicon and Intel 
# this will check for application signature, if invalid will remove the application and exit with error and notify user

## last updated by Harry Richman, december 2020

## Set variables
dmgfile="googlechrome.dmg"
volname="Google Chrome"
app="Google Chrome"

# this is the URL for universal binary
url='https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg'

## find current version number
currentVersion=$( curl -s https://omahaproxy.appspot.com/mac )

## Check is Chrome is installed or not and to show installed version if it is already
	if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
			echo "`date` $app isn't installed, current version of $app is $currentVersion"
	else
	
	## Get installed version from plist
		installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
		
		echo "`date` Installed version of $app is $installedVersion, current version of $app is $currentVersion"
	fi


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

# Set path to newly installed application
applicationPath="/Applications/$app.app"

# Check signature of installed application to ensure trusted
appSignature=$( pkgutil --check-signature "$applicationPath" | grep "Status:" | sed 's/^[ \t]*//;s/[ \t]*$//' )
## echo "Application Signature $appSignature"

# if unstrusted delete app, notify user and exit with error
# else, continue
			if [[ $appSignature != *"signed by a certificate trusted"* ]]; then
					echo "`date` $app is not trusted, removing $app"
					rm -rf "$applicationPath"
					"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType hud -title "Braze IT" -heading Installation Failure -description "Google Chrome failed security checks and could not be installed.                            Please request support at it.braze.com" -icon /private/var/braze.png -button1 Okay -defaultButton 0 -timeout 20
					exit 1
				else
					echo "`date` $app trusted, install succesful"
			fi
			
exit 0
