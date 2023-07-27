#!/bin/sh

DEVICE_NAME="Sean's iPhone"
SCHEME="slowdown"
CONFIGURATION="Debug"
PROJECT_NAME="slowdown"
PROJECT_SUFFIX="-gfbjubyeazbnhffdewgtqvlhggki"

DERIVED_DATA_PATH="Build/iOS/$PROJECT_NAME$PROJECT_SUFFIX"

xcrun xcodebuild \
  -scheme "$SCHEME" \
  -configuration $CONFIGURATION \
  -derivedDataPath "$DERIVED_DATA_PATH"

ios-deploy --justlaunch --debug --bundle "$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION-iphoneos/$PROJECT_NAME.app"