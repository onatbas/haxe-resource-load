package com.onatbas.akaloader.loaders ;

import com.onatbas.akaloader.loaders.BaseLoader.LoaderStatus;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import openfl.display.Bitmap;
import openfl.display.BitmapData;


class BitmapLoader extends BaseLoader
{
	var flashLoader:Loader;
	
    public function new(id:String, url:String)
    {
		super(id, url);
		this.type = AssetType.BITMAP;
		#if ( flash || html5 )
		flashLoader = new Loader();
        flashLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
        #else
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        #end
    }
	
	override function prepare() {
		#if (flash || html5)
		data = cast(flashLoader.content, Bitmap).bitmapData;
		#else
		data = BitmapData.loadFromBytes(loader.data);
		#end
	}
	
	override public function start() 
	{
		status = LoaderStatus.LOADING;
		#if (flash || html5) 
		flashLoader.load(new URLRequest(request));
		#else 
		loader.load(new URLRequest(request));
		#end
	}

    override public function reset(dispose:Bool)
    {
		status = LoaderStatus.IDLE;
        if (data != null && dispose) {
			cast(data, BitmapData).dispose();
		}
		data = null;
    }
    
}