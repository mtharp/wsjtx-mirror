#!/usr/bin/env bash
#
# Shell Script wrapper to copy wspr files to $HOME/.wspr
#
set -e

# set dir's
_BASED="/home/$USER/.wspr"
_SHARED=/usr/share/wspr
_BINDIR=/usr/bin

if [ ! -d "$_BASED" ]; then
	mkdir -p "$_BASED"/.wspr
fi

# cp "link" runtime files
ln -sf /usr/bin/fmtest "$_BASED"/fmtest
ln -sf /usr/bin/fmeasure "$_BASED"/fmeasure
ln -sf /usr/bin/fcal "$_BASED"/fcal
ln -sf /usr/bin/fmtave "$_BASED"/fmtave
ln -sf /usr/bin/wspr0 "$_BASED"/wspr0
ln -sf /usr/bin/wsprcode "$_BASED"/wsprcode
cp -rsf /usr/share/wspr/* "$_BASED"/

# cd to .wspr and run: py location updated form configure.ac
cd $_BASED
/usr/bin/python3 -O wspr.py
