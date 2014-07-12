package assets.manager.loaders;

import assets.manager.misc.LoaderStatus;
import assets.manager.misc.FileType;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import haxe.Timer;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.ErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;


class ImageLoader extends BaseLoader {
	var flashLoader:Loader;
	
    public function new(id:String) {
		super(id, FileType.IMAGE);
		#if ( flash || html5 )
		flashLoader = new Loader();
        flashLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
        flashLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFail);
		flashLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFail);
        #else
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        #end
    }
	
	override function processData() {
		#if (flash || html5)
		data = cast(flashLoader.content, Bitmap).bitmapData;
		#else
		data = BitmapData.loadFromBytes(loader.data);
		#end
	}
	
	override public function start() {
		status = LoaderStatus.LOADING;
		#if (flash || html5) 
		flashLoader.load(new URLRequest(id));
		#else 
		loader.load(new URLRequest(id));
		#end
	}

    override public function reset(dispose:Bool) {
		status = LoaderStatus.IDLE;
        if (data != null && dispose) {
			cast(data, BitmapData).dispose();
		}
		data = null;
    }
    
}