# Copyright (C) 2001, 2002  Earnie Boyd  <earnie@users.sf.net>
# This file is part of the Minimal SYStem.
# http://www.mingw.org/msys.shtml
# 
# File:			profile
# Description:	Shell environment initialization script
# Last Revised:	22-NOV-2014 by KI7MT

if [ -z "$MSYSTEM" ]; then
  MSYSTEM=MINGW32
fi

# My decision to add a . to the PATH and as the first item in the path list
# is to mimick the Win32 method of finding executables.
#
# I filter the PATH value setting in order to get ready for self hosting the
# MSYS runtime and wanting different paths searched first for files.

#------------------------------------------------------------------------------#
# KI7MT edit:
# * Remove Win32 %PATH% from both line to prevent Win32 sys path inclusion.
# * Add /scripts to both paths
#------------------------------------------------------------------------------#
if [ $MSYSTEM == MINGW32 ]; then
  export PATH=".:/local/bin:/bin:/lib:/include:/share:/scripts"
else
  export PATH=".:/local/bin:/bin:/lib:/include:/share:/scripts"
fi

if [ -z "$USERNAME" ]; then
  LOGNAME="`id -un`"
else
  LOGNAME="$USERNAME"
fi

# Set up USER's home directory
if [ -z "$HOME" ]; then
  HOME="/home/$LOGNAME"
fi

#------------------------------------------------------------------------------#
# KI7MT edit:
# * Added /scripts/msys-skel for copytin to $HOME 
# * Added all the copy commands under if [ ! -d "$HOME" ]; then .. fi
#------------------------------------------------------------------------------#
if [ ! -d "$HOME" ]; then
	mkdir -p "$HOME"
	# Copy all profiles
	clsb
	echo '-----------------------------------------------------------'
	echo " Setting up $HOME"
	echo '-----------------------------------------------------------'
	cp /etc/skel/.bashrc "$HOME"/.bashrc && echo "..installing: JTSDK bashrc to $HOME/.bashrc"
	cp /etc/skel/.bash_aliases "$HOME"/.bash_aliases && echo "..installing: JTSDK bash_aliases to $HOME/.bash_aliases"
	cp /etc/skel/.bash_profile "$HOME"/.bash_profile && echo "..installing: JTSDK bash_bashrc to $HOME/.bash_profile"
	cp /etc/skel/.inputrc "$HOME"/.inputrc && echo "..installing: JTSDK inputrc to $HOME/.inputrc"
	cp /etc/skel/.minttyrc "$HOME"/.minttyrc && echo "..installing: JTSDK minttyrc to $HOME/.minttyrc"
	echo ''
fi

if [ "x$HISTFILE" == "x/.bash_history" ]; then
  HISTFILE=$HOME/.bash_history
fi

export HOME LOGNAME MSYSTEM HISTFILE
export MAKE_MODE=unix

#------------------------------------------------------------------------------#
# KI7MT edit:
# * Updated Widows title and PS prompt
# * Added finished-post-install check and comments 
#------------------------------------------------------------------------------#
export PS1='\[\033]0;JTSDK MSYS Development Environment\007\033[32m\]\u@\h\[\033[33m\w\033[0m\]$ '
alias clear=clsb

if [ ! -f "$HOME"/.initial-setup ] ; then

	# Foreground colors
	C_R='\033[01;31m'		# red
	C_G='\033[01;32m'		# green
	C_Y='\033[01;33m'		# yellow
	C_C='\033[01;36m'		# cyan
	C_NC='\033[01;37m'		# no color

	echo ''
	echo -en ${C_G}'New User Setup Complete:' && echo -en ${C_R}" -->> RESTART REQUIRED <<--\n"${C_NC}
	echo ''
	echo "In order for your new [ $LOGNAME ] account to be completed,"
	echo 'you need to Re-Start JTSDK-MSYS'
	echo ''
	echo 'At the prompt, type: exit, then re-launch JTSDK-MSYS'
	echo ''
	touch "$HOME"/.initial-setup
else
	cat /scripts/msys-header.txt
	source /scripts/msys-alias.txt
fi
cd "$HOME"
