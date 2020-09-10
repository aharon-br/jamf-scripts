#! /bin/bash 


## This will allow setting a drop down menu EA variable in Jamf on a bulk quantity of computers
## The CSV of computers should be one line per name of computer, with an extra blank line at the end

## This should be run locally on your computer 'sudo sh /path/to/this/script.sh'

## Created by Harry Richman, September 2020
## Version 1


# Set field seperator to a comma
IFS=,

# Read from list of CSV computer names, set name to variable $id
while read id;do

# jamf account name
APIUser="jamf-user-name"
# jamf password
APIPassword="jamf-password"

# jamf Pro URL
JSSURL="https://whatever.jamfcloud.com"

# jamf Pro URL plus full path
JSSHostname="$JSSURL/JSSResource/computers/name/$id/subset/extensionattributes"

# Set this group to the desired EA drop down, e.g. A, B, C - change this as appropaite
value="A"

## Writes to an extension attribute called MY NEW EA in the Extension Attributes area of the computer record, pulls $value variable - change these as appropropate

XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>MY NEW EA</name><value>$value</value></extension_attribute></extension_attributes></computer>"

## upload to JSS using CURL to add in the above XML content 

curl -s -f -k -u $APIUser:$APIPassword -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$XMLTOWRITE" $JSSHostname --verbose

## complete when the following CSV list has no more entries
## Change path of CSV to the CSV file on your computer you wish to read from

done < "/path/to/csv.csv"