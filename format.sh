#!/bin/sh

EXTRA_ARGS=$@

swiftformat --swiftversion 5.9 .  --exclude Build,ProxyService $EXTRA_ARGS
