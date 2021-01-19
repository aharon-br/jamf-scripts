#!/bin/zsh

## This will remove desired versions of Adobe CC applications.
## Created by Harry Richman, January 2021
## Version 2

## Check for Adobe CC application. If this is not present, script can exit at this stage
if [[ -d "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app" ]]
	then
		echo "Adobe Creative Cloud present, proceeding"
	else
		echo "Adobe Creative Cloud not found, exiting"
		exit 0
fi
## Start for loop to loop through list of apps - could use $ variables to inject from Jamf
for app in Photoshop Bridge "Premier Pro" "After Effects"
do
### Check for CC 2020/2021 of application, if present remove any 2019 or below
if [[ -d "/Applications/Adobe $app 2020" ]] || [[ -d "/Applications/Adobe $app 2021" ]]
	then
		echo "$app 2020/2021 found, checking for old versions"
		if [[ -d "/Applications/Adobe $app CC 2019" ]]
			then 
				echo "$app 2019 found"
				rm -rf "/Applications/Adobe $app CC 2019"
		fi
		if [[ -d "/Applications/Adobe $app CC 2018" ]]
			then 
				echo "$app 2018 found"
				rm -rf "/Applications/Adobe $app CC 2018"
		fi
		if [[ -d "/Applications/Adobe $app CC 2017" ]]
			then 
				echo "$app 2017 found"
				rm -rf "/Applications/Adobe $app CC 2017"
		fi
	else
		echo "no $app 2021/2020"
fi

done

exit 0