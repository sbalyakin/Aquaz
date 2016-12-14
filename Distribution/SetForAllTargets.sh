#!/bin/sh

#  SetVersion.sh
#  Aquaz
#
#  Created by Sergey Balyakin on 13.12.16.
#  Copyright © 2016 Sergey Balyakin. All rights reserved.

PARAM_BUNDLE_KEY="$1"
PARAM_VALUE="$2"

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;36m'
COLOR_NONE='\033[0m'

AQUAZPRO_INFOPLIST_FILE=../Aquaz/Info.plist
AQUAZPRO_WIDGET_INFOPLIST_FILE=../Widget/Info.plist
AQUAZPRO_WATCH_INFOPLIST_FILE=../Watch/Info.plist
AQUAZPRO_WATCH_EXTENSION_INFOPLIST_FILE=../Watch\ Extension/Info.plist
AQUAZLITE_INFOPLIST_FILE=../AquazLiteSpecific/Aquaz-Info.plist
AQUAZLITE_WIDGET_INFOPLIST_FILE=../AquazLiteSpecific/Aquaz\ Widget-Info.plist
AQUAZLITE_WATCH_INFOPLIST_FILE=../AquazLiteSpecific/Aquaz\ Watch-Info.plist
AQUAZLITE_WATCH_EXTENSION_INFOPLIST_FILE=../AquazLiteSpecific/Aquaz\ Watch\ Extension-Info.plist

TARGETS_ARRAY=(
"AquazPro:../Aquaz/Info.plist"
"AquazPro Widget:../Widget/Info.plist"
"AquazPro Watch:../Watch/Info.plist"
"AquazPro Watch Extension:../Watch Extension/Info.plist"
"Aquaz:../AquazLiteSpecific/Aquaz-Info.plist"
"Aquaz Widget:../AquazLiteSpecific/Aquaz Widget-Info.plist"
"Aquaz Watch:../AquazLiteSpecific/Aquaz Watch-Info.plist"
"Aquaz Watch Extension:../AquazLiteSpecific/Aquaz Watch Extension-Info.plist"
)

setBundleKey() {
  INFO_PLIST="$1"
  TARGET="$2"
  VALUE="$3"
  BUNDLE_KEY="$4"
  BUNDLE_KEY_DESCRIPTION="$5"

  /usr/libexec/PlistBuddy -c "Set ${BUNDLE_KEY} ${VALUE}" "${INFO_PLIST}"
  echo "${COLOR_YELLOW}${BUNDLE_KEY_DESCRIPTION}${COLOR_NONE} ${COLOR_GREEN}${VALUE}${COLOR_NONE} has been set for ${COLOR_BLUE}${TARGET}${COLOR_NONE}"
}

setBundleKeyForAll() {
  VALUE="$1"
  BUNDLE_KEY="$2"
  BUNDLE_KEY_DESCRIPTION="$3"

  for TARGET_INFO in "${TARGETS_ARRAY[@]}" ; do
    TARGET="${TARGET_INFO%%:*}"
    INFO_PLIST="${TARGET_INFO##*:}"
    setBundleKey "${INFO_PLIST}" "${TARGET}" "${VALUE}" "${BUNDLE_KEY}" "${BUNDLE_KEY_DESCRIPTION}"
  done

  echo "${COLOR_GREEN}Done${COLOR_NONE}"
}


if [ "${PARAM_BUNDLE_KEY}" = "ShortVersion" ] ; then
  setBundleKeyForAll "${PARAM_VALUE}" "CFBundleShortVersionString" "Short version"
elif [ "${PARAM_BUNDLE_KEY}" = "BuildNumber" ] ; then
  setBundleKeyForAll "${PARAM_VALUE}" "CFBundleVersion" "Build number"
else
  echo "${COLOR_RED}Error: Unknown bundle key${COLOR_NONE}"
fi

