#!/bin/zsh


## This will download and copy to applications folder latest version of SubEthaEdit directly from the developer website
## Created by Harry Richman August 2020
## Last updated by Harry Richman August 2020 
## version 1, revision 3

zip="subethaedit.zip"
app="SubEthaEdit"

## Get current version from website

## First check for unreleased version
## If unreleased version give latest production version, otherwise give latest version

## Set unreleased variable to search for term unreleased
unreleased=$( curl -s https://raw.githubusercontent.com/subethaedit/SubEthaEdit/develop/ChangeLog.md | grep "unreleased" )

## If unreleased is not empty then set beta variable and remove that line from output

if [[ "$unreleased" != "" ]]; then
	
	beta=$( curl -s https://raw.githubusercontent.com/subethaedit/SubEthaEdit/develop/ChangeLog.md | grep -o "\[unreleased]\ SubEthaEdit [0-9]\.[0-9]" | sed 's/unreleased//g' | tr -d "\[\""\]\" | sed -e 's/^[ \t]*//' )

	currentVersion=$( curl -s https://raw.githubusercontent.com/subethaedit/SubEthaEdit/develop/ChangeLog.md | grep -o -E "SubEthaEdit [0-9]\.[0-9]|SubEthaEdit [0-9]\.[0-9]\.[0-9]" | sed "s/$beta//g" | sed '1d' | head -1 )
	
	else
		
## If unreleased is empty then get latest version from output

		currentVersion=$( curl -s https://raw.githubusercontent.com/subethaedit/SubEthaEdit/develop/ChangeLog.md | grep -o -E "SubEthaEdit [0-9]\.[0-9]|SubEthaEdit [0-9]\.[0-9]\.[0-9]" | head -1 )
		
		fi

## Check is SubEthaEdit is installed or not and to show installed version if it is already
if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
	echo "`date` $app isn't installed, current version of $app is $currentVersion"
else
	## Get installed version from plist
	installedVersion=$( defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString )
	echo "`date` Installed version of $app is $installedVersion, current version of $app is $currentVersion"
fi

## URL to download ZIP from
url='https://subethaedit.net/SubEthaEdit.zip'

echo "`date` Downloading $app $currentVersion"
## Download silently and allow redirects
curl -L -s -o  /tmp/${zip} ${url}

echo "`date` Changing Directory"
## Change Directory
cd /private/tmp

echo "`date` Unzipping $zip"
## unzip subethaedit.zip into /private/tmp/SubEthaEdit.app
sudo unzip -q $zip

echo "`date` Removing $app $installedVersion"
## Delete existing SubEthaEdit.app in Applications folder
sudo rm -rf /Applications/$app.app

echo "`date` Moving $app $currentVersion to Applications"
## Move current SubEthaEdit app from /private/tmp to /Applications
mv $app.app /Applications/$app.app

echo "`date` Deleting $zip"
## Clean up /private/tmp and remove zip file
sudo rm -f /private/tmp/atom.zip

exit 0