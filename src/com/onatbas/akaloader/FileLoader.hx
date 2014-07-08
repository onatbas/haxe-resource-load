package com.onatbas.akaloader ;

import com.onatbas.akaloader.loaders.BitmapLoader;
import com.onatbas.akaloader.loaders.ByteArrayLoader;
import com.onatbas.akaloader.loaders.LoaderManager;
import com.onatbas.akaloader.loaders.SoundLoader;
import com.onatbas.akaloader.loaders.TextLoader;
import com.onatbas.akaloader.misc.File;
import com.onatbas.akaloader.misc.FileType;
import msignal.Signal.Signal1;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
 * Client API class.
 */
class FileLoader
{
	/** Manager instance used to load files */
	public var manager:LoaderManager;
	/** Dispatched when queued files (or a single file) are loaded. */
	public var onFilesLoaded:Signal1<Array<File>>;
	
	var queuedFiles:Array<String>;
	
    public function new(maxConnectionLimit:Int = 3) {
		onFilesLoaded = new Signal1<Array<File>>();
		queuedFiles = new Array<String>();
		
		manager = new LoaderManager(maxConnectionLimit);
		manager.addEventListener(Event.COMPLETE, 
			function (_) { 
			onFilesLoaded.dispatch(createAssetList(manager.loadedFiles)); 
		});
    }
	
	/**
	 * Loads file
	 * @param	id	 	The file relative or full path or URL.
	 * @param 	type	The type of asset.
	 */
	public function loadFile(id:String, type:FileType) {
		if (!exists(id)) {
			addLoader(id, type);
		}
		manager.loadList([id]);
	}
	
	/**
	 * Prepares file to be load but do not start loading it already.
	 * @param	id		The file relative or full path or URL.
	 * @param	type
	 * @return
	 */
	public function queueFile(id:String, type:FileType) {
		if (!exists(id)) {
			addLoader(id, type);
		}
		if (queuedFiles.indexOf(id) == -1) {
			queuedFiles.push(id);
		}
	}
	
	/**
	 * Loads all queued files.
	 */
	public function loadQueuedFiles() {
		manager.loadList(queuedFiles);
		queuedFiles = new Array<String>();
	}
	
	/**
	 * 
	 * @param	id
	 * @param	dispose
	 * @return
	 */
	public function removeFile(id:String, dispose:Bool = false):Bool {
		return manager.remove(id, dispose);
	}
	
	/**
	 * Returns loaded assetwith information about file id, data, loader status and data type.
	 * Returns null if it has not been loaded or queued yet.
	 * @param	id		The id of the asset (fullpath)
	 * @return			The	asset 
	 */
	public function getLoadedFile(id:String):File {
		var loader = manager.findLoader(id);
		if (loader == null) return null;
		
		var asset:File = {
			id:id,
			type:loader.type,
			status:loader.status,
			data:loader.data
		}
		
		return asset;
	}
	
	/**
	 * Checks if file id has been registered.
	 * @param	file
	 * @return
	 */
	public function exists(file:String):Bool {
		var loader = manager.findLoader(file);
		return loader != null;
	}
	
	/**
	 * Lists loaded files/assets.
	 * @param	type	(Optional) only files of this type will be shown.
	 * @return			List of asset ids.
	 */
	public function list(type:FileType = null):Array<String> {
		var result = new Array<String>();
		for (loader in manager.loaders) {
			if (loader.type == type || type == null) {
				result.push(loader.id);
			}
		}
		return result;
	}
	
	//---------------------------------------------------------------------------------
	//  PRIVATE
	//---------------------------------------------------------------------------------
	function addLoader(id, type) {
		switch (type) {
			case BITMAP: manager.addLoader(new BitmapLoader(id));
			case TEXT:	 manager.addLoader(new TextLoader(id));
			case BYTES:	 manager.addLoader(new ByteArrayLoader(id));
			case SOUND:	 manager.addLoader(new SoundLoader(id));
		}
	}
	
	function createAssetList(list:Array<String>):Array<File> {
		var assets:Array<File> = new Array<File>();
		
		for (el in list) {
			assets.push(getLoadedFile(el));
		}
		
		return assets;
	}

}