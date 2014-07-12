package assets.manager;

import assets.manager.loaders.ImageLoader;
import assets.manager.loaders.BinaryLoader;
import assets.manager.loaders.LoaderManager;
import assets.manager.loaders.SoundLoader;
import assets.manager.loaders.TextLoader;
import assets.manager.misc.FileInfo;
import assets.manager.misc.FileType;
import assets.manager.misc.LoaderStatus;
import msignal.Signal.Signal1;
import openfl.events.Event;

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
	/** Dispatched when files fail to load and there are no more files to load. */
	public var onFilesLoadError:Signal1<Array<FileInfo>>;
	/** Dispatched every time a file is loaded. */
	public var onFileLoaded:Signal1<FileInfo>;
	/** Dispatched every time a file fails to load. */
	public var onFileLoadError:Signal1<FileInfo>;
	/** List of queued files, read only. */
	public var queuedFiles(default, null):Array<String>;
	
	
    public function new(maxConnectionLimit:Int = 3) {
		onFilesLoaded = new Signal1<Array<FileInfo>>();
		onFilesLoadError = new Signal1<Array<FileInfo>>();
		onFileLoaded = new Signal1<FileInfo>();
		onFileLoadError = new Signal1<FileInfo>();
		queuedFiles = new Array<String>();
		
		manager = new LoaderManager(maxConnectionLimit);
		manager.addEventListener(Event.COMPLETE, onManagerComplete);
		manager.addEventListener(LoaderManager.EVT_FILE_LOAD_COMPLETE, onManagerFileComplete);
    }
	
	/**
	 * Loads file
	 * @param	id	 	The file relative or full path or URL.
	 * @param 	type	The type of data to be loaded.
	 * @param	timeout	Time (ms) before request timeout.
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
	 * @param	type	The type of data to be loaded.
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
		
		if (queuedFiles.length == 0) {
			return;
		}
		
		var qf = queuedFiles.copy();
		queuedFiles = new Array<String>(); // reset queued files before starting operation.
		manager.loadList(qf);
	}
	
	/**
	 * Removes File from loading lists, only removes if it is not loading.
	 * @param	id			The file id.
	 * @param	dispose		Purges loaded data, causes bitmaps to be freed.
	 *
	 * @return	True if operation succeeds, fail if couldn't remove file.
	 */
	public function removeFile(id:String, dispose:Bool = false):Bool {
		if (manager.remove(id, dispose)) { // remove file loader
			
			// also remove file from queued list.
			if (queuedFiles.indexOf(id) != -1) {
				queuedFiles.remove(id);
			}
			
			return true;
		}
		return false;
	}
	
	/**
	 * Returns loaded assetwith information about file id, data, loader status and data type.
	 * Returns null if it has not been loaded or queued yet.
	 * @param	id		The id of the asset (fullpath)
	 * @return	The	asset 
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
	
	//---------------------------------------------------------------------------------
	//  PRIVATE
	//---------------------------------------------------------------------------------
	function addLoader(id, type) {
		switch (type) {
			case IMAGE: manager.addLoader(new ImageLoader(id));
			case TEXT:	 manager.addLoader(new TextLoader(id));
			case BINARY:	 manager.addLoader(new BinaryLoader(id));
			case SOUND:	 manager.addLoader(new SoundLoader(id));
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
		
		var loadedCompl = loadedFiles.filter( function (f:FileInfo) { return f.status == LoaderStatus.LOADED; } );
		var loadedError = loadedFiles.filter( function (f:FileInfo) { return f.status == LoaderStatus.ERROR; } );
		
		if (loadedCompl.length > 0) {
			onFilesLoaded.dispatch(loadedCompl);
		}
		if (loadedError.length > 0) {
			onFilesLoadError.dispatch(loadedError);
		}
	}
	
	// dispatches event for loaded file.
	private function onManagerFileComplete(e:Event):Void {
		var fileId = manager.loadedFiles[manager.loadedFiles.length - 1];
		var file = getLoadedFile(fileId);
		
		if (file.status == LoaderStatus.LOADED) {
			onFileLoaded.dispatch(file);
		} else 
		if (file.status == LoaderStatus.ERROR) {
			onFileLoadError.dispatch(file);
		} else {
			throw "Error unknown file loaded status";
		}
	}

}