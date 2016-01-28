#!/bin/sh -e
set -e

(
cd tmux-dev
git pull
)

echo 'archiving...'
tar -hzcf tmux-dev.tar.gz tmux-dev
