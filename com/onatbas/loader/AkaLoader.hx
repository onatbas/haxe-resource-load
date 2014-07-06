package com.onatbas.loader;

import com.onatbas.loader.loaders.BaseLoader;
import com.onatbas.loader.loaders.BaseLoader.LoaderStatus;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.media.Sound;

/**
 * Client API class.
 */
class AkaLoader extends EventDispatcher
{
	var manager:LoaderManager;
	
    public function new(maxConnectionLimit:Int = 1)
    {
		super();
		manager = new LoaderManager(maxConnectionLimit);
		manager.onCompleteCallback = function () { dispatchEvent(new Event(Event.COMPLETE)); }
    }
	
	/**
	 * Adds a new loader with id and path.
	 * @param	loader
	 */
	public function addLoader(loader:BaseLoader) {
		manager.addLoader(loader);
	}
	
	/**
	 * If the loader exists, begins loading data.
	 * Dispatches Event.COMPLETE when file is loaded, or fails to load.
	 * @param	file	
	 */
	public function loadFile(id:String):Bool {
		return manager.loadList([id]);
	}
	/**
	 * Loads multiple files, must haxe been added loader for each file id.
	 * Dispatches Event.COMPLETE when all files finish loading.
	 * @param	list
	 */
	public function loadList(list:Array<String>):Bool {
		return manager.loadList(list);
	}
	
	/**
	 * Unloads list of loaders.
	 * Dispose frees the memory used by the loaded asset.
	 * @param	list
	 * @param	dispose		Disposes loaded assets.
	 */
	public function unloadList(list:Array<String>, dispose:Bool = true) {
		manager.unloadList(list, dispose);
	}
	
	/**
	 * Gets the loader responsible for an asset.
	 * If it is not found returns null.
	 * @param	id		The id of the asset.
	 * @return			Loader or null.
	 */
	public function findLoader(id:String):BaseLoader {
		return(manager.findLoader(id));
	}
	
	/**
	 * Gets untyped loaded asset with matching id. 
	 * If it is not found returns null.
	 * @param  id	The asset id.
	 * @return		Loaded asset.
	 */
	public function getAsset(id:String):Dynamic {
		var loader = manager.findLoader(id);
		if (loader != null && loader.data != null) 
		{
			return loader.data;
		}
        return null;
	}
	
	/**
	 * Gets the status of the data loader with matching id.
	 * @param	id	The loader id (same as asset id).
	 * @return		Loader status.
	 */
	public function getStatus(id:String):LoaderStatus {
		var loader = manager.findLoader(id);
		if (loader != null) 
		{
			return loader.status;
		}
		return null;
	}
	
	/**
	 * Gets loaded asset with matching id as BitmapData.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getBitmapData(id:String):BitmapData
    {
        var loader = manager.findLoader(id);
		if (loader != null && loader.data != null) 
		{
			if (Std.is(loader.data, BitmapData)) 
			{
				return loader.data;
			}
		}
        return null;
    }

	/**
	 * Gets loaded asset with matching id as Text.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getText(id:String):String
    {
         var loader = manager.findLoader(id);
		if (loader != null && loader.data != null) 
		{
			if (Std.is(loader.data, String))
			{
				return loader.data;
			}
		}
        return null;
    }
	
	/**
	 * Gets loaded asset with matching id as list of texture names.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getTextureList(id:String):Array<String>
    {
        var loader = manager.findLoader(id);
		if (loader != null && loader.data != null)
		{
			if (Std.is(loader.data, Array))
			{
				return loader.data;
			}
		}
        return null;
    }
	
	/**
	 * Gets loaded asset with matching id as ByteArray.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getByteArray(id:String):ByteArray
    {
        var loader = manager.findLoader(id);
		if (loader != null && loader.data != null)
		{
			if (Std.is(loader.data, ByteArray))
			{
				return loader.data;
			}
		}
        return null;
    }
	
	/**
	 * Gets loaded asset with matching id as Sound.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
	public function getSound(id:String):Sound
	{
		var loader = manager.findLoader(id);
		if (loader != null && loader.data != null)
		{
			if (Std.is(loader.data, Sound))
			{
				return loader.data;
			}
		}
        return null;
	}
	
	/**
	 * Returns loaded asset type.
	 * If it doesnt exist returns null.
	 * @param	id	The asset id.
	 * @return		Asset type.
	 */
	public function getAssetType(id:String):AssetType {
		var loader = manager.findLoader(id);
		if (loader != null) 
		{
			return loader.type;
		}
		return null;
	}

}