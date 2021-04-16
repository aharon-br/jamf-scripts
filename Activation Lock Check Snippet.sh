#!/bin/zsh

## This will check if activation lock is one or not on the specified serial number (that of the logged in computer)
## This can be changed to search by computer ID if using a loop with many ID

## This is a snippet to be used with other things - a good check if using a script that is deleting anything from jamf 

## Harry Richman, March 2021

## Put the script you wish to run once checks are done here
scriptLocation="/private/tmp/script.sh"
cat > ${scriptLocation} <<EOF
## replace the two lines below
echo "this is the script"
echo "the script is now running"
EOF


## Get serial of computer this is running on
serial=$( /usr/sbin/ioreg -l | /usr/bin/awk '/IOPlatformSerialNumber/ { print $4;}' | /usr/bin/tr -d '"' )

## set username, PW and URL - send this as variables from jamf is preffered
jamfUser="USER FOR API"
jamfPW="PASSWORD FOR API"
URL="https://JAMF_URL.jamfcloud.com"


## get activation lock status from jamf api
activationLockStatus=$( curl -sku ${jamfUser}:${jamfPW} -H "accept: application/xml" "${URL}/JSSResource/computers/serialnumber/${serial}/subset/security" | xpath "string(//activation_lock)" 2>/dev/null )

if [[ ${activationLockStatus} == true ]]
	then
		
		echo "activation lock is on"
		
		## notify with applescript
		activationLockCode=$( osascript -e 'tell application "System Events" to text returned of (display dialog "Activation Lock is on, please retrieve the code from Jamf" default answer "Enter bypass code" buttons {"OK"} default button 1)' )
		
		## bypass code should match - re run if not matching
		until [[ $activationLockCode =~ ^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$ ]]
			do
				activationLockCode=$( osascript -e 'tell application "System Events" to text returned of (display dialog "Code incorrect, please retrieve the code from Jamf" default answer "Enter bypass code" buttons {"OK"} default button 1)' )
		done
		
		## remind to save code
		osascript -e 'tell application "System Events" to display dialog "Thank you, please save this code somewhere before moving forward" buttons {"I have saved the code"} default button 1'
		
		## Put your script that you wish to run here e.g. a scrtip that deletes from jamf
		sudo sh $scriptLocation
		
	else
		
		## if activation lock is not true, go ahead and run whatever your script is
		sudo sh $scriptLocation
fi

## Remove
rm -rf $scriptLocation
echo "temporary script deleted"

exit 0