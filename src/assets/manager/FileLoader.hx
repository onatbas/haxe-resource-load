package assets.manager;

import assets.manager.loaders.BaseLoader;
import assets.manager.loaders.ImageLoader;
import assets.manager.loaders.BinaryLoader;
import assets.manager.loaders.LoaderManager;
import assets.manager.loaders.SoundLoader;
import assets.manager.loaders.TextLoader;
import assets.manager.misc.FileInfo;
import assets.manager.misc.FileType;
import assets.manager.misc.LoaderStatus;
import flash.display.BitmapData;
import msignal.Signal.Signal1;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.utils.ByteArray;

/**
 * File Load API class.
 * 
 * Use this class to load single or multiple files simultaneously. 
 * When files finish loading and there are no more queued, onFileLoaded signal is dispatched.
 * Files finish loading with LOADED or ERROR status
 */
class FileLoader
{
	/** Manager instance used to load files */
	public var manager:LoaderManager;
	/** Dispatched when files are loaded and there are no more files to load. */
	public var onFilesLoaded:Signal1<Array<FileInfo>>;
	/** Dispatched every time a file is loaded. */
	public var onFileLoaded:Signal1<FileInfo>;
	/** List of queued files, read only. */
	public var queuedFiles(default, null):Array<String>;
	
	/** List of callbacks specific to a file */
	var uniqueCallbacks:Map < String, FileInfo->Void >;
	
    public function new(maxConnectionLimit:Int = 3) {
		onFilesLoaded = new Signal1<Array<FileInfo>>();
		onFileLoaded = new Signal1<FileInfo>();
		uniqueCallbacks = new Map < String, FileInfo->Void > ();
		queuedFiles = new Array<String>();
		
		manager = new LoaderManager(maxConnectionLimit);
		manager.addEventListener(Event.COMPLETE, onManagerComplete);
		manager.addEventListener(LoaderManager.EVT_FILE_LOAD_COMPLETE, onManagerFileComplete);
    }
	//#################################################################################
	//  LOAD FILES
	//#################################################################################
	/**
	 * Loads a text file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function loadText(id:String, ?onComplete:FileInfo->Void = null) {
		loadFile(id, FileType.TEXT, onComplete);
	}
	/**
	 * Loads an image file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function loadImage(id:String, ?onComplete:FileInfo->Void = null) {
		loadFile(id, FileType.IMAGE, onComplete);
	}
	/**
	 * Loads a binary file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function loadBinary(id:String, ?onComplete:FileInfo->Void = null) {
		loadFile(id, FileType.BINARY, onComplete);
	}
	/**
	 * Loads a text file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function loadSound(id:String, ?onComplete:FileInfo->Void = null) {
		loadFile(id, FileType.SOUND, onComplete);
	}
	/**
	 * Loads file
	 * @param	id	 		The file relative or full path or URL.
	 * @param 	type		The type of data to be loaded.
	 * @param	onComplete	Callback when this file is loaded.
	 */
	public function loadFile(id:String, type:FileType, ?onComplete:FileInfo->Void = null) {
		
		if (onComplete != null) {
			if (!Reflect.isFunction(onComplete)) {
				trace("Assets loader error: 'onComplete' is not a function");
				return;
			}
			
			uniqueCallbacks[id] = onComplete;
		}
		
		if (!exists(id)) {
			addLoader(id, type);
		}
		
		manager.loadList([id]);
	}
	//#################################################################################
	//  QUEUE FILES
	//#################################################################################
	/**
	 * Queues a text file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function queueText(id:String, ?onComplete:FileInfo->Void = null) {
		queueFile(id, FileType.TEXT, onComplete);
	}
	/**
	 * Queues an image file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function queueImage(id:String, ?onComplete:FileInfo->Void = null) {
		queueFile(id, FileType.IMAGE, onComplete);
	}
	/**
	 * Queues a binary file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function queueBinary(id:String, ?onComplete:FileInfo->Void = null) {
		queueFile(id, FileType.BINARY, onComplete);
	}
	/**
	 * Queues a sound file.
	 * @param	id				The file relative or full path or url.
	 * @param	onComplete		Callback when this file is loaded.
	 */
	public function queueSound(id:String, ?onComplete:FileInfo->Void = null) {
		queueFile(id, FileType.SOUND, onComplete);
	}
	
	/**
	 * Prepares file to be load but do not start loading it already.
	 * @param	id			The file relative or full path or URL.
	 * @param	type		The type of data to be loaded.
	 * @param	onComplete	Callback when this file is loaded.
	 */
	public function queueFile(id:String, type:FileType, ?onComplete:FileInfo->Void = null) {
		
		if (onComplete != null) {
			if (!Reflect.isFunction(onComplete)) {
				trace("Assets loader error: 'onComplete' is not a function");
				return;
			}
			
			uniqueCallbacks[id] = onComplete;
		}
		
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
		
		if (queuedFiles.length == 0) {
			return;
		}
		
		var qf = queuedFiles.copy();
		queuedFiles = new Array<String>(); // reset queued files before starting operation.
		manager.loadList(qf);
	}
	//#################################################################################
	//  GET LOADED FILES
	//#################################################################################
	/**
	 * Type safe method to get loaded image.
	 * @param	id	The asset id or path.
	 * @return	The asset data or null if it can't be found.
	 */
	public function getLoadedImage(id:String):BitmapData {
		var loader = getLoadedFile(id);
		
		if (loader != null && loader.type == FileType.IMAGE) {
			return loader.data;
		}
		
		return null;
	}
	/**
	 * Type safe method to get loaded text.
	 * @param	id	The asset id or path.
	 * @return	The asset data or null if it can't be found.
	 */
	public function getLoadedText(id:String):String {
		var loader = getLoadedFile(id);
		
		if (loader != null && loader.type == FileType.TEXT) {
			return loader.data;
		}
		
		return null;
	}
	/**
	 * Type safe method to get loaded bytearray.
	 * @param	id	The asset id or path.
	 * @return	The asset data or null if it can't be found.
	 */
	public function getLoadedBytes(id:String):ByteArray {
		var loader = getLoadedFile(id);
		
		if (loader != null && loader.type == FileType.BINARY) {
			return loader.data;
		}
		
		return null;
	}
	/**
	 * Type safe method to get loaded sound.
	 * @param	id	The asset id or path.
	 * @return	The asset data or null if it can't be found.
	 */
	public function getLoadedSound(id:String):Sound {
		var loader = getLoadedFile(id);
		
		if (loader != null && loader.type == FileType.SOUND) {
			return loader.data;
		}
		
		return null;
	}
	/**
	 * Returns loaded asset with information about file id, data, loader status and data type.
	 * Returns null if it has not been loaded or queued yet.
	 * @param	id		The id of the asset (fullpath)
	 * @return	The	file info or null if it can't be found.
	 */
	public function getLoadedFile(id:String):FileInfo {
		var loader = manager.findLoader(id);
		if (loader == null) return null;
		
		var asset:FileInfo = {
			id:id,
			type:loader.type,
			status:loader.status,
			data:loader.data
		}
		
		return asset;
	}
	//#################################################################################
	//  OTHER
	//#################################################################################
	/**
	 * Checks if file id has been registered.
	 * @param	file
	 * @return
	 */
	public function exists(file:String):Bool {
		return manager.findLoader(file) != null;
	}
	
	/**
	 * Lists registered files (queued or loaded).
	 * @param	type	(Optional) only files of this type will be shown.
	 * @return	List of asset ids.
	 */
	public function listFiles(type:FileType = null):Array<String> {
		var result = new Array<String>();
		for (loader in manager.loaders) {
			if (loader.type == type || type == null) {
				result.push(loader.id);
			}
		}
		return result;
	}
	/**
	 * Removes File from loading lists, only removes if it is not loading.
	 * @param	id			The file id.
	 * @param	dispose		Purges loaded data, causes bitmaps to be freed.
	 * @return	True if operation succeeds, fail if couldn't remove file.
	 */
	public function removeFile(id:String, dispose:Bool = false):Bool {
		if (manager.remove(id, dispose)) { // remove file loader
			
			// also remove file from queued list.
			if (queuedFiles.indexOf(id) != -1) {
				queuedFiles.remove(id);
			}
			
			if (uniqueCallbacks.exists(id)) {
				uniqueCallbacks.remove(id);
			}
			
			return true;
		}
		return false;
	}
	//#################################################################################
	//  PRIVATE
	//#################################################################################
	function addLoader(id, type) {
		switch (type) {
			case IMAGE: manager.addLoader(new ImageLoader(id));
			case TEXT: manager.addLoader(new TextLoader(id));
			case BINARY: manager.addLoader(new BinaryLoader(id));
			case SOUND:	manager.addLoader(new SoundLoader(id));
		}
	}
	
	function createInfoList(list:Array<String>):Array<FileInfo> {
		var info:Array<FileInfo> = new Array<FileInfo>();
		
		for (entry in list) {
			info.push(getLoadedFile(entry));
		}
		
		return info;
	}
	
	// dispatches loaded files events.
	function onManagerComplete(e:Event):Void {
		var loadedFiles = createInfoList(manager.loadedFiles);
		
		if (loadedFiles.length > 0) {
			onFilesLoaded.dispatch(loadedFiles);
		}
	}
	
	// dispatches event for loaded file.
	private function onManagerFileComplete(e:Event):Void {
		var fileId = manager.loadedFiles[manager.loadedFiles.length - 1];
		var file = getLoadedFile(fileId);
		
		// calls specific callback if it exists when this file is loaded.
		if (uniqueCallbacks.exists(fileId)) {
			var cbk = uniqueCallbacks[fileId];
			uniqueCallbacks.remove(fileId);
			cbk(file);
		}
		
		// dispatches general signal when file is loaded.
		onFileLoaded.dispatch(file);
	}

}