package com.onatbas.akaloader.loaders ;

import com.onatbas.akaloader.loaders.BaseLoader;
import com.onatbas.akaloader.misc.LoaderStatus;
import flash.events.Event;
import flash.events.EventDispatcher;


class LoaderManager extends EventDispatcher
{
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
        for (id in list)
        {
			var l = findLoader(id);
            if (l != null && l.status != LoaderStatus.LOADING && l.status != LoaderStatus.READY)
            {
                loadQueue.push(l);
				l.addEventListener(Event.COMPLETE, handleLoaderComplete);
				l.prepare();
            }
			checkLoadSequence();
        }
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
		if (loader != null && loader.status != LoaderStatus.LOADING) {
			loader.reset(dispose);
			loaders.remove(id);
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
	
	function handleLoaderComplete(e:Event):Void
    {
        var loader:BaseLoader = cast e.currentTarget;
        loader.removeEventListener(Event.COMPLETE, handleLoaderComplete);
		
		activeLoads--;
		loadedFiles.push(loader.id);
        checkLoadSequence();
    }

    function onLoadListComplete():Void
    {
        dispatchEvent(new Event(Event.COMPLETE));
		loadQueue = new Array<BaseLoader>();
		loadedFiles = new Array<String>();
    }
}