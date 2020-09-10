#!/bin/bash

## This will revert DNS to a text file that may have been previously saved
### Created by Harry Richman, July 2020 

oldDNS=$( cat /private/var/tmp/old_dns.txt )


if [[ "$oldDNS" = "There aren't any DNS Servers set on Wi-Fi." ]]
then
sudo networksetup -setdnsservers Wi-Fi empty
echo "DNS Servers removed, set to default"
else
sudo networksetup -setdnsservers Wi-Fi ${oldDNS}
echo "DNS Servers removed, set user inputted DNS"
fi
exit 0