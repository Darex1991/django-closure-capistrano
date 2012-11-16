goog.provide('djangoclosure.net.getJavascriptFile');
goog.require('goog.dom');
/**
 * Add the new script to the dom.
 *  @param {string} scriptURI
 *  @param {string} newScriptId
 *  @returns {boolean} True if fetched else false;
 */
djangoclosure.net.getJavascriptFile = function(scriptURI,
		newScriptId
		){
    if(!goog.dom.getElement(newScriptId)){
        var fjs = goog.dom.getElementsByTagNameAndClass("script")[0];
        var js=goog.dom.createDom("script");
        js.id=newScriptId;
        js.src=scriptURI;
        js.async=true;
        fjs.parentNode.insertBefore(js,fjs);
        return true;
    }
    return false;
}