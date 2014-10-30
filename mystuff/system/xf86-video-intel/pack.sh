#!/bin/sh -e
set -e

(
cd xf86-video-intel
git pull
)

echo 'archiving...'
tar -hzcf xf86-video-intel.tar.gz xf86-video-intel
