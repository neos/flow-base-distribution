<?php
class Foo {

	public function foo() {
		return 'foo' . $this->bar() . $this->baz();
	}

	protected function bar() {
		return 'bar';
	}

	private function baz() {
		return 'baz';
	}
}

class Bar extends Foo {

	public function foo() {
		return 'foo' . $this->baz();
	}

}

$bar = new Bar;
echo $bar->foo();
