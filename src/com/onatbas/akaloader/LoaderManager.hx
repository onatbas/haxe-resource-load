package com.onatbas.akaloader ;

import com.onatbas.akaloader.loaders.BaseLoader;
import flash.events.Event;
import flash.events.EventDispatcher;


class LoaderManager extends EventDispatcher
{
	public var onCompleteCallback:Void->Void;
    public var loaders(default, null):Map<String, BaseLoader>;
    private var loadQueue:Array<BaseLoader>;
    public var maxConnectionLimit(default, null):Int;

    public function new(maxConnectionLimit:Int = 1)
    {
        this.maxConnectionLimit = maxConnectionLimit;
        super();
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
	
    public function loadList(list:Array<String>):Bool
    {
        var id:String;
        for (id in list)
        {
			var l = findLoader(id);
            if (l != null && l.status != LoaderStatus.LOADING)
            {
                loadQueue.push(l);
				l.addEventListener(Event.COMPLETE, handleLoaderComplete);
				l.start();
            }

        }
        checkLoadSequence();
		return true;
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
            if (loader.status == LoaderStatus.LOADING)
            {
                isAllComplete = false;
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
        checkLoadSequence();
    }

    function onLoadListComplete():Void
    {
		loadQueue = new Array<BaseLoader>();
		onCompleteCallback();
        dispatchEvent(new Event(Event.COMPLETE));
    }
}