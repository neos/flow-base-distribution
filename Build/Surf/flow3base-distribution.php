<?php
use TYPO3\Surf\Domain\Model\Workflow;
use TYPO3\Surf\Domain\Model\Node;
use TYPO3\Surf\Domain\Model\SimpleWorkflow;

// Needs the following mandatory environment options:
// - WORKSPACE: work-directory
// - VERSION: version to be packaged
//
// By default, the script does the following:
// - run tests
// - build .tar.gz, .tar.bz2, .zip distribution
// - tag the distribution and the submodules (but does not push them)

// Has the following optional environment options:
// - BRANCH -- the branch to check out as base for further actions, defaults to "master"
// - SOURCEFORGE_USER -- username which should be used for sourceforge.net upload.
//                       if set, and ENABLE_SOURCEFORGE_UPLOAD is NOT "false", will upload
//                       the distribution to sourceforge
// - ENABLE_SOURCEFORGE_UPLOAD -- if set to string "false", Sourceforge upload is disabled
//                                no matter if SOURCEFORGE_USER is set or not.
// - RELEASE_HOST -- the hostname on which to add the release to the TYPO3.Release. If not set
//                   release creation will be skipped
// - RELEASE_HOST_LOGIN -- the user to use for the login, optional
// - RELEASE_HOST_SITE_PATH -- the path in which to run the release commands
// - ENABLE_TESTS -- if set to string "false", unit and functional tests are disabled
// - CREATE_TAGS -- if set to string "false", the distribution and submodules are not tagged

$application = new \TYPO3\Surf\Application\FLOW3Distribution();

$application->setOption('projectName', 'FLOW3');
$application->setOption('repositoryUrl', 'git://git.typo3.org/FLOW3/Distributions/Base.git');

if (getenv('VERSION')) {
	$application->setOption('version', getenv('VERSION'));
} else {
	throw new \Exception('version to be released must be set in the VERSION env variable. Example: VERSION=1.0-beta1 or VERSION=1.0.1');
}
if (getenv('BRANCH')) {
	$application->setOption('git-checkout-branch', getenv('BRANCH'));
}

$application->setOption('enableTests', getenv('ENABLE_TESTS') !== 'false');
$application->setOption('createTags', getenv('CREATE_TAGS') !== 'false');

if (getenv('SOURCEFORGE_USER') && getenv('ENABLE_SOURCEFORGE_UPLOAD') !== 'false') {
	$application->setOption('enableSourceforgeUpload', TRUE);
	$application->setOption('sourceforgeUserName', getenv('SOURCEFORGE_USER'));
	$application->setOption('sourceforgeProjectName', 'flow3');
	$application->setOption('sourceforgePackageName', 'FLOW3');
}

if (getenv('RELEASE_HOST')) {
	$application->setOption('releaseHost', getenv('RELEASE_HOST'));
	$application->setOption('releaseHostLogin', getenv('RELEASE_HOST_LOGIN'));
	$application->setOption('releaseHostSitePath', getenv('RELEASE_HOST_SITE_PATH'));
	$application->setOption('changeLogUri', '/documentation/guide/partv/changelogs/' . str_replace('.', '', getenv('VERSION')) . '.html');
}
if (getenv('RELEASE_HOST') && getenv('SOURCEFORGE_USER') && getenv('ENABLE_SOURCEFORGE_UPLOAD') !== 'false') {
	$application->setOption('releaseDownloadLabel', 'Base Distribution');
	$application->setOption('releaseDownloadUriPattern', sprintf('http://sourceforge.net/projects/flow3/files/FLOW3/%s/%%s/download', getenv('VERSION')));
}
if (getenv('WORKSPACE')) {
	$application->setDeploymentPath(getenv('WORKSPACE'));
} else {
	throw new \Exception('deployment path must be set in the WORKSPACE env variable');
}

$deployment->addApplication($application);

$workflow = new SimpleWorkflow();
$deployment->setWorkflow($workflow);

$node = new Node('localhost');
$node->setHostname('localhost');
$application->addNode($node);
$deployment->addNode($node);

?>