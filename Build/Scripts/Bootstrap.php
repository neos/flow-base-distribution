<?php
declare(ENCODING = 'utf-8');
namespace F3\Testing;

/*                                                                        *
 * This script belongs to the FLOW3 build system.                         *
 *                                                                        *
 * It is free software; you can redistribute it and/or modify it under    *
 * the terms of the GNU General Public License as published by the Free   *
 * Software Foundation, either version 3 of the License, or (at your      *
 * option) any later version.                                             *
 *                                                                        *
 * This script is distributed in the hope that it will be useful, but     *
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHAN-    *
 * TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General      *
 * Public License for more details.                                       *
 *                                                                        *
 * You should have received a copy of the GNU General Public License      *
 * along with the script.                                                 *
 * If not, see http://www.gnu.org/licenses/gpl.html                       *
 *                                                                        *
 * The TYPO3 project - inspiring people to share!                         *
 *                                                                        */

/**
 * A simple class loader that deals with the Framework classes and is intended
 * for use with PHPUnit.
 *
 * @param string $className
 * @return void
 * @author Karsten Dambekalns <karsten@typo3.org>
 */
function loadClassForTesting($className) {
	$classNameParts = explode('\\', $className);
	if (is_array($classNameParts) && $classNameParts[0] === 'F3') {
		$packagesBasePath = dirname(__FILE__) . '/../../Packages/';
		foreach (array('Framework', 'Application') as $packageCategory) {
			$classFilePathAndName = $packagesBasePath . $packageCategory . '/' . $classNameParts[1] . '/Classes/';
			$classFilePathAndName .= implode(array_slice($classNameParts, 2, -1), '/') . '/';
			$classFilePathAndName .= end($classNameParts) . '.php';
			if (file_exists($classFilePathAndName)) {
				require($classFilePathAndName);
				break;
			}
		}
	}
}

spl_autoload_register('F3\Testing\loadClassForTesting');

\F3\FLOW3\Core\Bootstrap::defineConstants();

?>