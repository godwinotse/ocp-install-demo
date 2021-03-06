#!/bin/sh 

SRC_URL=https://github.com/eschabell/origin.git
SRC_REF=docker_version_warning
OS_TYPE=darwin/amd64 
BUILD_FILE=https://raw.githubusercontent.com/eschabell/build-origin/master/origin-builder.yaml

# prints the documentation for this script.
function print_docs() 
{
	echo "This application will build you a new os commandline client for your operating"
	echo "system, one with the fix for the new boot2docker iso that uses v17.03 and"
	echo "gives errors with oc-v3.2.1.4 and possibly all previous versions:"
	echo
	echo "    -- Checking Docker version ... FAIL"
	echo "    Error: Minor number must not contain leading zeroes '03'"
	echo 
	echo "Run this builder and provide the target operating system:"
	echo
	echo "   $ ./oc_builder.sh [ linux | osx | windows ]"
	echo
	echo "You need a running OpenShift and your oc client must be logged in before"
	echo "running this builder. The ouput will be found by looking up the deployed"
	echo "builders published route, which is a web server hosting the newly created"
	echo "oc client for you to download."
	echo
}

build_os()
{
	# Incoming parameter, should be 'linux', 'darwin' or 'windows'.
	#
	target_os="$1/amd64"

	# Forcing you to login.
	#
	oc login --password=devel --username=openshift-dev

	# Try to create new project, if fails not a problem.
	#
	echo "Creating a new project for you..."
	echo
	oc new-project my-project

  if [ $? -ne 0 ]; then
		echo
		echo Error occurred during 'oc new-project' command!
		exit
	fi	
	
	# Select correct builder based on given os.
	#
	echo "Starting to build a new fixed oc client for your $1 system..."
	echo
	echo "Building using: $BUILD_FILE, source url: $SRC_URL, ref: $SRC_REF and platform: $target_os"
	echo
	oc new-app -f $BUILD_FILE -p SOURCE_URL=$SRC_URL -p SOURCE_REF=$SRC_REF -p PLATFORM=$target_os 

	if [ $? -ne 0 ]; then
		echo
		echo Error occurred during 'oc new-app' command!
		exit
	fi
}

# wipe screen.
clear 

echo
echo "##############################################################"
echo "##                                                          ##"   
echo "##  Building a new version of oc, for one of the following  ##"
echo "##  platforms with fix for boot2docker using v17.03:        ##"
echo "##                                                          ##"   
echo "##   linux/amd64 or darwin/amd64 or windows/amd64           ##"   
echo "##                                                          ##"   
echo "##############################################################"
echo

# validate args, expecting 'linux' | 'windows' | 'osx'.
if [ $# -eq 1 ]; then
	echo "Validating argument: $1"
	echo
	if [ $1 == "linux" ]; then
		echo "Starting build of oc with fix for Linux systems..."
		echo
		build_os "linux"
	elif [ $1 == "windows" ]; then
		echo "Starting build of oc with fix for Windows systems..."
		echo
		build_os "windows"
	elif [ $1 == "osx" ]; then
		echo "Starting build of oc with fix for osX systems..."
		echo
		build_os "darwin"
	else
	  print_docs
	  exit	
	fi
elif [ $# -gt 1 ]; then
	print_docs
	echo
	exit
else
	# no arguments, prodeed with default host.
	print_docs
	echo
	exit
fi

echo
echo "Login to OpenShift and wait for the build to finish and find your deployed oc tool..."
echo
