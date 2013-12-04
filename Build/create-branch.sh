#!/bin/bash

#
# Create a new branch for the distribution and its packages
#
# Needs the following arguments
#
# $1 BRANCH    the branch to create
# $2 BUILD_URL used in commit message
#

source $(dirname ${BASH_SOURCE[0]})/BuildEssentials/ReleaseHelpers.sh

if [ -z "$1" ] ; then
	echo >&2 "No branch specified (e.g. 2.1) as first parameter"
	exit 1
fi
BRANCH=$1

if [ -z "$2" ] ; then
	echo >&2 "No build URL given as second parameter"
	exit 1
fi
BUILD_URL="$2"

# branch distribution
git checkout -b ${BRANCH} origin/master

# branch BuildEssentials
git --git-dir "Build/BuildEssentials/.git" --work-tree "Build/BuildEssentials" checkout -b ${BRANCH} origin/master

# branch packages
for PACKAGE in `ls Packages/Framework` ; do
	git --git-dir "Packages/Framework/${PACKAGE}/.git" --work-tree "Packages/Framework/${PACKAGE}" checkout -b ${BRANCH} origin/master
done

$(dirname ${BASH_SOURCE[0]})/set-dependencies.sh "${BRANCH}.*@dev" ${BRANCH} "${BUILD_URL}"

push_branch ${BRANCH}
push_branch ${BRANCH} "Build/BuildEssentials"
for PACKAGE in `ls Packages/Framework` ; do
	push_branch ${BRANCH} "Packages/Framework/${PACKAGE}"
done
