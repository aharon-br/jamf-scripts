#!/bin/zsh


## This will download and copy to applications folder latest version of Visual Studio Code directly from the developer website
## Created by Harry Richman September 2020
## Last updated by Harry Richman September 2020 
## version 1, revision 2

zip="VSCode-darwin-stable.zip"
app="Visual Studio Code"

## Get current version from website
currentVersion=$( curl -s 'https://code.visualstudio.com/Download' | grep -o "softwareVersion\">[0-9]\.[0-9][0-9]" | tr -d "softwareVersion\">" | head -1 )

## Check is Atom is installed or not and to show installed version if it is already
if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
	echo "$(date) $app isn't installed, current version of $app is $currentVersion"
else
	## Get installed version from plist
	installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
	echo "$(date) Installed version of $app is $installedVersion, current version of $app is $currentVersion"
fi

## URL to download ZIP from
url='https://az764295.vo.msecnd.net/stable/58bb7b2331731bf72587010e943852e13e6fd3cf/VSCode-darwin-stable.zip'

echo "$(date) Downloading $app $currentVersion"
## Download silently and allow redirects
curl -L -s -o  /tmp/${zip} ${url}

echo "$(date) Changing Directory"
## Change Directory
cd /private/tmp

echo "$(date) Unzipping $zip"
## unzip VSCode-darwin-stable.zip into /private/tmp/Visual Studio Code.app
sudo unzip -q $zip

echo "$(date) Removing $app $installedVersion"
## Delete existing Visual Studio Code.app in Applications folder
sudo rm -rf /Applications/"$app".app

echo "$(date) Moving $app $currentVersion to Applications"
## Move Visual Studio Code app from /private/tmp to /Applications
mv "$app".app /Applications/"$app".app

echo "$(date) Deleting $zip"
## Clean up /private/tmp and remove zip file
sudo rm -f /private/tmp/$zip

exit 0