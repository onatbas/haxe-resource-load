package;
import async.tests.AsyncTestCase;
#if (cpp || neko || php)
import assets.manager.FileLoader;
import assets.manager.FileSaver;
import assets.manager.misc.FileType;
import flash.display.BitmapData;
import sys.FileSystem;
import assets.manager.misc.FileInfo;
#end
import openfl.utils.ByteArray;

/**
 * ...
 * @author TiagoLr
 */
class TestSaveFiles extends AsyncTestCase {
	#if (cpp || neko || php)

	var loader:FileLoader;
	
	override public function setup() {
		loader = new FileLoader(3);
	}
	
	override public function tearDown() {
		if (FileSystem.exists(FileSystem.fullPath("testFile"))) {
			FileSystem.deleteFile(FileSystem.fullPath("testFile"));
		}
	}
	
	/**
	 * Test saving PNG
	 */
	public function testSavePNG() {
		var data:BitmapData = new BitmapData(20, 20, true, 0xFFFF0000);
		FileSaver.saveAsPng("testFile", data);
		loader.onFileLoaded.addOnce(createAsync(onPNGLoaded));
		loader.loadFile("testFile", FileType.IMAGE);
	}
	
	function onPNGLoaded(o:Dynamic) {
		var file:FileInfo = cast o;
		var data = cast(file.data, BitmapData);
		assertTrue(data.getPixel(0, 0) == 0xFF0000); // assert red color corner
	}
	
	/**
	 * Test saving text
	 */
	public function testSaveText() {
		var data:String = "test string";
		FileSaver.saveAsText("testFile", data);
		loader.onFileLoaded.addOnce(createAsync(onTextLoaded));
		loader.loadFile("testFile", FileType.TEXT);
	}
	
	function onTextLoaded(o:Dynamic) {
		var file:FileInfo = cast o;
		var data = cast(file.data, String);
		assertTrue(data == "test string");
	}
	
	/**
	 * Test saving bytes
	 */
	public function testSaveBytes() {
		var data:ByteArray = new ByteArray();
		data.writeUTFBytes("test string");
		FileSaver.saveAsBytes("testFile", data);
		loader.onFileLoaded.addOnce(createAsync(onBytesLoaded));
		loader.loadFile("testFile", FileType.BINARY);
	}
	
	function onBytesLoaded(o:Dynamic) {
		var file:FileInfo = cast o;
		var data = cast(file.data, ByteArray);
		assertTrue(Std.string(data) == "test string"); // assert red color corner
	}
	
	#end	
	
	
}