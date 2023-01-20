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
    CI_ARCHIVE_PATH_BASENAME=$(basename "${CI_ARCHIVE_PATH}")
    echo "Archive path is available"
    export ARCHIVE_NAME="slowdown_build_${CI_BUILD_NUMBER}_${CI_COMMIT}.xcarchive"
    (cd "${CI_ARCHIVE_PATH_DIRNAME}"; /usr/bin/tar -s "/${CI_ARCHIVE_PATH_BASENAME}/${ARCHIVE_NAME}/" -czvf - "${CI_ARCHIVE_PATH_BASENAME}") | ./push_bin
else
    echo "Archive path isn't available."
fi

exit 0
