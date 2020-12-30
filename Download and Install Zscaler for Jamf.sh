#!/bin/zsh

## This will download the version of Zscaler specified in the URL and version name fields
# this will check for application signature, if invalid will remove the application and exit with error 
## This uses variables in Jamf in order to easily deploy multiple version, or different enforcements/policys

## last updated by Harry Richman, december 2020
## version 1, revision 2 for Jamf

## Set variables
zip="zscaler.zip"
app="Zscaler"


## Check is Zscaler is installed or not and to show installed version if it is already
	if [ ! -f "/Applications/$app.app/Contents/Info.plist" ] ; then
			echo "`date` $app isn't installed"
	else
	
	## Get installed version from plist
		installedVersion=$( defaults read "/Applications/$app/$app.app/Contents/Info.plist" CFBundleShortVersionString )
		
		echo "`date` Installed version of $app is $installedVersion"
	fi

## set $4 in jamf to be the version number downloading
echo "`date` Downloading $app $4"
## Download silently and allow redirects
## Set $5 in Jamf to be the download URL for the version desired
curl -L -s -o  /tmp/$zip $5

echo "`date` Changing Directory"
## Change Directory
cd /private/tmp

echo "`date` Unzipping $zip"
## unzip zip into /private/tmp/
sudo unzip -q $zip

echo "`date` Remove zip file"
## delete the zip file
rm -rf /private/tmp/$zip

## Set installer name by searching 
installer=$( ls | grep "Zscaler" )

echo "`date` installing Zscaler"
## Install using correct settings, set these all to variables in jamf
## $6 for cloudname
## $7 for policy token
## $8 for domain
sudo sh /tmp/$installer/Contents/MacOS/installbuilder.sh --cloudName $6  --policyToken $7  --strictEnforcement 1 --unattendedmodeui none --userDomain $8

sleep 10

echo "`date` moving Uninstaller" 
## Move uninstaller to /var to hide from users
mkdir /var/Zscaler
mv /Applications/Zscaler/UninstallApplication.app /var/Zscaler/UninstallApplication.app

echo "`date` removing installer"
## Remove installer from /tmp
rm -rf $installer

echo "`date` $app version $4 installed"

# Set path to newly installed application
applicationPath="/Applications/$app/$app.app"

# Check signature of installed application to ensure trusted
appSignature=$( pkgutil --check-signature "$applicationPath" | grep "Status:" | sed 's/^[ \t]*//;s/[ \t]*$//' )
## echo "Application Signature $appSignature"

# if unstrusted delete app, and exit with error
# else, continue
			if [[ $appSignature != *"signed by a certificate trusted"* ]]; then
					echo "`date` $app is not trusted, removing $app"
					rm -rf "$applicationPath"
					## The below is commented out, but uncomment if wanting to notify the user of the install failure
					## "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType hud -title "Braze IT" -heading Installation Failure -description "APP failed security checks and could not be installed.                            Please request support at it.braze.com" -icon /private/var/braze.png -button1 Okay -defaultButton 0 -timeout 20
					exit 1
				else
					echo "`date` $app version $4 trusted, install succesful"
			fi
			
exit 0
