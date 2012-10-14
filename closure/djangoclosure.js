goog.provides('djangoclosure.net.DjangoXhrIo');
goog.require('goog.net.XhrIo');
/**
 * DjangoXhrio
 * @extends {goog.net.Xhrio}
 */
djangoclosure.net.DjangoXhrIo = function(){
	goog.base(this);
	this.set('X-Requested-With','XMLHttpRequest');
};
goog.inherits(djangoclosure.net.DjangoXhrIo,
		goog.net.Xhrio);