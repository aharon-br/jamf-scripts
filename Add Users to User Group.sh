#!/bin/zsh

## Harry Richman, January 2021

## This will add users to a user group from a CSV of usernames


## Enrcrypted API User password
encryptedString="STRING"
salt="STRING"
passphrase="STRING"

jamfPW=$( echo "$encryptedString" | /usr/bin/openssl enc -aes256 -d -a -A -S "$salt" -k "$passphrase" ) 

jamfUser="API-USER-NAMES"
URL="https://URL.jamfcloud.com"

# Set ID number of usergroup here
groupID="GROUP_NUMBER"

## Set IFS to comma
IFS=,

## Loop thru CSV and add all usernames to the group inputted
while read userName;do
curl -sfku "${jamfUser}:${jamfPW}" "${URL}/JSSResource/usergroups/id/$groupID" -X PUT -HContent-type:application/xml --data "<user_group><user_additions><user><username>${userName}</username></user></user_additions></user_group>"

echo "$userName added"
done < /path/to/USERNAME.csv