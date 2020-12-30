#!/bin/zsh

### This is for updating desired office application only. It will not install new copies.
### This is designed to be runned on a schedule in jamf, for all computers, with retry on failure

## Check notes through, some parts can be changed if running from jamf, otherwise ensure changing details per application

## Harry Aharon Richman
## Created November 2020, version 1, revision 3


# Download URLS from macadmins.software
## Office 2019 URLS (as of December 2020)
## Full Office https://go.microsoft.com/fwlink/?linkid=525133
###  Word https://go.microsoft.com/fwlink/?linkid=525134
#### Excel https://go.microsoft.com/fwlink/?linkid=525135
##### PowerPoint https://go.microsoft.com/fwlink/?linkid=525136 


# Set App Name as $4 in Jamf , use e.g. Excel, PowerPoint, Word
## Set Download URL as $5 in Jamf, use one of the above URLS

date=$( date | awk '{print $2,$3,$4}' )

## This will check if the application is installed, if it isn't it will exit clean, if it is, it will carry on
if [[ -d "/Applications/Microsoft $4.app" ]]
	then
		echo "$4 installed, proceeding"
	else
		echo "$4 not installed, exiting"
		exit 0
fi

## This will check if the application is running, if it is it will exit unclean so jamf will attempt to re-run on failure. If it is closed, it will carry on
running=$( ps -acx | grep -o "$4" )
if [[ $running != $4 ]]
	then
		echo "$4 not running, proceeding"
	else
		echo "$4 running, exiting with error"
		exit 1
fi			

## read latest avaialble version, and currently installed version
latestVersion=$( curl -s -k -L https://macadmins.software/latest.xml | grep -o -a7 "com.microsoft.excel.standalone.365" | tail -1 | tr -d 'a-z' | tr -d '<>/' | awk '{print $1}' )
installedVersion=$( defaults read /Applications/Microsoft\ Excel.app/Contents/Info CFBundleShortVersionString )

echo "Latest version is $latestVersion"
echo "Installed version is $installedVersion"

## If the latest version is  the same as the installed, print up to date. If it is not, proceed with install
if [[ "$latestVersion" == "$installedVersion" ]]
	then
		echo "up to date"
	else
		echo "not up to date, continuing with update"
		echo "${date} Downloading Microsoft $4 version ${latestVersion}"
		curl -L -s -k -o /tmp/$4.pkg "$5"
		echo "installing Microsoft $4 ${latestVersion}"
		installer -allowUntrusted -pkg /tmp/$4.pkg -target /
		sleep 15
		echo "Micosoft $4 ${installedVersion} installed"
		echo "Deleting Microsoft $4 Package"
		rm -rf /tmp/$4.pkg
		echo "${date} Microsoft $4 Updated to `defaults read /Applications/Microsoft\ $4.app/Contents/Info CFBundleShortVersionString`"

fi

exit 0