package com.onatbas.loader;

import com.onatbas.loader.event.LoaderEvent;
import com.onatbas.loader.loaders.BaseExternalLoader;
import flash.events.EventDispatcher;
import com.onatbas.loader.loaders.IExternalLoader;
import flash.events.Event;
import com.onatbas.loader.ExternalDeliverableType;
import com.onatbas.loader.LoadingStatusType;
import haxe.CallStack;

private typedef LoadStatusMap = Map<String, LoadingStatusType>;

class BaseLoaderManager<T> extends EventDispatcher
{
    public var loaders(default, null):Map<String, BaseExternalLoader>;
    private var loadQueue:LoadStatusMap;

    public var maxConnectionLimit(default, null):Int;

    public function new(maxConnectionLimit:Int = 1)
    {
        this.maxConnectionLimit = maxConnectionLimit;
        super();
        loaders = new Map<String, BaseExternalLoader>();
    }

    public function addLoader(loader:BaseExternalLoader):Void
    {
        var id:String = loader.id;
        if (loaders[id] != null)
        {
            trace("There is already a loader with id " + loader.id);
            return;
        }

        loaders[id] = loader;
    }
	
    public function loadList(list:Array<String>):Void
    {
        loadQueue = new Map<String, LoadingStatusType>();

        var id:String;
        for (id in list)
        {
            if (loadQueue[id] == null || (findAgentById(id) != null && !findAgentById(id).ready))
            {
                loadQueue[id] = INACTIVE;
            }

        }
        checkLoadSequence();
    }

    public function unloadList(list:Array<String>):Void
    {
        var loader:IExternalLoader<Dynamic>;
        var id:String;
        for (loader in loaders)
        {
            for (id in list)
            {
                if (loader.id == id) loader.disposeAll();
            }
        }
    }

    private function checkLoadSequence():Void
    {

        var isAllComplete:Bool = true;
        var activeCount:Int = 0;
        var id:String;
        var keys = loadQueue.keys();
        for (id in keys)
        {
            if (loadQueue[id] != COMPLETE)
            {
                isAllComplete = false;
            }

            if (activeCount >= maxConnectionLimit)
            {
                continue;
            }
            else if (loadQueue[id] == ACTIVE)
            {
                activeCount ++;
            }
            else if (loadQueue[id] == INACTIVE)
            {
                loaders[id].addListener(LoaderEvent.COMPLETE, handleLoaderComplete);
                loadQueue[id] = ACTIVE;
                loaders[id].start();
            }
        }

        if (isAllComplete)
        {
            onLoadListComplete();
        }
    }

    private function onLoadListComplete():Void
    {
        this.dispatchEvent(new ExternalAssetLoaderEvent(ExternalAssetLoaderEvent.LIST_LOAD_COMPLETE));
    }

    private function handleLoaderComplete(e:LoaderEvent):Void
    {
        var loader:IExternalLoader<T> = cast e.loader;
        loader.removeListener(LoaderEvent.COMPLETE, handleLoaderComplete);
        loader.prepare();

        var id:String = loader.id;
        loadQueue[id] = COMPLETE;
        checkLoadSequence();
    }

    public function findAgent(deliverable:ExternalDeliverable<Dynamic>):IExternalLoader<T>
    {
        var loader:IExternalLoader<T>;
        for (loader in loaders)
        {
            if (loader.ready && loader.canDeliver(deliverable))
            {
                return loader;
            }
        }

        return null;
    }

    public function findAgentById(id):IExternalLoader<T>
    {
        for (loader in loaders)
        {
            if (loader.id == id) return loader;
        }

        return null;
    }
}