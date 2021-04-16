#!/bin/zsh

## This will clear user info from the serial number chosen and unmanage the device
## it will then update in oomnitza to unassingn and set the inventory status
## Harry Richman April 2021

## Get serial of computer this is to be run on
serial=$( osascript -e 'tell application "System Events" to text returned of (display dialog "Please enter the serial number of the computer" default answer "Serial Number" buttons {"OK"} default button 1)' )

echo "Serial is ${serial}" 

## set username, PW and URL - send this as variables from jamf is preffered
jamfUser="JAMF API USER"
jamfPW="JAMF API PW"
URL="https://JAMF_URL.jamfcloud.com"

oomAPI="OOMNITZA_API_KEY"

## Create the xml for empty user for upload via API
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
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
</computer>" > "/tmp/empty_location.xml"

## Create the XML to mark as unmanaged after sending MDM
echo "<computer><general><remote_management><managed>false</managed></remote_management></general></computer>" > "/tmp/unmanage.xml"

## Get Jamf ID from serial
device=$( /usr/bin/curl -H "Accept: text/xml" -sfku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computers/match/${serial} | xmllint --format - | grep "<id>" | cut -f2 -d">" | cut -f1 -d"<" )

echo "Device ID is ${device}"

## Post blank User information and unmanage device
curl -sfku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computers/id/${device} -T /tmp/empty_location.xml -X PUT
curl -X POST -sku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computercommands/command/UnmanageDevice/id/${device} --verbose
curl -sfku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computers/id/${device} -T /tmp/unmanage.xml -X PUT

## Change Oomnitza status

# set url for oomnitza e.g. if https://acme.oomnitza.com, put acme
oomURL=COMPANYNAME

#create tmp json for oomnitza
jsonLocation="/tmp/oomnitza_${serial}.json"

# Get json from Oomnitza API and load to temp
curl -s --location --request GET "https://${oomURL}.oomnitza.com/api/v3/assets?filter=serial_number%20eq%20%27${serial}%27" \
--header 'Authorization2: OOM_API' >> ${jsonLocation}

#Oomnitza search record text
oomEquipID=$( awk -F "," '/equipment_id/{print $1}' ${jsonLocation} | tr -d {\[\" | awk -F ":" '{print $2}' )
	
echo "oomnitza ID is ${oomEquipID}"

## Upload to Oomnitza to change status of device
curl --location --request PATCH "https://${oomURL}.oomnitza.com/api/v3/assets/${oomEquipID}" --header 'Authorization2: OOM_API' --data '{ "status":"Inventory - Used", "assigned_to":" ", "to_be_collected":"False" }'


## Erase temp file from upload
rm -rf /tmp/empty_location.xml
rm -rf /tmp/unmanage.xml
rm -rf /tmp/${serial}.json