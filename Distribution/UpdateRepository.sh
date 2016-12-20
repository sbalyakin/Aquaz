#!/bin/sh

#  UpdateRepository.sh
#  Aquaz
#
#  Created by Sergey Balyakin on 07.12.15.
#  Copyright © 2015 Sergey Balyakin. All rights reserved.

###########################################################################################
# IMPORTANT: read readme.txt file before usage

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;36m'
COLOR_NONE='\033[0m'

AQUAZ_INFOPLIST_FILE=../Aquaz/Info.plist
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$AQUAZ_INFOPLIST_FILE")

# Commit updated Info.plist
echo "${COLOR_BLUE}Commit the updated Info.plist files.${COLOR_NONE}"
git commit -a -m "Task #108, Build number has been updated to $buildNumber."

# Push the changes
echo "\n${COLOR_BLUE}Push the changes to the repository.${COLOR_NONE}"
git push --all

# Add tag
shortVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$AQUAZ_INFOPLIST_FILE")
fullVersion=$shortVersion.$buildNumber
echo "\n${COLOR_BLUE}Add tag for version $fullVersion.${COLOR_NONE}"
git tag -a v$fullVersion -m "Version $fullVersion"

# Push the tag
echo "\n${COLOR_BLUE}Push the new tag to the repository.${COLOR_NONE}"
git push origin v$fullVersion

echo "\n${COLOR_GREEN}Done.${COLOR_NONE}"
