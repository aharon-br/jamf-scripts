#!/bin/zsh

## This will download the inputted installer version, then start a full erase and install of the OS
## Version number could be passed as a variable $4 in Jamf
## Harry Richman, January 2021

## Full fetch the desired installer
/usr/sbin/softwareupdate --fetch-full-installer --full-installer-version 10.15.7

## Start install with full erase and new volume
'/Applications/Install macOS Catalina.app/Contents/Resources/startosinstall' ‑‑eraseinstall
--agreetolicense --forcequitapps ‑‑newvolumename 'Macintosh HD'