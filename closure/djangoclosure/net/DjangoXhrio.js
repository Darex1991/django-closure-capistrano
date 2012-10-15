goog.provides('djangoclosure.net.DjangoXhrio');
goog.require('goog.net.XhrIo');
/**
 * DjangoXhrio
 * @extends {goog.net.Xhrio}
 */
djangoclosure.net.DjangoXhrio = function(){
	goog.base(this);
	this.set('X-Requested-With','XMLHttpRequest');
};
goog.inherits(djangoclosure.net.DjangoXhrio,
		goog.net.Xhrio);