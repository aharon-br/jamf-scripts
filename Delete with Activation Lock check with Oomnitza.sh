#!/bin/zsh

## This will check if activation lock is one or not on the specified serial number returned by the user
## If its disabled it will delete the computer from Jamf
## if its enabled it will prompt to upload the bypass code to Oomnitza

## Get serial of computer this is running on
serial=$( osascript -e 'tell application "System Events" to text returned of (display dialog "Please enter the serial number of the computer to delete. Please be sure this serial is correct, this computer will require re-enrollment" default answer "Serial Number" buttons {"OK"} default button 1)' )


## set username, PW and URL - send this as variables from jamf is preffered
jamfUser="JAMF API USER"
jamfPW="JAMF API PW"
URL="https://JAMF_URL.jamfcloud.com"

oomAPI="OOMNITZA_API"
# if oomnitza url is acme.oomnitza.com, put acme below
oomURL="OOMITZA_URL"

## Get Jamf ID from serial
		deviceID=$( /usr/bin/curl -H "Accept: text/xml" -sfku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computers/match/${serial} | xmllint --format - | grep "<id>" | cut -f2 -d">" | cut -f1 -d"<" )

## get activation lock status from jamf api
activationLockStatus=$( curl -sku ${jamfUser}:${jamfPW} -H "accept: application/xml" "${URL}/JSSResource/computers/serialnumber/${serial}/subset/security" | xpath "string(//activation_lock)" 2>/dev/null )

## if actication lock is one
if [[ ${activationLockStatus} == true ]]
	then
		
		echo "activation lock is on"
		
		## notify with applescript
		activationLockCode=$( osascript -e 'tell application "System Events" to text returned of (display dialog "Activation Lock is on, please retrieve the code from Jamf in order to proceed" default answer "Enter bypass code" buttons {"OK"} default button 1)' )
		
		## bypass code should match - re run if not matching
		until [[ $activationLockCode =~ ^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$ ]]
			do
				activationLockCode=$( osascript -e 'tell application "System Events" to text returned of (display dialog "Code incorrect, please retrieve the code from Jamf in order to proceed" default answer "Enter bypass code" buttons {"OK"} default button 1)' )
		done
		
		echo "${activationLockCode}"
		
		jsonLocation="/tmp/oomnitza_${serial}.json"

		# Get json from Oomnitza API and load to temp
		curl -s --location --request GET "https://${oomURL}.oomnitza.com/api/v3/assets?filter=serial_number%20eq%20%27${serial}%27" \
		--header 'Authorization2: "'${oomAPI}'"' >> ${jsonLocation}
		
		#Oomnitza search record text
		oomEquipID=$( awk -F "," '/equipment_id/{print $1}' ${jsonLocation} | tr -d {\[\" | awk -F ":" '{print $2}' )
			
		echo "${oomEquipID}"
		
		#Upload activation lock bypass code to Oomnitza notes filed
		
		curl --location --request PATCH "https://${oomURL}.oomnitza.com/api/v3/assets/${oomEquipID}" --header 'Authorization2: "'${oomAPI}'"' --data '{ "notes":"'${activationLockCode}'" }'
		
		rm -f ${jsonLocation}
		
		## remind to check code
		osascript -e 'tell application "System Events" to display dialog "Thank you, this code is uploaded to the notes field on Oomnitza. Please verify that it is present." buttons {"I have confirmed"} default button 1'
		
		
		## Delete record from Jamf
		curl -sku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computers/id/${deviceID} -X DELETE
		
		## tell user complete
		osascript -e 'tell application "System Events" to display dialog "Activation lock code uploaded and computer is removed from Jamf" buttons {"OK"} default button 1'
		
		else
		
		## Delete record from Jamf
		curl -sku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computers/id/${deviceID} -X DELETE

		## tell user activation loack is not on
		osascript -e 'tell application "System Events" to display dialog "Activation lock is not enabled and computer has been removed from Jamf" buttons {"OK"} default button 1'

fi

echo "checks complete, exiting"

exit 0
		
		
