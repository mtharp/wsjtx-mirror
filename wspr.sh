#!/usr/bin/env bash
#
# Shell script wrapper to update or copy files from the system install

set -e

# set dir's
_HOMEDIR="/home/$USER/.wspr"

# make a few dir's
mkdir -p $_HOMEDIR

# update files only if newer
cp -uR /usr/share/wspr/* $_HOMEDIR
cp -uR /usr/share/doc/wspr/* $_HOMEDIR/
cp -uR /usr/lib/wspr/* $_HOMEDIR

# run: py location updated by configure.ac
cd $_HOMEDIR
/usr/bin/python3 -O wspr.py
