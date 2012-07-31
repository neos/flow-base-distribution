<?php
// See the following file for detailed usage explanations:
include(__DIR__ . '/../Common/Surf/CommonJenkinsDistributionBuild.php');

$application->setOption('projectName', 'TYPO3 Phoenix');
$application->setOption('repositoryUrl', 'git://git.typo3.org/TYPO3v5/Distributions/Base.git');

$application->setOption('sourceforgeProjectName', 'typo3');
$application->setOption('sourceforgePackageName', 'TYPO3 Phoenix');
$application->setOption('changeLogUri', '/documentation/features.html');

// Currently, because we are doing sprint releases, we only tag the main project and not the distributions
$application->setOption('tagRecurseIntoSubmodules', FALSE);

$application->setOption('releaseDownloadLabel', 'Phoenix Base Distribution');
$application->setOption('releaseDownloadUriPattern', sprintf('http://sourceforge.net/projects/typo3/files/TYPO3 Phoenix/%s/%%s/download', getenv('VERSION')));
?>