<?php
declare(ENCODING = 'utf-8');

/*                                                                        *
 * This script is part of the TYPO3 project - inspiring people to share!  *
 *                                                                        *
 * TYPO3 is free software; you can redistribute it and/or modify it under *
 * the terms of the GNU General Public License version 2 as published by  *
 * the Free Software Foundation.                                          *
 *                                                                        *
 * This script is distributed in the hope that it will be useful, but     *
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHAN-    *
 * TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General      *
 * Public License for more details.                                       *
 *                                                                        */

/**
 * Bootstrap for the FLOW3 Framework
 *
 * @package FLOW3
 * @version $Id$
 * @author Robert Lemke <robert@typo3.org>
 * @license http://opensource.org/licenses/gpl-license.php GNU Public License, version 2
 */

define('FLOW3_PATH_PUBLIC', str_replace('\\', '/', dirname(__FILE__)) . '/');
require_once(FLOW3_PATH_PUBLIC . '../Packages/FLOW3/Classes/F3_FLOW3.php');

$framework = new F3_FLOW3();
$framework->run();
?>