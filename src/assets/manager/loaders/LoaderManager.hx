package assets.manager.loaders ;

import assets.manager.loaders.BaseLoader;
import assets.manager.misc.LoaderStatus;
import flash.events.Event;
import flash.events.EventDispatcher;


class LoaderManager extends EventDispatcher
{
	// dispatched when file load finishes (with error or success).
	public static inline var EVT_FILE_LOAD_COMPLETE:String = "evtFileLoadComplete";
	
    var loadQueue:Array<BaseLoader>;
	var activeLoads:Int;
	
    public var loaders(default, null):Map<String, BaseLoader>;
	/** Max number of simultaneous loads */
    public var maxConnectionLimit(default, null):Int;
	/** Stores loaded files id, cleans up list after all queued files are loaded */
	public var loadedFiles(default, null):Array<String>; 
	

    public function new(maxConnectionLimit:Int = 1)
    {
        super();
        this.maxConnectionLimit = maxConnectionLimit;
		activeLoads = 0;
		loadedFiles = new Array<String>();
        loaders = new Map<String, BaseLoader>();
		loadQueue = new Array<BaseLoader>();
    }

    public function addLoader(loader:BaseLoader):Void
    {
        var id:String = loader.id;
        if (loaders[id] != null)
        {
            trace("There is already a loader with id " + loader.id);
            return;
        }

        loaders[id] = loader;
    }
	
    public function loadList(list:Array<String>)
    {	
		loadedFiles = new Array<String>();
        for (id in list)
        {
			var l = findLoader(id);
			
            if (l != null && l.status != LoaderStatus.LOADING && l.status != LoaderStatus.READY)
            {
                loadQueue.push(l);
				l.addEventListener(Event.COMPLETE, onFileLoaded);
				l.prepare();
            }
        }
		checkLoadSequence();
    }

    public function unloadList(list:Array<String>, dispose:Bool):Void
    {
        for (loader in loaders)
        {
            for (id in list)
            {
                if (loader.id == id) 
				{
					loader.reset(dispose);
				}
            }
        }
    }
	
	public function remove(id:String, dispose:Bool):Bool {
		var loader = findLoader(id);
		
		// if loader exists and has not begun loading process, remove it.
		if (loader != null && loader.status != LoaderStatus.LOADING && loader.status != LoaderStatus.READY) {
			loader.reset(dispose);
			loaders.remove(id);
			if (loadedFiles.indexOf(id) != -1) {
				loadedFiles.remove(id);
			}
			return true;
		}
		
		return false;
	}
	
	public function findLoader(id):BaseLoader
    {
        for (loader in loaders)
        {
            if (loader.id == id) return loader;
        }

        return null;
    }
	
    function checkLoadSequence():Void
    {
        var isAllComplete:Bool = true;
		
        for (loader in loadQueue)
        {
			if (loader.status == LoaderStatus.LOADING || loader.status == LoaderStatus.READY)
            {
                isAllComplete = false;
            }
			
			if (loader.status == LoaderStatus.READY && activeLoads < maxConnectionLimit) 
			{
				activeLoads++;
				loader.start();
			}
        }

        if (isAllComplete)
        {
            onLoadListComplete();
        }
    }
	
	function onFileLoaded(e:Event):Void
    {
        var loader:BaseLoader = cast e.currentTarget;
        loader.removeEventListener(Event.COMPLETE, onFileLoaded);
		activeLoads--;
		loadQueue.remove(loader);
		
		if (loadedFiles.indexOf(loader.id) != -1) {
			loadedFiles.remove(loader.id);
		}
		
		// places last loaded file at the end of the loaded files list.
		loadedFiles.push(loader.id); 
		dispatchEvent(new Event(EVT_FILE_LOAD_COMPLETE));
		
        checkLoadSequence();
    }

    function onLoadListComplete():Void
    {
        dispatchEvent(new Event(Event.COMPLETE));
    }
}