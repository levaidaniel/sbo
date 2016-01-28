#!/bin/sh -e

set -e


[ -z "$1" ]  &&  exit 1
[ ! -d "$1" ]  &&  exit 1

find ./"$1" \
	! -type l  | \
cpio -ovHtar |gzip -9c  > \
"${1%%/}".tar.gz
