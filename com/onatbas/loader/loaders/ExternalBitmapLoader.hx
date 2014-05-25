package com.onatbas.loader.loaders;

import flash.events.ProgressEvent;
import flash.events.HTTPStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.events.IOErrorEvent;
import com.onatbas.loader.event.LoaderEvent;
import flash.net.URLLoaderDataFormat;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.net.URLLoader;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.display.Loader;

import flash.events.Event;

import flash.display.Bitmap;
import flash.display.BitmapData;

import com.onatbas.loader.ExternalDeliverable;
import com.onatbas.loader.ExternalDeliverableType;

class ExternalBitmapLoader implements IExternalLoader<BitmapData>
{
    public var id(default, null):String;

    #if (flash || html5 )
    private var urlLoader:Loader;
    #else
    private var urlLoader:URLLoader;
    #end

    private var eventDispatcher:EventDispatcher;

    private var _bitmapData:BitmapData;
    private var request:URLRequest;
    public var ready(default, null):Bool;

    public function new(id:String, bitmapUrl:String)
    {
        this.id = id;
        eventDispatcher = new EventDispatcher();
        this.request = new URLRequest(bitmapUrl);


        #if (flash || html5 )
        urlLoader = new Loader();
        this.urlLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
        #else
        urlLoader = new URLLoader();
        this.urlLoader.addEventListener(Event.COMPLETE, handleComplete);

        #end

    }

    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        if (deliverable.type != BITMAP) return false;
        if (this.id != deliverable.id) return false;
        return true;
    }

    public function deliver(deliverable:ExternalDeliverable<BitmapData>):Void
    {
        deliverable.data = getBitmapData();
    }

    public function getBitmapData():BitmapData
    {
        return _bitmapData;
    }

    public function prepare():Void
    {
        #if (flash || html5 )
        _bitmapData = cast(urlLoader.content, Bitmap).bitmapData;

        #else
        _bitmapData = BitmapData.loadFromBytes(urlLoader.data);
        #end
        ready = true;
    }

    public function start():Void
    {
        #if (flash || html5 )
        #else
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        #end
        urlLoader.load(request);
    }

    public function handleComplete(e:Event):Void
    {

        eventDispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }

    public function disposeAll():Void
    {
    ready = false;
        if (_bitmapData != null)
        _bitmapData.dispose();
        _bitmapData = null;
    }

    public function addListener(type:String, listener:Dynamic -> Void):Void
    {
        eventDispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void):Void
    {
        eventDispatcher.removeEventListener(type, listener);
    }
}