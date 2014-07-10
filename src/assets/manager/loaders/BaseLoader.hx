package assets.manager.loaders ;
import assets.manager.loaders.BaseLoader;
import haxe.Timer;
import openfl.display.BitmapData;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.media.Sound;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import assets.manager.misc.FileType;
import assets.manager.misc.LoaderStatus;

/**
 * ...
 * @author TiagoLr
 */
class BaseLoader extends EventDispatcher {

	/** The default loader, set to null to use other loader instead */
    var loader:URLLoader;
	
	public var type(default, null):FileType;
	public var id(default, null):String;
	public var data(default, null):Dynamic;
	public var status(default, null):LoaderStatus;
	public var error(default, null):String;
	
	function new(id:String, type:FileType) {
		super();
		this.id = id;
		this.data = null;
		this.type = type;
		status = LoaderStatus.IDLE;
		loader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handleComplete);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFail);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFail);
	}
	
	function handleComplete(e:Event) {
		processData();
		status = LoaderStatus.LOADED;
        dispatchEvent(new Event(Event.COMPLETE));
    }
	
	function onLoadFail(e:ErrorEvent) {
		data = null;
		error = e.toString();
		status = LoaderStatus.ERROR;
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	function processData() {
		data = loader.data;
	}
	
	public function prepare() {
		status = LoaderStatus.READY;
	}
	
	public function reset(dispose:Bool) {
		status = LoaderStatus.IDLE;
		data = null;
        loader.data = null;
	}
	
	public function start() {
		this.status = LoaderStatus.LOADING;
		loader.load(new URLRequest(id));
	}
	
}