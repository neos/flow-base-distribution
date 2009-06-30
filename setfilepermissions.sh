#!/bin/bash

# This is a little convenience script which sets / fixes the permissions of the Data
# and the Public directory. This script will disappear as soon as we have some proper
# installation routine in place.
#
# Make sure to set the webserver group name to the one used by your system.

usage() {
	echo
	echo Usage: $0 \<commandlineuser\> \<webgroup\>
	echo Run as superuser, if needed
	echo
	exit 1
}

if [ "$#" != "2" ]; then
  usage
fi

COMMANDLINE_USER="$1"
WEBSERVER_GROUP="$2"

find . -type d -exec chmod 750 {} \;
find . -type f -exec chmod 640 {} \;
find Data . -exec chown $COMMANDLINE_USER:$WEBSERVER_GROUP {} \;

chmod 755 Data
find Data -type d -exec chmod 770 {} \;
find Data -type f -exec chmod 660 {} \;
chmod 770 Data/Logs

chmod 770 flow3 
chmod 770 $0

chmod 750 Public
chmod 750 Public/index.php

find Public/Resources -type d -exec chmod 770 {} \;
find Public/Resources -type f -exec chmod 660 {} \;
find Public/Resources -not -regex '.*[.]svn.*'  -exec chown $COMMANDLINE_USER:$WEBSERVER_GROUP {} \;
