package com.onatbas.akaloader.utils;
import com.onatbas.akaloader.AkaLoader;

/**
 * Couple of utils to manage a group of LoaderManagers.
 * @author TiagoLr
 */
class LoaderGroup {

	static var managers:Map<String,AkaLoader> = new Map<String,AkaLoader>();
	
	public static function registerManager(manager:AkaLoader, id:String) {
		managers.set(id, group);
	}
	
	public static function getManager(id:String):AkaLoader {
		managers[id];
	}
	
	public static function unregisterManager(id:String) {
		if (managers.exists(id)) {
			managers.remove(id);
		}
	}
	
}