#!/bin/zsh

# This will collect logs for IT into a ZIP file and upload to Jamf for IT to collect
# Created by Nidia Vargas, August 2020
# Last updated by Harry Richman, September 2020

## Varibales $4, $5, $6 is set with script variables in Jamf - ensure they are set
## $4 should be api username, $5 should be api password, and $6 should be jamf base URL
 
## Set variables  
date=$( date | awk '{print $1, $2, $3, $4, $6}' | sed -e 's/[[:space:]]/- /g' | tr -d " " )  
serial=$( /usr/sbin/ioreg -l | /usr/bin/awk '/IOPlatformSerialNumber/ { print $4;}' | /usr/bin/tr -d '"' )


## set variable jamfID - computers ID number in JSS
jamfID=$( /usr/bin/curl -H "Accept: text/xml" -sfku ${4}:${5} ${6}/JSSResource/computers/match/${serial} | xmllint --format - | grep "<id>" | cut -f2 -d">" | cut -f1 -d"<" )

  
## Create folder for system logs in tmp    
mkdir /private/var/tmp/logs-for-IT
## Copy system log files to folder
cp -a /Library/Logs/DiagnosticReports /private/var/tmp/logs-for-IT
cp /private/var/log/system.log  /private/var/tmp/logs-for-IT
cp /private/var/log/jamf.log  /private/var/tmp/logs-for-IT
cp /private/var/log/install.log  /private/var/tmp/logs-for-IT

## Create folder for user logs
mkdir /private/var/tmp/logs-for-IT/User-DiagnosticReport
## Copy user logs to folder
cp -a ~/Library/Logs/DiagnosticReports /private/var/tmp/logs-for-IT/User-DiagnosticReport

## Zip folder with logs in 'Logs-date' file
zip -r -X /private/var/tmp/Logs-$date.zip /private/var/tmp/logs-for-IT >> /dev/null


## Upload log file to Jamf attatchments
curl -sfku ${4}:${5} ${6}/JSSResource/fileuploads/computers/id/${jamfID} -F name=@/private/var/tmp/Logs-$date.zip -X POST


## Clean up and remove files
rm -R /private/var/tmp/logs-for-IT
rm /private/var/tmp/Logs-$date.zip

exit 0