#!/bin/sh

# Post-commit CI upload script.

set -e

cd "$(git rev-parse --show-toplevel)/go-proxy"
eval "$(direnv export bash)"

COMMIT=$(git rev-parse HEAD)
WORK_DIR="$(mktemp -d)"
FILENAME="$WORK_DIR/Ffi.xcframework_$COMMIT.tgz"

function cleanup {      
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}
trap cleanup EXIT

(cd ../ci_scripts; tar -czvf "$FILENAME" Ffi.xcframework)
gcloud storage cp "$FILENAME" gs://slowdown-ci