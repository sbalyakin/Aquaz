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

# Increase build number for Aquaz target
AQUAZ_INFOPLIST_FILE=../Aquaz/Info.plist
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$AQUAZ_INFOPLIST_FILE")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $buildNumber" "$AQUAZ_INFOPLIST_FILE"
echo "### Build number for Aquaz target has been bumped to $buildNumber."

# Increase build number for Widget target
WIDGET_INFOPLIST_FILE=../Widget/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $buildNumber" "$WIDGET_INFOPLIST_FILE"
echo "### Build number for Widget target has been bumped to $buildNumber."

# Increase build number for Watch target
WATCH_INFOPLIST_FILE=../Watch/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $buildNumber" "$WATCH_INFOPLIST_FILE"
echo "### Build number for Watch target has been bumped to $buildNumber."

# Increase build number for Watch Extension target
WATCH_EXTENSION_INFOPLIST_FILE=../Watch\ Extension/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $buildNumber" "$WATCH_EXTENSION_INFOPLIST_FILE"
echo "### Build number for Watch Extension target has been bumped to $buildNumber."

echo "### Done."