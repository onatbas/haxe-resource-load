package com.onatbas.loader.loaders;

import com.onatbas.loader.event.LoaderEvent;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
class ExternalByteArrayLoader implements IExternalLoader<ByteArray>
{

    /* IExternalLoader Implementation */
    public var id(default, null):String;
    public var ready(default, null):Bool;

    private var loader:URLLoader;
    private var request:URLRequest;

    public function start():Void
    {
        if (loader == null)
        {
            loader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, handleComplete);
        }

        loader.load(request);
    }

    public function addListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.removeEventListener(type, listener);
    }

    public function disposeAll():Void
    {
        if (loader != null)
        {
            loader.data = null;
        }
        this.data = null;
        ready = false;
    }

    public function prepare():Void
    {
        ready = true;
        this.data = loader.data;
    }

    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        if (deliverable.id != id) return false;

        return true;
    }

    public function deliver(deliverable:ExternalDeliverable<ByteArray>):Void
    {
        deliverable.data = data;
    }

    /* IExternalLoader Implementation ends here. */


    public var data(default,null):ByteArray;

    private var dispatcher:EventDispatcher;

    public function new(id:String, url:String)
    {
        this.id = id;
        this.request = new URLRequest(url);
        dispatcher = new EventDispatcher();

    }


    /**
    * Informs the loader job is complete.
    * @e Event.COMPLETE
    * */
    private function handleComplete(e:Event):Void
    {
        dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }
}