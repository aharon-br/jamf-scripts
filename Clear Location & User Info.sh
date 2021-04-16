#!/bin/zsh

## This will clear user info from the serial number chosen and unmanage the device
## Harry Richman April 2021

## Get serial of computer this is to be run on
serial=$( osascript -e 'tell application "System Events" to text returned of (display dialog "Please enter the serial number of the computer" default answer "Serial Number" buttons {"OK"} default button 1)' )

## set username, PW and URL - send this as variables from jamf is preffered
jamfUser="JAMF API USER"
jamfPW="JAMF API PASSWORD"
URL="https://JSS_URL.jamfcloud.com"

## Create the xml for upload via API
tee /tmp/empty_location.xml << EOF
<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<computer>
    <location>
        <username/>
        <real_name/>
        <email_address/>
        <position/>
        <phone/>
        <department/>
        <building/>
        <room/>
    </location>
</computer>
EOF


## Get Jamf ID from serial
device=$( /usr/bin/curl -H "Accept: text/xml" -sfku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computers/match/${serial} | xmllint --format - | grep "<id>" | cut -f2 -d">" | cut -f1 -d"<" )


## Post blank User information and unmanage device
curl -sfku "${jamfUser}:${jamfPW}" "${URL}/JSSResource/computers/id/$device" -T /tmp/empty_location.xml -X PUT
curl -X POST -sku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computercommands/command/UnmanageDevice/id/${device}

## Erase temp file from upload

rm -rf /tmp/empty_location.xml