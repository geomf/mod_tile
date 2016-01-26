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

#update style with data from VCAP_SERVICES
./update_style.sh

# unpack binaries
tar xfz bin.tar.gz

# Change apache to listen on proper port
sed -i "52s/80/$PORT/" httpd.conf

# Starting apache server and specify config file
# BUG: There is some minor problem with it, because it should start with blocking console, but it not and this is strange, but is good ;p , no need of & at the end
./apache/bin/apachectl -f /home/vcap/app/httpd.conf

./mod_tile/bin/renderd -f -c renderd.conf

# wait until the server will start and work normally - this shouldn't be neccessary
sleep 1000

