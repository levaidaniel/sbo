#!/bin/sh -e
set -e

(
cd spectrwm-dev
git pull
)

echo 'archiving...'
tar -hzcf spectrwm-dev.tar.gz spectrwm-dev