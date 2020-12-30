#!/bin/zsh

## This will show which city Zscaler is currently connected to if using ZIA 

location=$( curl -sk ip.zscaler.com | grep "Zscaler Cloud:" | tr -d '<>"":./=' | sed -e s/div//g -e s/classheadlineYou//g -e s/are//g -e s/accessing//g -e s/the//g -e s/Internet//g -e s/via//g -e s/Zscaler//g -e s/Cloud//g -e s/III//g -e s/in//g -e s/zscalerthreenet//g -e s/cloud//g | tr -d " " )

echo "<result>$location</result>"