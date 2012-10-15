goog.provide('djangoclosure.net.DjangoXhrIo');
goog.require('goog.net.XhrIo');
/**
 * DjangoXhrIo
 * @constructor
 * @extends {goog.net.XhrIo}
 */
djangoclosure.net.DjangoXhrIo = function(){
	goog.base(this);
	this.headers.set('X-Requested-With','XMLHttpRequest');
};
goog.inherits(djangoclosure.net.DjangoXhrIo,
		goog.net.XhrIo);