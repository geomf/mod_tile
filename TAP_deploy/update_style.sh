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


JSON_PY="import json,sys; print json.loads(sys.stdin.read())['user-provided'][0]['credentials']"
DBNAME=`echo $VCAP_SERVICES | python -c "$JSON_PY['database'];"`
HOST=`echo $VCAP_SERVICES | python -c "$JSON_PY['host'];"`
USER=`echo $VCAP_SERVICES | python -c "$JSON_PY['username'];"`
PASSWORD=`echo $VCAP_SERVICES | python -c "$JSON_PY['password'];"`
PORT=`echo $VCAP_SERVICES | python -c "$JSON_PY['port'];"`

sed -i 's/CDATA\[DBNAME_PLACEHOLDER\]/CDATA\['$DBNAME'\]/g' style/Feeder2_OSMBright.xml
sed -i 's/CDATA\[HOST_PLACEHOLDER\]/CDATA\['$HOST'\]/g' style/Feeder2_OSMBright.xml
sed -i 's/CDATA\[PASSWORD_PLACEHOLDER\]/CDATA\['$PASSWORD'\]/g' style/Feeder2_OSMBright.xml
sed -i 's/CDATA\[PORT_PLACEHOLDER\]/CDATA\['$PORT'\]/g' style/Feeder2_OSMBright.xml
sed -i 's/CDATA\[USER_PLACEHOLDER\]/CDATA\['$USER'\]/g' style/Feeder2_OSMBright.xml