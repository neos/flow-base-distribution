#!/bin/bash

#
# Updates the dependencies in composer.json files of the dist and its
# packages.
#
# Needs the following environment variables
#
# VERSION          the version that is "to be released"
# BRANCH           the branch that is worked on, used in commit message
# BUILD_URL        used in commit message
#

source $(dirname ${BASH_SOURCE[0]})/BuildEssentials/ReleaseHelpers.sh

if [ -z "$1" ] ; then
	echo "No version specified (e.g. 2.1.*) as parameter"
	exit 1
fi

if [[ $1 =~ (dev)-.+ || $1 =~ (alpha|beta)[0-9]+ ]] ; then
	VERSION=$1
	STABILITY_FLAG=${BASH_REMATCH[1]}
else
	if [[ $1 =~ ([0-9]+\.[0-9]+)\.[0-9] ]] ; then
		VERSION=${BASH_REMATCH[1]}.*
	else
		echo "Version $1 could not be parsed."
		exit 1
	fi
fi

if [[ $STABILITY_FLAG ]] ; then
	composer require --no-update "typo3/eel:@${STABILITY_FLAG}"
	composer require --no-update "typo3/fluid:@${STABILITY_FLAG}"
	composer require --no-update "typo3/party:@${STABILITY_FLAG}"
else
	php $(dirname ${BASH_SOURCE[0]})/BuildEssentials/FilterStabilityFlags.php
fi
composer require --no-update "typo3/flow:${VERSION}"
composer require --no-update "typo3/welcome:${VERSION}"
composer require --dev --no-update "typo3/kickstart:${VERSION}"
composer require --dev --no-update "typo3/buildessentials:${VERSION}"
commit_manifest_update BRANCH=$BRANCH BUILD_URL=$BUILD_URL

cd Packages/Framework/TYPO3.Flow
composer require --no-update "typo3/eel:${VERSION}"
composer require --no-update "typo3/fluid:${VERSION}"
composer require --no-update "typo3/party:${VERSION}"
commit_manifest_update BRANCH=$BRANCH BUILD_URL=$BUILD_URL
cd -

for PACKAGE in `ls Packages/Framework` ; do
	if [ $PACKAGE != "TYPO3.Flow" ] ; then
		cd Packages/Framework/${PACKAGE}
		composer require --no-update "typo3/flow:${VERSION}"
		commit_manifest_update BRANCH=$BRANCH BUILD_URL=$BUILD_URL
		cd -
	fi
done
