#!/bin/bash -x
#
# Mod Tile Software for generating and serving mapping tiles
# Copyright (c) 2016, Intel Corporation.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#


####################
# Install packages #
####################
sudo apt-get update -qq

# basic packages
sudo apt-get install tar wget git-core build-essential -y
#build esentials - install make and fix paths for ICU :P

# neccessary packages for apache
sudo apt-get install libpcre++-dev -y

# neccessary packages for mod_tile
sudo apt-get install dh-autoreconf apache2-dev libmapnik-dev -y
# libmapnik-dev - install proper mapnik includes (C++ headers files) which are required to compile mod_tile

