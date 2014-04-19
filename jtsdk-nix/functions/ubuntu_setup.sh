#! /usr/bin/env bash
#
# Name			: ubuntu-setup.sh
# Execution		: used by setup.sh for UBuntu systems
# Author		: Greg, Beam, ki7mt -at- yahoo.com
# Copyright		: Copyright (C) 2014 Joseph H Taylor, Jr, K1JT
# Contributors	: KI7MT
#
# ubuntu-setup.sh is part of the JTSDK-NIX project
#
# JTSDK-NIX is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation either version 3 of the License, or
# (at your option) any later version. 
#
# JTSDK-NIX is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------#

# check which version we are using
function setup_marker() {

if [[ -d ~/.local/share/applications/jtsdk-nix ]]; then
mkdir -p ~/.local/share/applications/jtsdk-nix
fi

}


# check which version we are using
function ubuntu_distro_check() {

# uname still best way to get arch ?
_ARCH=$(uname -i)

# ubuntu uses lsb_release 
_DISTRIBUTOR=$( lsb_release -i |awk 'FNR==1 {print $3}')
_RELEASE=$(lsb_release -r |awk '{print $2}')

}

# Ubuntu 64-Bit
function ub1404_x86_64() {

sudo apt-get install cmake dialog subversion clang-3.5 gfortran \
libfftw3-dev git libgfortran3:i386 libusb-dev autoconf libtool \
texinfo qt5-default qtmultimedia5-dev libqt5multimedia5-plugins \
libsamplerate-dev portaudio19-dev python-virtualenv virtualenvwrapper

}

# Ubuntu 32-Bit
function ub1404_x86() {

sudo apt-get install cmake dialog subversion clang-3.5 gfortran \
libfftw3-dev git libgfortran3:i386 libusb-dev autoconf libtool \
texinfo qt5-default qtmultimedia5-dev libqt5multimedia5-plugins \
libsamplerate-dev portaudio19-dev python-virtualenv virtualenvwrapper

}


# Python3 Setup Using Python3 (JTSDK-ENV) 
function python_env_setup() {

# Add pip completion to ~/.bashrc
pip completion --bash >> ~/.bashrc

apt-get install python3-dev python-tk python3-imaging python3-imaging \
python3-imaging-tk python-virtualenv python3-setuptools \
python3-pip python3-numpy

}



