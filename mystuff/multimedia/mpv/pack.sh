#!/bin/sh -e
set -e

(
cd mpv-dev
git pull
)

echo 'archiving...'
tar -hzcf mpv-dev.tar.gz mpv-dev
