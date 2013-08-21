#!/bin/bash

#
# Create a new branch for the distribution and its packages
#
# Needs the following environment variables
#
# BRANCH the branch to create
#

source $(dirname ${BASH_SOURCE[0]})/BuildEssentials/ReleaseHelpers.sh

if [ -z "$1" ] ; then
	echo "No branch specified (e.g. 2.1) as parameter"
	exit 1
fi
BRANCH=$1

# branch distribution
git branch ${BRANCH}
git checkout ${BRANCH}
push_branch BRANCH=$BRANCH

# branch BuildEssentials
cd Build/BuildEssentials
git branch ${BRANCH}
push_branch BRANCH=$BRANCH
cd -

# branch packages
for PACKAGE in ls Packages/Framework ; do
	cd Packages/Framework/${PACKAGE}
	git branch ${BRANCH}
	git checkout ${BRANCH}
	push_branch BRANCH=$BRANCH
	cd -
done

$(dirname ${BASH_SOURCE[0]})/set-dependencies.sh dev-${BRANCH}
