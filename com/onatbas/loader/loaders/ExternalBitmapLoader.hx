package com.onatbas.loader.loaders;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;


class ExternalBitmapLoader extends BaseExternalLoader
{
	var flashLoader:Loader;
	
    public function new(id:String, url:String)
    {
		super(id, url);
		this.type = ExternalDeliverableType.BITMAP;
		#if ( flash || html5 )
		flashLoader = new Loader();
        flashLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
        #else
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        #end
    }
	
	override function prepare() {
		#if (flash || html5)
		return data cast(data, Bitmap).bitmapData;
		#else
		return BitmapData.loadFromBytes(data);
		#end
	}
	
	override public function start() 
	{
		#if (flash || html5) 
		flashLoader.load(new URLRequest(request));
		#else 
		if (loader != null) {
			loader.load(new URLRequest(request));
		}
		#end
	}

    override public function disposeAll()
    {
		status = LoaderStatus.IDLE;
        if (data != null) {
			cast(data, BitmapData).dispose();
			data = null;
		}
    }
    
}