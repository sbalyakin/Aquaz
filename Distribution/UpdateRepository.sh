#!/bin/sh

#  UpdateRepository.sh
#  Aquaz
#
#  Created by Sergey Balyakin on 07.12.15.
#  Copyright © 2015 Sergey Balyakin. All rights reserved.

###########################################################################################
# IMPORTANT: read readme.txt file before usage

# Commit updated Info.plist
echo "### Commit the updated Info.plist files."
git commit -a -m "Task #108, Build number has been updated to $buildNumber."

# Push the changes
echo "### Push the changes to the repository."
git push --all

# Add tag
shortVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$AQUAZ_INFOPLIST_FILE")
fullVersion=$shortVersion.$buildNumber
echo "### Add tag for version $fullVersion."
git tag -a v$fullVersion -m "Version $fullVersion"

# Push the tag
echo "### Push the new tag to the repository."
git push origin v$fullVersion

echo "### Done."
