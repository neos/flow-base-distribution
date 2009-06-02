#!/bin/bash

# This is a little convenience script which sets / fixes the permissions of the Data
# and the Public directory. This script will disappear as soon as we have some proper
# installation routine in place.
#
# Make sure to set the webserver group name to the one used by your system.

usage() {
	echo
	echo Usage: $0 \<webuser\> \<webgroup\>
	echo Run as superuser, if needed
	echo
	exit 1
}

if [ "$#" != "2" ]; then
  usage
fi

WEBSERVER_USER="$1"
WEBSERVER_GROUP="$2"

find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

find Data -not -regex '.*[.]svn.*' -not -name 'CLI' -exec chown $WEBSERVER_USER:$WEBSERVER_GROUP {} \;
chmod 755 Data
find Data -type d -exec chmod 755 {} \;
find Data -type f -exec chmod 644 {} \;
chmod 777 Data/Logs

chmod 755 flow3 
chmod 755 $0

chmod 755 Public
chmod 755 Public/index.php

find Public/Resources -type d -exec chmod 755 {} \;
find Public/Resources -type f -exec chmod 644 {} \;
find Public/Resources -not -regex '.*[.]svn.*'  -exec chown $WEBSERVER_USER:$WEBSERVER_GROUP {} \;
