#!/bin/sh

set -e

cd "$(git rev-parse --show-toplevel)"
eval "$(direnv export bash)"

make clean
make