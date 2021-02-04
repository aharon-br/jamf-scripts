#!/bin/zsh

## Zoom Updater
## Harry Richman
## Version 3, revision 2
## Last updated February 2021
## Script will download latest Zoom Installer and update
### Adapted from Office install script

## Zoom mass deployment guide https://support.zoom.us/hc/en-us/articles/115001799006-Mass-Deployment-with-Preconfigured-Settings-for-Mac
downloadURL="https://zoom.us/client/latest/ZoomInstallerIT.pkg"
# Change App Name here - could instead use $4 in Jamf and variable in Jamf
app="zoom.us"
date=$( date | awk '{print $2,$3,$4}' )

## Get latest verson from Zoom website
latestVersion=$( curl -sL 'https://support.zoom.us/hc/en-us/articles/201361963' | egrep -o "version [[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}" | tr -d "version " | sort --version-sort | tail -n1 )

## Get Currently installed version
installedVersion=$( defaults read "/Applications/${app}.app/Contents/Info.plist" CFBundleShortVersionString | awk '{print $1}' )

## This will check if the application is installed, if it isn't it will exit clean, if it is, it will carry on
if [[ -d "/Applications/${app}.app" ]]
	then
		echo "$app installed, proceeding"
	else
		echo "$app not installed, exiting"
		exit 0
fi

## This will check if the application is running and exit if it is
running=$( ps -acx | grep -o "$app" )
if [[ $running != $app ]]
	then
		echo "${date} $app not running"
	else
		echo "${date} $app running, exiting with error"
		exit 1
fi

echo "Latest version is $latestVersion"
echo "Installed version is $installedVersion"

## If the latest version is  the same as the installed, print up to date. If it is not, proceed with install
if [[ "$latestVersion" == "$installedVersion" ]]
	then
		echo "${date} $app up to date"
	else
		echo "${date} Downloading Latest ${app}"
		curl -sL -k -o /tmp/$app.pkg "$downloadURL"
		echo "${date} installing ${app}"
		installer -allowUntrusted -pkg /tmp/$app.pkg -target /
		sleep 15
		echo "${date} ${app} installed"
		echo "Deleting ${app} Package"
		rm -rf /tmp/$app.pkg
		echo "${date} ${app} Updated to `defaults read /Applications/${app}.app/Contents/Info CFBundleShortVersionString`"
fi

# Set path to newly installed application
applicationPath="/Applications/$app.app"
# Check signature of installed application to ensure trusted
appSignature=$( pkgutil --check-signature "$applicationPath" | grep "Status:" | sed 's/^[ \t]*//;s/[ \t]*$//' )
# if unstrusted delete app, and exit with error
# else, continue 
if [[ $appSignature != *"signed by a certificate trusted"* ]]; 
then 
	echo "${date} $app is not trusted, removing $app" 
	rm -rf "$applicationPath" 
	exit 1 
else 
	echo "`${date} $app trusted, install succesful" 
fi 

exit 0