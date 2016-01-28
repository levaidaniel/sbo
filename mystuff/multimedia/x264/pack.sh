#!/bin/sh -e
set -e

(
cd x264-dev
git pull
cd ..
)

echo 'archiving...'
tar -hzcf x264-dev.tar.gz x264-dev
