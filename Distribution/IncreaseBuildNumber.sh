#!/bin/sh

#  IncreaseBuildNumber.sh
#  Aquaz
#
#  Created by Sergey Balyakin on 07.12.15.
#  Copyright © 2015 Sergey Balyakin. All rights reserved.

###########################################################################################
# IMPORTANT: read readme.txt file before usage

# Check repository for uncommited changes
#if [ "`git status -s 2>&1 | egrep '^\?\?|^ M|^A |^ D|^fatal:'`" ] ; then
#echo "Error: Uncommited changes are detected. Commit them into git before deployment."
#exit 1
#fi

# Increase build number based on 'AquazPro' target
AQUAZPRO_INFOPLIST_FILE=../Aquaz/Info.plist

BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${AQUAZPRO_INFOPLIST_FILE}")
BUILD_NUMBER=$((${BUILD_NUMBER} + 1))

sh SetForAllTargets.sh "BuildNumber" "${BUILD_NUMBER}"
