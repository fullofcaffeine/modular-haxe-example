package util;

import js.Browser;
import js.html.LinkElement;
import js.html.ScriptElement;
import js.Promise;

class Require
{
	static var loaded:Map<String, Promise<String>> = new Map();
	
	static public function module(name:String, loadCss:Bool = true):Promise<String>
	{
		if (loaded.exists(name)) 
			return loaded.get(name);
		
		var p = new Promise<String>(function(resolve, reject) {
			var doc = Browser.document;
			var pending = loadCss ? 2 : 1;
			var css:LinkElement = null;
			var script:ScriptElement = null;
			var hasFailed:Bool = false;
			
			function resourceLoaded() 
			{
				if (--pending == 0) 
					resolve(name);
			}
			function resourceFailed()
			{
				if (!hasFailed)
				{
					hasFailed = true;
					
					loaded.remove(name); // retry
					if (css != null) doc.body.removeChild(css);
					doc.body.removeChild(script);
					
					reject(name);
				}
			}
			
			if (loadCss)
			{
				css = doc.createLinkElement();
				css.rel = 'stylesheet';
				css.onload = resourceLoaded;
				css.onerror = resourceFailed;
				css.href = '$name.css';
				doc.body.appendChild(css);
			}
			
			script = doc.createScriptElement();
			script.onload = resourceLoaded;
			script.onerror = resourceFailed;
			script.src = '$name.js';
			doc.body.appendChild(script);
		});
		
		loaded.set(name, p);
		return p;
	}
	
}