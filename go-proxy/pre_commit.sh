#!/bin/sh

set -e

cd "$(git rev-parse --show-toplevel)/go-proxy"
eval "$(direnv export bash)"

make clean
make