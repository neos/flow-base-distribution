<?php

require_once('phing/tasks/ext/svn/SvnBaseTask.php');
require_once('phing/BuildException.php');

class SetPackagesExternalsTask extends SvnBaseTask {

	public function setPackagesPath($packagesPath) {
		$this->packagesPath = $packagesPath;
	}

	public function setFixRevision($fixRevision) {
		$this->fixRevision = $fixRevision;
	}

	public function main() {
		$latestPackageRevisions = array();

		if ($this->fixRevision) {
			foreach (new DirectoryIterator($this->packagesPath) as $file) {
				$filename = $file->getFilename();
				if ($file->isDir() && $filename[0] !== '.') {
					$this->setup('info');
					$xml = simplexml_load_string($this->run(array($file->getPathName(), '--xml')));
					if ($xml === FALSE) {
						throw new BuildException('svn info returned no parseable xml.');
					}
					$latestPackageRevisions[$filename] = (integer)$xml->entry->commit['revision'];
				}
			}
		}

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
					($this->fixRevision ? str_pad(('-r' . $latestPackageRevisions[$packageKey]), 10) : '') .
					trim($uri) . chr(10);
			}
		}
		$this->setup('propset');
		$existingExternals = $this->run(array('svn:externals', escapeshellarg($newExternals), $this->packagesPath));
	}

}

?>