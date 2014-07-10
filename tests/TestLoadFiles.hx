package ;
import assets.manager.FileLoader;
import assets.manager.misc.FileInfo;
import assets.manager.misc.FileType;
import assets.manager.misc.LoaderStatus;
import async.tests.AsyncTestCase;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;

/**
 * Simple test case
 */
class TestLoadFiles extends AsyncTestCase
{	 
	private var loader:FileLoader;
	private var fileCounter:Int;
	
    public function new() {
        super();
    }
    
	override public function setup() {
		loader = new FileLoader(3);
		fileCounter = 0;
	}
	
	override public function tearDown() {
	}
	
	// tests loading from relative path
	public function testLoadRelativePath() {
		loader.onFileLoaded.addOnce(createAsync(onLoadRelativePathComplete));
		loader.loadFile("assets/t1.txt", FileType.TEXT);
	}
	
	function onLoadRelativePathComplete(e:Dynamic) {	
		var file:FileInfo = cast e;
		
		assertFile(file, "assets/t1.txt", LoaderStatus.LOADED, FileType.TEXT);
		assertTrue(Std.is(file.data, String));
	}
	
	#if (cpp || neko || php)
	/**
	 * tests loading from full path (flash causes error)
	 */
	public function testLoadFullPath() {
		loader.onFileLoaded.addOnce(createAsync(onLoadFullPath));
		loader.loadFile(Sys.getCwd() + "assets/t2.txt", FileType.TEXT);
	}
	
	function onLoadFullPath(e:Dynamic) {
		var file:FileInfo = cast e;
		
		assertFile(file, Sys.getCwd() + "assets/t2.txt", LoaderStatus.LOADED, FileType.TEXT);
		assertTrue(Std.is(file.data, String));
	}
	#end
	/**
	 * tests loading image file.
	 */
	public function testLoadPNG() {
		loader.queueFile("assets/i1.png", FileType.IMAGE);
		loader.queueFile("assets/i2.png", FileType.IMAGE);
		loader.queueFile("assets/i3.png", FileType.IMAGE);
		loader.queueFile("assets/i1.jpg", FileType.IMAGE);
		loader.queueFile("assets/i2.jpg", FileType.IMAGE);
		loader.queueFile("assets/i3.jpg", FileType.IMAGE);
		loader.onFilesLoaded.addOnce(createAsync(onLoadImage));
		loader.loadQueuedFiles();
	}
	
	function onLoadImage(e:Dynamic) {
		var files:Array<FileInfo> = cast e;
		
		assertTrue(files.length == 6);
		
		for (file in files) {
			assertFile(file, null, LoaderStatus.LOADED, FileType.IMAGE);
			assertTrue(Std.is(file.data, BitmapData));
			var data:BitmapData = file.data;
			assertTrue(data.width == 50);
			assertTrue(data.height == 50);
			var corner = data.getPixel(0, 0);
			assertTrue(corner > 0x000000); // color is not black.
			assertTrue(corner < 0xffffff); // color is not white.
		}
	}
	
	/**
	 * Tests loading text file.
	 */
	public function testLoadText() {
		loader.onFileLoaded.addOnce(createAsync(onLoadText));
		loader.loadFile("assets/t3.txt", FileType.TEXT);
	}
	
	function onLoadText(e:Dynamic) {
		var file:FileInfo = cast e;
		
		assertFile(file, "assets/t3.txt", LoaderStatus.LOADED, FileType.TEXT);
		assertTrue(Std.is(file.data, String));
		assertTrue(file.data == "text3");
	}
	
	/**
	 * Tests loading binary file.
	 */
	public function testLoadBinary() {
		loader.onFileLoaded.addOnce(createAsync(onLoadBinary));
		loader.loadFile("assets/t1.txt", FileType.BINARY);
	}
	
	function onLoadBinary(e:Dynamic ) {
		var file:FileInfo = cast e;
		
		assertFile(file, "assets/t1.txt", LoaderStatus.LOADED, FileType.BINARY);
		assertTrue(Std.is(file.data, ByteArray));
		assertTrue(Std.string(cast(file.data, ByteArray)) == "text1");
	}
	
	/**
	 * Tests loading sound file.
	 */
	public function testLoadSound() {
		loader.onFileLoaded.addOnce(createAsync(onLoadSound));
		loader.loadFile("assets/sine.ogg", FileType.SOUND);
	}
	
	function onLoadSound(e:Dynamic) {
		var file:FileInfo = cast e;
		
		assertFile(file, "assets/sine.ogg", LoaderStatus.LOADED, FileType.SOUND);
		assertTrue(Std.is(file.data, Sound));
		var sound:Sound = file.data;
		assertTrue(sound.bytesTotal > 0);
	}
	
	/**
	 * Tests queuing and loading files in varied ways.
	 */
	public function testQueueFiles() {
		loader.queueFile("assets/t1.txt", FileType.TEXT);
		loader.queueFile("assets/t2.txt", FileType.TEXT);
		loader.queueFile("assets/t3.txt", FileType.TEXT);
		
		// tests loading a single file.
		loader.onFileLoaded.addOnce(createAsync(onQueueFiles1));
		loader.loadFile("assets/t1.txt", FileType.TEXT);
	} 
	
	function onQueueFiles1(e:Dynamic) {
		var file:FileInfo = cast e;
		assertFile(file, "assets/t1.txt", LoaderStatus.LOADED);
		
		// tests loading previous queued files.
		assertTrue(loader.queuedFiles.length == 3);
		loader.onFilesLoaded.addOnce(createAsync(onQueueFiles2));
		loader.loadQueuedFiles();
	}
	
	function onQueueFiles2(e:Dynamic) {
		var files:Array<FileInfo> = cast e;
		assertTrue(files.length == 3);
		
		assertTrue(loader.queuedFiles.length == 0);
		loader.onFilesLoaded.addOnce(createAsync(onQueueFiles3));
		
		// should not dispatch any event.
		loader.loadQueuedFiles();
		
		// reload files in same test just in case.
		loader.queueFile("assets/t1.txt", FileType.TEXT);
		loader.queueFile("assets/t2.txt", FileType.TEXT);
		loader.queueFile("assets/t3.txt", FileType.TEXT);
		
		loader.onFileLoaded.add(function (_) { fileCounter++; } );
		loader.loadQueuedFiles();
	}
	
	function onQueueFiles3(e:Dynamic) {
		var files:Array<FileInfo> = cast e;
		
		if (files.length == 0) {
			throw "Received filesloaded event loading nothing";
		}
		
		assertTrue(fileCounter == 3); // asserts onFileLoaded using counter
		assertTrue(files.length == 3);
	}
	
	/**
	 * Tests different types of errors during file load.
	 */
	public function testLoadError() {
		// Test loading file that does not exist
		loader.queueFile("assets/noFile", FileType.TEXT);
		loader.queueFile("assets/noFile2", FileType.TEXT);
		loader.queueFile("assets/noFile3", FileType.TEXT);
		
		loader.onFileLoaded.add(function (_) { throw "non existing file dispatched load complete"; });
		loader.onFilesLoaded.add(function (_) { throw "non existing file dispatched load complete"; });
		loader.onFileLoadError.add(function (_) { fileCounter++; } );
		loader.onFilesLoadError.addOnce(createAsync(onLoadError));
		loader.loadQueuedFiles();
		assertTrue(true);
	}
	
	function onLoadError(e:Dynamic) {
		var files:Array<FileInfo> = cast e;
		
		assertTrue(fileCounter == 3);
		assertTrue(files.length == 3);
		
		for (file in files) {
			assertFile(file, null, LoaderStatus.ERROR, FileType.TEXT);
		}
	}
	
	/**
	 * Tests removing files.
	 */
	//public function testRemoveFile() {
		// TODO
		//assertTrue(true);
	//}
	
	//---------------------------------------------------------------------------------
	// AUX 
	//---------------------------------------------------------------------------------
	function assertFile(file:FileInfo, id:String = null, status:LoaderStatus = null, type:FileType = null) {
		assertTrue(file != null);
		if (id != null) {
			assertTrue(file.id == id);
		}
		if (status != null) {
			assertTrue(file.status == status);
		}
		if (type != null) {
			assertTrue(file.type == type);
		}
		if (file.status == LoaderStatus.LOADED) {
			assertTrue(file.data != null);
		} else 
		if (file.status == LoaderStatus.ERROR) {
			assertTrue(file.data == null);
		}
	}
	
}