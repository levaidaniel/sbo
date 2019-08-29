#!/bin/sh -e
set -e

(
cd motion
git pull
)

echo 'archiving...'
tar -hzcf motion.tar.gz motion
