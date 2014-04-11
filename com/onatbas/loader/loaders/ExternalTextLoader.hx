package com.onatbas.loader.loaders;

import com.onatbas.loader.event.LoaderEvent;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.net.URLLoader;
import flash.net.URLRequest;

import com.onatbas.loader.ExternalDeliverable;
import com.onatbas.loader.ExternalDeliverableType;

class ExternalTextLoader implements IExternalLoader<String>
{
    public var id(default, null):String;
    private var request:URLRequest;

    private var loader:URLLoader;
    private var dispatcher:EventDispatcher;

    public var ready(default, null):Bool;

    public function new(id:String, textUrl:String)
    {
        this.id = id;
        this.request = new URLRequest(textUrl);

        dispatcher = new EventDispatcher();

        this.loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, handleComplete);

    }

    private function handleComplete(e:Event):Void
    {
        dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }

    public function start():Void
    {
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

    public function getText():String
    {
        var string:String = Std.string(loader.data);
        return string;
    }

    public function disposeAll():Void
    {
        loader.data = null;

        ready = false;
    }

    public function prepare():Void
    {
        ready = true;
    }

    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        if (deliverable.type != TEXT) return false;
        if (deliverable.id != id) return false;

        return true;
    }

    public function deliver(deliverable:ExternalDeliverable<String>):Void
    {
        deliverable.data = getText();
    }
}