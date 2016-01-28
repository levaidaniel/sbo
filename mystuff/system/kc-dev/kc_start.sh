#!/bin/sh


if [ $(( $RANDOM % 2)) -eq 0 ];then
	KC=/usr/bin/kc_readline
else
	KC=/usr/bin/kc_editline
fi

echo "Starting development version: ${KC}"
ulimit -c unlimited
$KC $@
