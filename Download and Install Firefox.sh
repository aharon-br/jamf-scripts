#!/bin/zsh


## This will download and copy to applications folder latest version of Firefox directly from the developer website

## Harry Richman, March 2021
# Version 1


dmgfile="Firefox.dmg"
volname="Firefox"
app="Firefox"

date=$( date | awk '{print $2,$3,$4}' )


## Get latest version from Firefox Website
latestVersion=$( curl -s https://www.mozilla.org/en-US/firefox/new/ | grep 'data-latest-firefox' | sed -e 's/.* data-latest-firefox="\(.*\)".*/\1/' -e 's/\"//' | /usr/bin/awk '{print $1}' )
echo "`date` latest version of ${app} is ${latestVersion}"

## URL to download DMG from
url="https://download-installer.cdn.mozilla.net/pub/firefox/releases/${latestVersion}/mac/en-US/Firefox%20${latestVersion}.dmg"

## This will check if the application is installed, if it isn't it will exit clean, if it is, it will carry on
if [[ -d "/Applications/${app}.app" ]]
	then
		echo "`date` ${app} installed"
		## Read curently installed version
installedVersion=$( defaults read /Applications/${app}.app/Contents/Info CFBundleShortVersionString )
		echo "`date` installed version of ${app} is ${installedVersion}"
	else
		echo "`date` ${app} not installed"
fi

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

exit 0