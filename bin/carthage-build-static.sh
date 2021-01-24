#!/bin/sh -e

#  Created by Mark Jarecki on 10/7/19.
#
# Usage:
#
# Basic.
# bash ./path/to/build-static-carthage -d realm-cocoa RxSwift RxSwiftExt -p ios
#
# Custom framework search path, relative to the project
# bash ./path/to/build-static-carthage -d realm-cocoa RxSwift RxSwiftExt -p ios -f ./path/to/Carthage/SomeOtherBuildDir/iOS/**
#

# Make a unique temporary file with mktemp
XCCONFIG=$(mktemp /tmp/static.xcconfig.XXXXXX)

# Perform clean-up on Interrupt, Hang Up, Terminate, Exit signals
trap 'rm -f "$XCCONFIG"' INT TERM HUP EXIT

# Base framework search path
FMWK_SEARCH_PATHS="\$(inherited) "

# Current flag cursor
CURRENT_FLAG=""

# Write properties to the temp xconfig file
echo "MACH_O_TYPE = staticlib" >> $XCCONFIG
echo "DEBUG_INFORMATION_FORMAT = dwarf" >> $XCCONFIG
# echo "CLANG_ENABLE_CODE_COVERAGE = NO" >> $XCCONFIG
echo "FRAMEWORK_SEARCH_PATHS = $FMWK_SEARCH_PATHS" >> $XCCONFIG
# echo "BUILD_LIBRARY_FOR_DISTRIBUTION = YES" >> $XCCONFIG

# Export temporary xcconfig file to all current shell child processes
export XCODE_XCCONFIG_FILE="$XCCONFIG"

while read line; do
echo "$line"
done < $XCCONFIG

carthage $1 $2 --no-use-binaries --verbose --platform ios