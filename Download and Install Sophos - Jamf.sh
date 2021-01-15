#!/bin/zsh

## This will download and install the latest Sophos availble from the sophos web portal
## Harry Richman, created March 2020. Last updated January 2021
## Version 2

# Make temp directory for Sophos download and install
mkdir /private/var/tmp/sophos
cd /private/var/tmp/sophos

# Download Sophos
echo "`date` downloading sophos"
# Use Jamf variable $4 to pass URL from sophos portal
curl -s -L -O "$4"

echo "`date` sophos downloading, preparing to install sophos"
unzip SophosInstall.zip
## Adjusts permissions for Sophos to ensure runs
chmod a+x /private/var/tmp/sophos/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
chmod a+x /private/var/tmp/sophos/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
# Run installer
echo "`date` installing sophos"
sudo /private/var/tmp/sophos/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --install 
# Clean up temp folders
echo "`date` removing install files"
/bin/rm -rf /private/var/tmp/sophos;
echo "`date` sophos installed"

exit 0