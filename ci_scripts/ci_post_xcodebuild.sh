#!/bin/sh

#  ci_post_xcodebuild.sh
#  slowdown
#
#  Created by Sean Lee on 1/19/23.
#  

set -e

CI_SCRIPTS_DIR="$(pwd)"

# See https://developer.apple.com/documentation/xcode/environment-variable-reference
if [ -z "${CI_COMMIT}" ];
then
  export CI_COMMIT=$(git rev-parse HEAD)
fi

CREDS_FILENAME="$CI_SCRIPTS_DIR/creds.json"
echo "$SLOWDOWN_CI_CREDS" | openssl enc -base64 -d > "$CREDS_FILENAME"
export GOOGLE_APPLICATION_CREDENTIALS="$CREDS_FILENAME"

if [[ -n $CI_ARCHIVE_PATH ]];
then
    CI_ARCHIVE_PATH_DIRNAME=$(dirname "${CI_ARCHIVE_PATH}")
    export CI_ARCHIVE_PATH_BASENAME=$(basename "${CI_ARCHIVE_PATH}")
    echo "Archive path is available"
    (cd "${CI_ARCHIVE_PATH_DIRNAME}"; tar -czvf - "${CI_ARCHIVE_PATH_BASENAME}") | ./push_bin

    # # Move up to parent directory
    # cd ..
    # # Debug
    # echo "Derived data path: $CI_DERIVED_DATA_PATH"
    # echo "Archive path: $CI_ARCHIVE_PATH"
    # # Crashlytics dSYMs script
    # $CI_DERIVED_DATA_PATH/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols -gsp /GoogleService-Info.plist -p ios $CI_ARCHIVE_PATH/dSYMs
else
    echo "Archive path isn't available."
fi
