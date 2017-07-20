#!/bin/sh -e
set -e

(
cd x265-dev
git pull
cd ..
)

echo 'archiving...'
tar -hzcf x265-dev.tar.gz x265-dev
