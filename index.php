<?php
declare(encoding = 'utf-8');

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
 * Fallback Bootstrap for the FLOW3 Framework.
 *
 * This file only becomes active in setups which don't allow for moving files
 * to outside the web root directory. While the preferred method is to make
 * only the "Public/" directory publicly available, it is also possible use
 * this index.php as the root script.
 *
 * @package FLOW3
 * @version $Id$
 * @author Robert Lemke <robert@typo3.org>
 * @copyright Copyright belongs to the respective authors
 * @license http://opensource.org/licenses/gpl-license.php GNU Public License, version 2
 */

require_once('Public/index.php');
?>