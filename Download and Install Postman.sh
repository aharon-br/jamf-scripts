#!/bin/zsh


## This will download and copy to applications folder latest version of Postman directly from the developer website
## Created by Harry Richman February 2021
## version 1

zip="postman.zip"
app="Postman"



## Check is Postman is installed or not and to show installed version if it is already
if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
	echo "`date` $app isn't installed"
else
	## Get installed version from plist
	installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
	echo "`date` Installed version of $app is $installedVersion"
fi

## URL to download ZIP from
url="https://dl.pstmn.io/download/latest/osx"

echo "`date` Downloading $app $currentVersion"
## Download silently and allow redirects
curl -skLo  /tmp/${zip} ${url}

echo "`date` Changing Directory"
## Change Directory
cd /private/tmp

echo "`date` Unzipping $zip"
## unzip postman.zip into /private/tmp/Postman.app
sudo unzip -q $zip

echo "`date` Removing $app $installedVersion"
## Delete existing Postman.app in Applications folder
sudo rm -rf /Applications/$app.app

echo "`date` Moving $app $currentVersion to Applications"
## Move current Postman app from /private/tmp to /Applications
mv $app.app /Applications/$app.app

echo "`date` Deleting $zip"
## Clean up /private/tmp and remove zip file
sudo rm -f /private/tmp/$zip

exit 0