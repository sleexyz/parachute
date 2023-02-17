#!/bin/sh

set -e

cd "$(git rev-parse --show-toplevel)"
eval "$(direnv export bash)"

if [[ $(git diff --stat) != '' ]]; then
    echo "Working tree is dirty, aborting commit."
    exit 1
fi

make clean
make