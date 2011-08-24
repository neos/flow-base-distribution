<?php

use \TYPO3\Deploy\Domain\Model\Workflow;
use \TYPO3\Deploy\Domain\Model\Node;
use \TYPO3\Deploy\Domain\Model\SimpleWorkflow;


$application = new \TYPO3\Deploy\Application\FLOW3Distribution();
$application->setOption('repositoryUrl', 'git://git.typo3.org/FLOW3/Distributions/Base.git');

$application->setOption('projectName', 'FLOW3');
$application->setOption('sourceforgeProjectName', 'flow3');
$application->setOption('sourceforgePackageName', 'FLOW3');

if (getenv('F3_VERSION')) {
	$application->setOption('version', getenv('F3_VERSION'));
} else {
	throw new \Exception('version to be released must be set in the F3_VERSION env variable. Example: F3_VERSION=1.0.0-beta1');
}
$application->setOption('enableTests', TRUE);
$application->setOption('createTags', TRUE);

if (getenv('F3_SOURCEFORGE_USER')) {
	$application->setOption('enableSourceforgeUpload', TRUE);
	$application->setOption('sourceforgeUserName', getenv('F3_SOURCEFORGE_USER'));
}

if (getenv('F3_DEPLOY_PATH')) {
	$application->setDeploymentPath(getenv('F3_DEPLOY_PATH'));
} else {
	throw new \Exception('deployment path must be set in the F3_DEPLOY_PATH env variable');
}

$deployment->addApplication($application);

$workflow = new SimpleWorkflow();
$deployment->setWorkflow($workflow);

$node = new Node('localhost');
$node->setHostname('localhost');
$application->addNode($node);
$deployment->addNode($node);


?>