#!/bin/zsh


## This will download and copy to applications folder latest version of Atom directly from the developer website
## Created by Harry Richman August 2020
## Last updated by Harry Richman August 2020 
## version 1

zip="atom.zip"
app="Atom"

## Get current version from website
currentVersion=$( curl -s 'https://atom.io/' | grep -o ">[0-9]\.[0-9][0-9]\.[0-9]<" | tr -d "< " | tr -d "> " )

## Check is Atom is installed or not and to show installed version if it is already
if [ ! -f "/Applications/Atom.app/Contents/Info.plist" ] ; then
	echo "`date` $app isn't installed, current version of $app is $currentVersion"
else
	## Get installed version from plist
	installedVersion=$( defaults read "/Applications/Atom.app/Contents/Info.plist" CFBundleShortVersionString )
	echo "`date` Installed version of $app is $installedVersion, current version of $app is $currentVersion"
fi

## URL to download ZIP from
url='https://atom.io/download/mac'

echo "`date` Downloading $app $currentVersion"
## Download silently and allow redirects
curl -L -s -o  /tmp/${zip} ${url}

echo "`date` Changing Directory"
## Change Directory
cd /private/tmp

echo "`date` Unzipping $zip"
## unzip atom.zip into /private/tmp/Atom.app
sudo unzip -q atom.zip

echo "`date` Removing $app $installedVersion"
## Delete existing Atom.app in Applications folder
sudo rm -rf /Applications/Atom.app

echo "`date` Moving $app $currentVersion to Applications"
## Move current Atom app from /private/tmp to /Applications
mv $app.app /Applications/$app.app

echo "`date` Deleting $zip"
## Clean up /private/tmp and remove zip file
sudo rm -f /private/tmp/atom.zip

exit 0