goog.provide('djangoclosure.debug.Logger');
goog.require('goog.dom');
goog.require('goog.debug.Logger');

/**
 * Logger to make it easy to compile debug
 * messages out of the code.
 * @constructor
 */
djangoclosure.debug.Logger = function(){};
djangoclosure.debug.Logger.prototype.info = function(){};

/***
 * Set goog.DEBUG to false to get rid of logging.
 * @param {string} loggerName
 */
djangoclosure.debug.Logger.getLogger = function(loggerName){
    if (goog.DEBUG==false) {
    	return new djangoclosure.debug.Logger();
    }else{
    	return   goog.debug.Logger.getLogger(loggerName);
    }  	
}