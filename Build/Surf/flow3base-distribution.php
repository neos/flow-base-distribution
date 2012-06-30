<?php
// See the following file for detailed usage explanations:
include(__DIR__ . '/../Common/Surf/CommonJenkinsDistributionBuild.php');

$application->setOption('projectName', 'FLOW3');
$application->setOption('repositoryUrl', 'git://git.typo3.org/FLOW3/Distributions/Base.git');

$application->setOption('sourceforgeProjectName', 'flow3');
$application->setOption('sourceforgePackageName', 'FLOW3');
$application->setOption('changeLogUri', '/documentation/guide/partv/changelogs/' . str_replace('.', '', getenv('VERSION')) . '.html');

$application->setOption('releaseDownloadLabel', 'Base Distribution');
$application->setOption('releaseDownloadUriPattern', sprintf('http://sourceforge.net/projects/flow3/files/FLOW3/%s/%%s/download', getenv('VERSION')));
?>