package com.onatbas.loader.loaders;
import com.onatbas.loader.event.LoaderEvent;
import com.onatbas.loader.ExternalDeliverable;
import flash.display.BitmapData;
import flash.net.URLRequest;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.media.Sound;
import openfl.net.URLLoader;

/**
 * ...
 * @author TiagoLr
 */
class BaseExternalLoader {

	/** The default loader, set to null to use other loader instead */
    var loader:URLLoader;
	var eventDispatcher:EventDispatcher;
	var request:String;
	
	public var id(default, null):String;
	public var type(default, ExternalDeliverableType);
	public var data(default, null):Dynamic;
	public var status(default, null):LoaderStatus;
	
	public function new(id:String, request:String) {
		this.id = id;
		this.request = request;
        eventDispatcher = new EventDispatcher();
		status = LoaderStatus.IDLE;
		type = ExternalDeliverableType.NOTYPE;
		loader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handleComplete);
	}
	
	function handleComplete(e:Event) {
		prepare();
		status = LoaderStatus.LOADED;
        eventDispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }
	
	function prepare() {
		data = loader.data;
	}
	
	public function addListener(type:String, listener:Dynamic -> Void) {
        eventDispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void) {
        eventDispatcher.removeEventListener(type, listener);
    }
	
	public function disposeAll() {
		status = LoaderStatus.IDLE;
		data = null;
        loader.data = null;
	}
	
	public function start() {
		if (loader != null) {
			loader.load(new URLRequest(request));
		}
	}
	
	public function canDeliver(item:ExternalDeliverable<Dynamic>):Bool {
		if (deliverable.type != type) return false;
        if (this.id != deliverable.id) return false;
        return true;
	}
	
	public function deliver(deliverable:ExternalDeliverable<T>) {
		if (data != null) {
			switch (type) {
				case ExternalDeliverableType.NOTYPE: return data;
				case ExternalDeliverableType.BITMAP: return cast (data, BitmapData);
				case ExternalDeliverableType.SOUND: return cast (data, Sound);
				case ExternalDeliverableType.TEXT: return cast (data, String);
				case ExternalDeliverableType.TEXTURELIST: return cast (data, Array<String>); 
				case ExternalDeliverableType.ATLAS: return cast (data, Array<String>);
			}
		}
	}
	
}