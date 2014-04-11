package com.onatbas.loader;

import com.onatbas.loader.event.LoaderEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import com.onatbas.loader.loaders.IExternalLoader;
import com.onatbas.loader.ExternalDeliverable;

class ExternalAssetGroup<T> implements IExternalLoader<T>
{
    private var manager:BaseLoaderManager<T>;
    private var dispatcher:EventDispatcher;
    public var id(default, null):String;
    public var ready(default, null):Bool;

    public function new(id:String, maxConnectionLimit:Int = 1)
    {
        manager = new BaseLoaderManager<T>(maxConnectionLimit);
        this.id = id;
        dispatcher = new EventDispatcher();

        manager.addEventListener(ExternalAssetLoaderEvent.LIST_LOAD_COMPLETE, handleComplete);
    }

    public function addListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.removeEventListener(type, listener);
    }

    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        if (!ready)
        {
            return false;
        }
        if (manager.findAgent(deliverable) != null)
        {
            return true;

        }
        return false;
    }

    public function deliver(deliverable:ExternalDeliverable<T>):Void
    {
        if (!ready) return;
        manager.findAgent(deliverable).deliver(deliverable);
    }

    public function start():Void
    {
        var keys:Iterator<String> = manager.loaders.keys();
        var ids:Array<String> = new Array<String>();
        var key:String;
        for (key in keys)
            ids.push(key);
        manager.loadList(ids);
    }

    public function prepare():Void
    {
        var loader:IExternalLoader<T>;
        for (loader in manager.loaders)
        {
            loader.prepare();
        }

    }

    public function disposeAll():Void
    {
        var loader:IExternalLoader<T>;
        for (loader in manager.loaders)
        {
            loader.disposeAll();
        }

        ready = false;
    }

    private function handleComplete(e:ExternalAssetLoaderEvent):Void
    {
        ready = true;
        dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }

}