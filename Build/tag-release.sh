#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/BuildEssentials/ReleaseHelpers.sh

if [ -z "$1" ] ; then
	echo "No version specified (e.g. 2.1.*) as first parameter"
	exit 1
fi
VERSION=$1

if [ -z "$2" ] ; then
	echo "No branch specified (e.g. 2.1) as second parameter"
	exit 1
fi
BRANCH=$2

if [ -z "$3" ] ; then
	echo "No build URL specified as third parameter"
	exit 1
fi
BUILD_URL=$3

tag_version VERSION=$VERSION BRANCH=$BRANCH BUILD_URL=$BUILD_URL
push_branch BRANCH=$BRANCH
push_tag TAG=$VERSION

cd Build/BuildEssentials
tag_version VERSION=$VERSION BRANCH=$BRANCH BUILD_URL=$BUILD_URL
push_branch BRANCH=$BRANCH
push_tag TAG=$VERSION
cd -

for PACKAGE in `ls Packages/Framework` ; do
	cd Packages/Framework/${PACKAGE}
	tag_version VERSION=$VERSION BRANCH=$BRANCH BUILD_URL=$BUILD_URL
	push_branch BRANCH=$BRANCH
	push_tag TAG=$VERSION
	cd -
done
