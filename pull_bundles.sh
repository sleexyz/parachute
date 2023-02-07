#!/bin/sh

set -e

ARCHIVE_DIR=".external/slowdown-ci-archives"
BUNDLE_DIR="$HOME/Desktop/slowdown-ci-archives_extracted"

mkdir -p "$BUNDLE_DIR"
gsutil rsync -r gs://slowdown-ci-archives/ "$ARCHIVE_DIR"

for FILE in .external/slowdown-ci-archives/*; do 
  OUTPUT="$BUNDLE_DIR/$(basename -- "$FILE" .tgz)"
  if [ ! -d "$OUTPUT" ]; then
    echo "Extracting $FILE"
    tar -xvf "$FILE" -C "$BUNDLE_DIR/"
  else
    echo "Already extracted, skipping: $FILE"
  fi
done

open "$BUNDLE_DIR"
