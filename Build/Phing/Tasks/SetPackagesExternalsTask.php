<?php

require_once('phing/tasks/ext/svn/SvnBaseTask.php');
require_once('phing/BuildException.php');

class SetPackagesExternalsTask extends SvnBaseTask {

	public function setPackagesPath($packagesPath) {
		$this->packagesPath = $packagesPath;
	}

	public function setWorkingCopyRevision($workingCopyRevision) {
		$this->workingCopyRevision = $workingCopyRevision;
	}

	public function main() {
		$this->setup('propget');
		$existingExternals = $this->run(array('svn:externals', $this->packagesPath));
		$newExternals = '';
		$externalsArray = array();
		foreach (explode(chr(10), $existingExternals) as $line) {
			if (strlen(trim($line)) > 0) {
				$line = preg_replace('/\-r[0-9]+/', '', $line);
				$line = preg_replace('/ +/', ' ', $line);
				list($packageKey, $uri) = explode(' ', $line);
				$newExternals .=
					str_pad($packageKey, 50) .
					((int)$this->workingCopyRevision > 0 ? str_pad(('-r' . $this->workingCopyRevision), 10) : '') .
					trim($uri) . chr(10);
			}
		}
		$this->setup('propset');
		$existingExternals = $this->run(array('svn:externals', escapeshellarg($newExternals), $this->packagesPath));
	}

}

?>