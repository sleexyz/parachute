#!/bin/sh

rm -rf dist
npm run build
gsutil -m cp -R ./dist/* gs://parachute-site