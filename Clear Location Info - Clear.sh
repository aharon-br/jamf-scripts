#!/bin/zsh

## Harry Richman, January 2021
## Version 2, revison 3

## This will remove the location data of the desired computers from the smart search of computers 

#########

## If needing to change the username/password being used:
## Create encrypted by setting function in Terminal

#function GenerateEncryptedString() {
#local STRING="${1}"
#local SALT=$(openssl rand -hex 8)
#local K=$(openssl rand -hex 12)
#local ENCRYPTED=$(echo "${STRING}" | openssl enc -aes256 -a -A -S "${SALT}" -k "${K}")
#echo "Encrypted String: ${ENCRYPTED}"
#echo "Salt: ${SALT} | Passphrase: ${K}"
#}

### Then run GenerateEncryptedString thePasswordToEncrypt

#########

## Enrcrypted API User password
encryptedString="STRING"
salt="STRING"
passphrase="STRING"

#Decrypt encrypted string
#function DecryptString() {
#echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
#}

jamfPW=$( echo "$encryptedString" | /usr/bin/openssl enc -aes256 -d -a -A -S "$salt" -k "$passphrase" ) 


jamfUser="api-user-name"
URL="https://URL.jamfcloud.com"


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

# ID number of search that contains computers to remove location data of
sID="SEARCH ID NUMBER"

# Get ID of computers in search of computers haven't check in for over 45 days
computerSearch=$( curl -X GET -skfu "${jamfUser}:${jamfPW}" "${URL}/JSSResource/advancedcomputersearches/id/$sID" -H "accept: application/xml" | xmllint --format  - | awk -F '[<>]' '/<id>/{print $3}' | tail -n +2 | tail -r | tail -n +2 | tail -r )

for device in $computerSearch
	do 
		curl -sfku "${jamfUser}:${jamfPW}" "${URL}/JSSResource/computers/id/$device" -T /tmp/empty_location.xml -X PUT
	curl -X POST -sku ${jamfUser}:${jamfPW} ${URL}/JSSResource/computercommands/command/UnmanageDevice/id/${device}
	#echo "$device"
done

## Delete the empty location XML
sudo rm -f /tmp/empty_location.xml

exit 0