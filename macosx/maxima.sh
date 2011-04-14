#!/bin/sh

ROOT=`(cd \`dirname $0\` > /dev/null 2>&1 ; pwd)`
MAXIMA_PREFIX=$ROOT/maxima/
export MAXIMA_PREFIX

PATH="$MAXIMA_PREFIX/bin:$PATH"
export PATH

exec "$MAXIMA_PREFIX/bin/maxima" "$1" "$2" "$3" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
