#!/bin/bash

# This is a little convenience script which sets / fixes the permissions of the Data
# and the Public directory. This script will disappear as soon as we have some proper
# installation routine in place.
#
# Make sure to set the webserver group name to the one used by your system before running
# this script.

usage() {
  echo Usage: $0 \<webuser\> \<webgroup\>
  exit 1
}

if [ "$#" != "2" ]; then
  usage
fi

WEBSERVER_USER="$1"
WEBSERVER_GROUP="$2"

chmod 775 Data
find Data/* -type d -exec chmod 775 {} \;
find Data/* -type f -exec chmod 664 {} \;

chmod 775 Public
find Public/* -type d -exec chmod 775 {} \;
find Public/* -type f -exec chmod 664 {} \;

chown -R $WEBSERVER_USER Public/Resources/
chown -R $WEBSERVER_USER:$WEBSERVER_GROUP Data/
