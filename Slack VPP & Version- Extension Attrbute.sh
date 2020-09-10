#! /bin/zsh

## Created by Harry Richman, May 2020
## Last updated by Harry Richman, September 2020
## Version 2

## This will check is Slack is installed - if it is installed whether it is VPP and if not if it is up-to-date

## This should be used as an extension attribute in Jamf

if [ ! -f "/Applications/Slack.app/Contents/Info.plist" ] ; then
	echo "<result>Slack isn't installed</result>"
exit 0
fi

installedVersion=$( defaults read "/Applications/Slack.app/Contents/Info.plist" CFBundleShortVersionString )
currentVersion=$( curl -s -L 'https://slack.com/downloads/mac' | grep -o "Version [0-9]\.[0-9]\.[0-9]" | tr -d "Version " )
VPPtest=$( mdls /Applications/Slack.app -name kMDItemAppStoreReceiptIsVPPLicensed | cut -d = -f 2 | xargs )


if [[ "VPPtest" == "1" ]]; then
	
		echo "<result>VPP Licensed & $installedVersion</result>"
		
	else

		if [[ "$installedVersion" == "$currentVersion" ]]; then

			echo "<result>not VPP - latest - $currentVersion</result>"

		else

			echo "<result>not VPP - old - $installedVersion installed, current $currentVersion</result>"

		fi
		
fi

exit 0