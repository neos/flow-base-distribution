<?php
declare(ENCODING="utf-8");

/*                                                                        *
 * Additional component configuration                                     *
 *                                                                        *
 * This file contains additions to the component configuration. It is     *
 * loaded at the component initialization stage during the FLOW3 initiali-*
 * zation sequence. Just add your own modifications as necessary.         *
 *                                                                        *
 * Please refer to the FLOW3 manual for possible configuration options.   *
 *                                                                        */

$c->F3_TYPO3CR_StorageAccessInterface->constructorArguments[1] = 'sqlite:/tmp/FLOW3/TYPO3CR.db';

?>