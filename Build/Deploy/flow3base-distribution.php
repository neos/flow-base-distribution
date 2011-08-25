<?php

use \TYPO3\Deploy\Domain\Model\Workflow;
use \TYPO3\Deploy\Domain\Model\Node;
use \TYPO3\Deploy\Domain\Model\SimpleWorkflow;

// Needs the following mandatory environment options:
// - WORKSPACE: work-directory
// - VERSION: version to be packaged
//
// By default, the script does the following:
// - run tests
// - build .tar.gz, .tar.bz2, .zip distribution
// - tag the distribution and the submodules (but does not push them)

// Has the following optional environment options:
// - SOURCEFORGE_USER -- username which should be used for sourceforge.net upload.
//                       if set, and ENABLE_SOURCEFORGE_UPLOAD is NOT "false", will upload
//                       the distribution to sourceforge
// - ENABLE_SOURCEFORGE_UPLOAD -- if set to string "false", Sourceforge upload is disabled
//                                no matter if SOURCEFORGE_USER is set or not.
// - ENABLE_TESTS -- if set to string "false", unit and functional tests are disabled
// - CREATE_TAGS -- if set to string "false", the distribution and submodules are not tagged

$application = new \TYPO3\Deploy\Application\FLOW3Distribution();
$application->setOption('repositoryUrl', 'git://git.typo3.org/FLOW3/Distributions/Base.git');

$application->setOption('projectName', 'FLOW3');
$application->setOption('sourceforgeProjectName', 'flow3');
$application->setOption('sourceforgePackageName', 'FLOW3');

if (getenv('VERSION')) {
	$application->setOption('version', getenv('VERSION'));
} else {
	throw new \Exception('version to be released must be set in the VERSION env variable. Example: VERSION=1.0.0-beta1');
}

$application->setOption('enableTests', getenv('ENABLE_TESTS') !== 'false');
$application->setOption('createTags', getenv('CREATE_TAGS') !== 'false');

if (getenv('SOURCEFORGE_USER') && getenv('ENABLE_SOURCEFORGE_UPLOAD') !== 'false') {
	$application->setOption('enableSourceforgeUpload', TRUE);
	$application->setOption('sourceforgeUserName', getenv('SOURCEFORGE_USER'));
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