#!/bin/zsh 

## This will install Rosetta without user interaction
## It should be targetted just as Apple Slicon to avoid excessive failures, but this will also perform a check

# Harry Richman, January 2021


## Check if computer is Apple Silicon
## Apple Silicon will be 'arm64', Intel 'i386'
arch=$( /usr/bin/arch )

if [[ "$arch" == "arm64" ]]
	then
	echo "Apple Silicon, installing Rosetta"	
	sudo softwareupdate --install-rosetta --agree-to-license
	exit 0
	else
	echo "not Apple Silicon"
	exit 1
fi
