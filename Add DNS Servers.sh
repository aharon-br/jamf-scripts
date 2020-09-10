#!/bin/bash

## This will add the Specified DNS Servers in Script Options in Jamf ($4, $5, $6, $7) to the users existing DNS. 
## If running outside of Jamf edit $4,$5,$6,$7 to actual DNS entries
### Harry Richman 2020

## Make a text copy of current DNS for emergency roll back purposes
sudo networksetup -getdnsservers Wi-Fi >> /var/tmp/old_dns.txt

## Get Current DNS to ensure being added back in
currentDNS=$( networksetup -getdnsservers Wi-Fi )

## If wanting to replace DNS servers entirely remove ${currentDNS} from this line
sudo networksetup -setdnsservers Wi-Fi sudo networksetup -setdnsservers Wi-Fi $4 $5 $6 $7
 ${currentDNS}

exit 0