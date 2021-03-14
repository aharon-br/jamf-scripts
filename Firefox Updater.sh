#!/bin/zsh


## This will download and copy to applications folder latest version of Firefox directly from the developer website
## This will will not install on computers that do not have firefox already, this is for updating
## This is best used on a recurring basis - weekly/monthly

## Harry Richman, March 2021
# Version 1


dmgfile="Firefox.dmg"
volname="Firefox"
app="Firefox"

date=$( date | awk '{print $2,$3,$4}' )


## Get latest version from Firefox Website
latestVersion=$( curl -s https://www.mozilla.org/en-US/firefox/new/ | grep 'data-latest-firefox' | sed -e 's/.* data-latest-firefox="\(.*\)".*/\1/' -e 's/\"//' | /usr/bin/awk '{print $1}' )
echo "`date` latest version of ${app} is ${latestVersion}"

## This will check if the application is installed, if it isn't it will exit clean, if it is, it will carry on
if [[ -d "/Applications/${app}.app" ]]
	then
		echo "`date` ${app} installed, proceeding"
	else
		echo "`date` ${app} not installed, exiting"
		exit 0
fi

## Read curently installed version
installedVersion=$( defaults read /Applications/${app}.app/Contents/Info CFBundleShortVersionString )
echo "`date` installed version of ${app} is ${installedVersion}"

## URL to download DMG from
url="https://download-installer.cdn.mozilla.net/pub/firefox/releases/${latestVersion}/mac/en-US/Firefox%20${latestVersion}.dmg"

## Check if installed and latest are not matching, if they don't install new version, if they do, exit clean
if [[ $installedVersion != $latestVersion ]]
	then

		echo "`date` Downloading $app $latestVersion"
		## Download silently and allow redirects
		curl -L -s -o  /tmp/${dmgfile} ${url}
		
		echo "`date` Mounting disk"
		## Silently mount DMG
		hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
		
		echo "`date` Installing $app to applications"
		## Copy Application into /Applications
		ditto -rsrc "/Volumes/${volname}/$app.app" "/Applications/$app.app"
		
		sleep 10
		
		echo "`date` Unmounting disk"
		## Unmount volume
		hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet
		
		sleep 10
		
		echo "`date` Deleting disk"
		## Delete disk image and clean up
		rm /tmp/"${dmgfile}"
		
		echo "`date` $app installed"
		
		## This will check if the application is running and optionally notify the user (uncomment that line)
		running=$( ps -acx | grep -o "firefox" )
		if [[ $running != $app ]]
			then
				echo "`date` ${app} not running"
			else
				echo "`date` ${app} running"
				## "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType hud -title "TITLE" -heading "HEADING" -description "MESSAGE" -icon /path/to/icon.png -button1 Okay -defaultButton 0 -timeout 20
		fi
		
		sleep 5

		# Set path to newly installed application
		applicationPath="/Applications/$app.app"
		# Check signature of installed application to ensure trusted
		appSignature=$( pkgutil --check-signature "$applicationPath" | grep "Status:" | sed 's/^[ \t]*//;s/[ \t]*$//' )
		# if unstrusted exit with error
		# else, continue 
		if [[ $appSignature != *"signed by a certificate trusted"* ]]; 
		then 
			echo "${date} $app is not trusted, install should be tried again" 
			exit 1 
		else 
			echo "${date} $app trusted, install succesful" 
		fi 
					
	else
		echo "${app} is up to date, exiting"
		exit 0
		
fi


exit 0