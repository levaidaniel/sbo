#!/bin/sh -e
set -e

(
cd ffmpeg-dev
git pull
)

echo 'archiving...'
tar -hzcf ffmpeg-dev.tar.gz ffmpeg-dev
