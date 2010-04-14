<?php

require_once('phing/tasks/ext/svn/SvnBaseTask.php');
require_once('phing/BuildException.php');

class SvnSwitchTaskTask extends SvnBaseTask {

	public function setTargetUrl($targetUrl) {
		$this->targetUrl = $targetUrl;
	}

	public function setDir($dir) {
		$this->dir = $dir;
	}

	public function main() {
		$this->setup('switch');
		$this->run(array($this->targetUrl, $this->dir));
	}

}

?>