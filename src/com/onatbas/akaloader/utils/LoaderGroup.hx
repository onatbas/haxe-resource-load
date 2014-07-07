package com.onatbas.akaloader.utils;
import com.onatbas.akaloader.AkaLoader;

/**
 * Couple of utils to manage groups of LoaderManagers.
 * @author TiagoLr
 */
class LoaderGroup {

	static var groups:Map<String,AkaLoader> = new Map<String,AkaLoader>();
	
	public static function registerManager(manager:AkaLoader, id:String) {
		groups.set(id, group);
	}
	
	public static function getManager(id:String):AkaLoader {
		groups[id];
	}
	
	public static function unregisterManager(id:String) {
		if (groups.exists(id)) {
			groups.remove(id);
		}
	}
	
}