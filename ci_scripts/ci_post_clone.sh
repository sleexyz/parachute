#!/bin/sh

#  ci_post_clone.sh
#  slowdown
#
#  Created by Sean Lee on 1/17/23.
#  

#!/bin/sh


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

./ci-pull | tar -xzvf - -C "$CI_SCRIPTS_DIR"
    
echo "done"
exit 0
