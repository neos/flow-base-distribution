<?php

require_once('phing/Task.php');
require_once('PHP/UML.php');

class PhpUmlTask extends Task {

	public function setInput($path) {
		$this->input = $path;
	}

	public function setTitle($title) {
		$this->title = $title;
	}

	public function setOutput($output) {
		$this->output = $output;
	}

	public function main() {
		$this->log('Calling PHP_UML on ' . $this->input);
		$renderer = new PHP_UML();
		$renderer->deploymentView = FALSE;
		$renderer->onlyApi = TRUE;
		$renderer->setInput($this->input);
		$renderer->parse($this->title);
		$renderer->generateXMI(2.1, 'utf-8');
		$renderer->export('html', $this->output);
	}

}

?>