#!/bin/sh

set -e

cd "$(git rev-parse --show-toplevel)"
eval "$(direnv export bash)"


if [[ "$(git diff --stat)" != '' ]]; then
    echo "Working tree is dirty, aborting commit:"
    git status --short
    exit 1
fi

UNTRACKED_FILES="$(git ls-files . --exclude-standard --others)"
if [[ "${UNTRACKED_FILES}" != '' ]]; then
    echo "Found untracked files, aborting commit:"
    echo "${UNTRACKED_FILES}"
    exit 1
fi

make clean
make
