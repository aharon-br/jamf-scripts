#!/bin/zsh


## This will download and copy to applications folder latest version of iTerm directly from the developer website
## Created by Harry Richman February 2021
## version 1

zip="iterm.zip"
app="iTerm"

## Get current version from website
		currentVersion=$( curl -s https://iterm2.com/downloads.html | egrep -o "iTerm2 [[:digit:]]{1,2}.[[:digit:]]{1,2}.[[:digit:]]{1,2}" | head -1 | sed -e 's/iTerm2//g' | sed 's/ //g' )



## Check is iTerm is installed or not and to show installed version if it is already
if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
	echo "`date` $app isn't installed, current version of $app is $currentVersion"
else
	## Get installed version from plist
	installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
	echo "`date` Installed version of $app is $installedVersion, current version of $app is $currentVersion"
fi

## URL to download ZIP from
url=$( curl -s https://iterm2.com/downloads.html | egrep -o "https://iterm2.com/downloads/stable/iTerm2-[[:digit:]]{1,2}.[[:digit:]]{1,2}.[[:digit:]]{1,2}.zip" | head -1 )

echo "`date` Downloading $app $currentVersion"
## Download silently and allow redirects
curl -L -s -o  /tmp/${zip} ${url}

echo "`date` Changing Directory"
## Change Directory
cd /private/tmp

echo "`date` Unzipping $zip"
## unzip iterm.zip into /private/tmp/iterm.app
sudo unzip -q $zip

echo "`date` Removing $app $installedVersion"
## Delete existing SubEthaEdit.app in Applications folder
sudo rm -rf /Applications/$app.app

echo "`date` Moving $app $currentVersion to Applications"
## Move current iterms app from /private/tmp to /Applications
mv $app.app /Applications/$app.app

echo "`date` Deleting $zip"
## Clean up /private/tmp and remove zip file
sudo rm -f /private/tmp/$zip

exit 0