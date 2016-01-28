#!/bin/sh -e
set -e

(
cd kc-dev
git checkout master && git pull
)

echo 'archiving...'
tar -hzcf kc-dev.tar.gz kc-dev
