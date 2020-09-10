#!/bin/bash

# Make temp directory for Sophos download and install
mkdir /private/var/tmp/sophos
cd /private/var/tmp/sophos

# Remove any previous Sophos install - these lines should only be used on machines with 10.15 and broken installs
##cd /Library/Application\ Support/Sophos/saas/Installer.app/Contents/MacOS/tools/
##sudo ./InstallationDeployer --remove

#Clean up any old Sophos keychain
#sudo security delete-keychain "/Library/Sophos Anti-Virus/SophosSecure.keychain"; sudo security delete-keychain "/Library/Sophos Anti-Virus/Sophos.keychain"

# Installing Sophos
# Download Sophos
## Put you Sophos URL here
echo "`date` downloading sophos"
curl -L -O "https://SOPHOS_URL_HERE.SophosInstall.zip"
echo "`date` sophos downloading, preparing to install sophos"
unzip SophosInstall.zip
chmod a+x /private/var/tmp/sophos/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
chmod a+x /private/var/tmp/sophos/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
# Run installer
echo "`date` installing sophos"
sudo /private/var/tmp/sophos/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --install;
# Clean up temp folders
echo "`date` removing install files"
/bin/rm -rf /private/var/tmp/sophos;
echo "`date` sophos installed"
exit 0      ## Success
exit 1      ## Failure