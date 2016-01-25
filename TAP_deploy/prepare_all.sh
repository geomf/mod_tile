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
# Create variables #
####################

PACKAGE_DIR=$(pwd)
SRC_DIR=$PACKAGE_DIR"/src"
INSTALL_DIR=$PACKAGE_DIR"/install"
LIB_DIR=$PACKAGE_DIR"/lib/"
VCAP_PREFIX="/home/vcap/app"

VCAP_DIR=$INSTALL_DIR$VCAP_PREFIX



######################
# Create directories #
######################
mkdir $SRC_DIR
mkdir $INSTALL_DIR
mkdir $LIB_DIR

#for tiles storage
mkdir tiles

#for renderd.sock and renderd.stats
mkdir renderd



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

##################
# Install Apache #
##################
cd $SRC_DIR

# Download Apache with requirements
wget http://archive.apache.org/dist/httpd/httpd-2.4.17.tar.gz
wget http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
wget http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz

# Unpack All
tar xfz httpd-2.4.17.tar.gz
tar xfz apr-1.5.2.tar.gz
tar xfz apr-util-1.5.4.tar.gz

# APR - Apache Portable Runtime
mv apr-1.5.2 httpd-2.4.17/srclib/apr

#APR Utils
mv apr-util-1.5.4 httpd-2.4.17/srclib/apr-util

# Apache
cd httpd-2.4.17/

# build apache
./configure --prefix=$VCAP_PREFIX/apache  --with-included-apr
make -s
make DESTDIR=$INSTALL_DIR install -s



####################
# Configure Apache #
####################
cd $PACKAGE_DIR

mv $VCAP_DIR/apache/conf/httpd.conf .
# if module tile_module
sed -i "186iLoadTileConfigFile /home/vcap/app/renderd.conf" httpd.conf
sed -i "187iModTileRenderdSocketName /home/vcap/app/renderd/renderd.sock" httpd.conf
sed -i "188i# Timeout before giving up for a tile to be rendered" httpd.conf
sed -i "189iModTileRequestTimeout 0" httpd.conf
sed -i "190i# Timeout before giving up for a tile to be rendered that is otherwise missing" httpd.conf
sed -i "191iModTileMissingRequestTimeout 30" httpd.conf

sed -i "152iLoadModule tile_module modules/mod_tile.so" httpd.conf



##################
# Install Mapnik #
##################
cd $SRC_DIR

#download libmapnik2.2, because it contains required shared object libmapnik.so.2.2 and mapnik/input/postgis.input
apt-get download libmapnik2.2
dpkg-deb -x libmapnik2.2_2.2.0+ds1-6build2_amd64.deb ./mapnik/

mkdir $VCAP_DIR/mapnik/lib/ -p
cp mapnik/usr/lib/* $VCAP_DIR/mapnik/lib/ -r

#there is unnecessary 2.2 folder in lib hierarchy so it must be removed
mv $VCAP_DIR/mapnik/lib/mapnik/2.2/* $VCAP_DIR/mapnik/lib/mapnik/

# create symlink to proper libmapnik.so, because rendered require libmapnik.so.2.3
cd $VCAP_DIR
ln -s libmapnik.so.2.2 ./mapnik/lib/libmapnik.so.2.3



##################################
# Install mod_tile (as rendered) #
##################################


cd $PACKAGE_DIR/..
chmod u+x ./autogen.sh
./autogen.sh
./configure --prefix=$VCAP_PREFIX/mod_tile
make -s
make DESTDIR=$INSTALL_DIR install -s
# install only so file
make DESTDIR=$INSTALL_DIR install-mod_tile -s

# copy mod_tile.so to proper directory, and Load it with apache conf
cp $INSTALL_DIR/usr/lib/apache2/modules/mod_tile.so $INSTALL_DIR/home/vcap/app/apache/modules/



########################
# Package all binaries #
########################

cd $VCAP_DIR
tar zcf ../../../../bin.tar.gz .
cd $PACKAGE_DIR



######################
# Copy required Libs #
######################

cp /usr/lib/x86_64-linux-gnu/libboost_system.so.1.54.0 $LIB_DIR
cp /usr/lib/x86_64-linux-gnu/libboost_thread.so.1.54.0 $LIB_DIR
cp /usr/lib/x86_64-linux-gnu/libboost_regex.so.1.54.0 $LIB_DIR
cp /usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.54.0 $LIB_DIR

cp /usr/lib/libproj.so.0 $LIB_DIR
cp /usr/lib/x86_64-linux-gnu/libmemcached.so.10 $LIB_DIR



