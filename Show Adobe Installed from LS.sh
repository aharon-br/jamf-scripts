#!/bin/bash

ccApps=$( ls /Applications | grep "Adobe" | sed -e 's/Adobe Acrobat Reader DC.app//' | sed -e 's/Adobe Creative Cloud//' | sed -e 's/Adobe//' | sed 's/^[[:space:]]*//g' | sed '/^[[:space:]]*$/d' | tr -d 0123456789 )

echo "$ccApps"