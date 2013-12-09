#!/bin/bash

#
# Generates a changelog in reStructuredText from the commit history of
# the base distribution and all packages in Packages/Framework
#
# Needs the following environment variables
#
# WORKSPACE        the base directory of the distribution
# VERSION          the version that is "to be released"
# PREVIOUS_VERSION the last released version, is guessed if not given
# BRANCH           the branch that is worked on, used in commit message
# BUILD_URL        used in commit message
#

TARGET="${WORKSPACE}/Packages/Framework/TYPO3.Flow/Documentation/TheDefinitiveGuide/PartV/ChangeLogs/`echo ${VERSION} | tr -d .`.rst"

cd "${WORKSPACE}"
export TARGET

echo -e "====================\n${VERSION}\n====================\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nBase Distribution\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" > "${TARGET}"
git log --pretty=format:"%s
-----------------------------------------------------------------------------------------

%b

* Commit: \`%h <https://git.typo3.org/Flow/Distributions/Base.git/commit/%H>\`_

" --no-merges ${PREVIOUS_VERSION}.. >> "${TARGET}"

for PACKAGE in `ls Packages/Framework` ; do
	cd "${WORKSPACE}/Packages/Framework/${PACKAGE}"
	echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n${PACKAGE}\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" >> "${TARGET}"
	git log --pretty=format:"%s
-----------------------------------------------------------------------------------------

%b

* Commit: \`%h <https://git.typo3.org/Packages/${PACKAGE}.git/commit/%H>\`_

" --no-merges ${PREVIOUS_VERSION}.. >> "${TARGET}" || true
done;

# Drop some footer lines from commit messages
perl -p -i -e 's|^Change-Id: (I[a-f0-9]+)$||g' "${TARGET}"
perl -p -i -e 's|^Releases?:.*$||g' "${TARGET}"
perl -p -i -e 's|^Migration?:.*$||g' "${TARGET}"
perl -p -i -e 's|^Reviewed-by?:.*$||g' "${TARGET}"
perl -p -i -e 's|^Reviewed-on?:.*$||g' "${TARGET}"
perl -p -i -e 's|^Tested-by?:.*$||g' "${TARGET}"

# Link issues to Forge
perl -p -i -e 's/(Fixes|Resolves|Related|Relates|Extbase Issue): #([0-9]+)/* $1: `#$2 <http:\/\/forge.typo3.org\/issues\/$2>`_/g' "${TARGET}"
perl -p -i -e 's/Security-Bulletin: (FLOW3-SA-[0-9]{4}-[0-9]+)/* Security-Bulletin: `$1 <http:\/\/typo3.org\/teams\/security\/security-bulletins\/flow3\/$1\/>`_/g' "${TARGET}"
perl -p -i -e 's/Security-Bulletin: (FLOW-SA-[0-9]{4}-[0-9]+)/* Security-Bulletin: `$1 <http:\/\/typo3.org\/teams\/security\/security-bulletins\/flow\/$1\/>`_/g' "${TARGET}"

# escape backslashes
perl -p -i -e 's/\\/\\\\/g' "${TARGET}"
# clean up empty lines
perl -p -i -0 -e 's/\n\n+/\n\n/g' "${TARGET}"
# join bullet list items
perl -p -i -0 -e 's/(\* [^\n]+)\n+(\* [^\n]+)/$1\n$2/g' "${TARGET}"
# amend empty sections (todo: get rid of duplication)
perl -p -i -0 -e 's/(~{40}\n[a-z0-9.]+\n~{40}\n)(\n~{40})/$1\nNo changes\n$2/ig' "${TARGET}"
perl -p -i -0 -e 's/(~{40}\n[a-z0-9.]+\n~{40}\n)(\n~{40})/$1\nNo changes\n$2/ig' "${TARGET}"
perl -p -i -0 -e 's/(~{40}\n[a-z0-9.]+\n~{40}\n)(\n*)$/$1\nNo changes\n$2/ig' "${TARGET}"
# remove automatic submodule pointer raises
perl -p -i -0 -e 's/\[TASK\] Raise submodule pointers(?:[^[]+)//ig' "${TARGET}"
# remove automatic lock file updates
perl -p -i -0 -e 's/\[TASK\] Automatic composer.lock update(?:[^[]+)//ig' "${TARGET}"

# commit generated changelog
cd "${WORKSPACE}/Packages/Framework/TYPO3.Flow"
git add Documentation/TheDefinitiveGuide/PartV/ChangeLogs/`basename "${TARGET}"`
git commit -m "[TASK] Add changelog for TYPO3 Flow ${VERSION}" -m "See $BUILD_URL" -m "Releases: $BRANCH"
cd -
