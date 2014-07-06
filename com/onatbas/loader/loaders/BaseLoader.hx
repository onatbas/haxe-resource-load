package com.onatbas.loader.loaders;
import flash.display.BitmapData;
import flash.net.URLRequest;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.media.Sound;
import openfl.net.URLLoader;
import openfl.utils.ByteArray;


enum LoaderStatus {
	IDLE;
	FAILED;
	LOADING;
	LOADED;
}
/**
 * ...
 * @author TiagoLr
 */
class BaseLoader extends EventDispatcher {

	/** The default loader, set to null to use other loader instead */
    var loader:URLLoader;
	var request:String;
	
	public var type(default, null):AssetType;
	public var id(default, null):String;
	public var data(default, null):Dynamic;
	public var status(default, null):LoaderStatus;
	
	function new(id:String, request:String) {
		super();
		this.id = id;
		this.request = request;
		status = LoaderStatus.IDLE;
		type = AssetType.NOTYPE;
		loader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handleComplete);
	}
	
	function handleComplete(e:Event) {
		prepare();
		status = LoaderStatus.LOADED;
        dispatchEvent(new Event(Event.COMPLETE));
    }
	
	function prepare() {
		data = loader.data;
	}

	
	public function reset(dispose:Bool) {
		status = LoaderStatus.IDLE;
		data = null;
        loader.data = null;
	}
	
	public function start() {
		this.status = LoaderStatus.LOADING;
		loader.load(new URLRequest(request));
	}
	
}