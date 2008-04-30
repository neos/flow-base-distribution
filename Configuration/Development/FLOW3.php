<?php
declare(ENCODING="utf-8");

/*                                                                        *
 * Configuration for the FLOW3 Framework                                  *
 *                                                                        *
 * This file contains additions to the base configuration for the FLOW3   *
 * Framework in the Development context. Just add your own modifications  *
 * as necessary.                                                          *
 *                                                                        *
 * Please refer to the default configuration file or the FLOW3 manual for *
 * possible configuration options.                                        *
 *                                                                        */

/**
 * Disable the component configuration cache.
 */
$c->component->configurationCache->enable = FALSE;

/**
 * Disable the proxy class cache.
 */
$c->aop->proxyCache->enable = FALSE;

/**
 * Use the more meaningful debug exception handler.
 */
$c->exceptionHandler->className = 'F3_FLOW3_Error_DebugExceptionHandler';

/**
 * All errors should result in exceptions.
 */
$c->errorHandler->exceptionalErrors = array(E_ERROR, E_RECOVERABLE_ERROR, E_WARNING, E_NOTICE, E_USER_ERROR, E_USER_WARNING, E_USER_NOTICE);

?>