package com.onatbas.akaloader ;
#if (cpp || neko || php)
import haxe.io.Bytes;
import sys.io.FileOutput;
import openfl.utils.ByteArray;
import flash.display.BitmapData;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
#end
/**
 * ...
 * @author TiagoLr
 */
class FileSaver {
	#if (cpp || neko || php)
	static inline var error:String = "Saver Error: ";
	
	/**
	 * Saves a png image file. 
	 * If file does not exist it will be created (including parent directories).
	 * @param	fullPath	The file path (absolute or relative) eg: "dir/file.ext"
	 * @param	data		The data to save to the file.
	 * @return				Operation failed or successful.
	 */
	static public function saveAsPng(fullPath:String, data:BitmapData):Bool {
		var path:Path = validate(fullPath, data);
		
		if (path == null) {
			return false;
		}
		
		try {
			var ba:ByteArray = data.encode('png');
			File.saveBytes(fullPath, cast (ba, Bytes));
		} catch(e:Dynamic) {
            trace ("Save Failed " + Std.string(e));
			return false;
        }
		
		return true;
	}
	
	/**
	 * Saves a text file. 
	 * If file does not exist it will be created (including parent directories).
	 * @param	fullPath	The file path (absolute or relative) eg: "dir/file.ext"
	 * @param	data		The data to save to the file.
	 * @return				Operation failed or successful.
	 */
	static public function saveAsText(fullPath:String, data:String):Bool {
		var path:Path = validate(fullPath, data);
		
		if (path == null) {
			return false;
		}
		
		try {
			File.saveContent(path.toString(), data);
        } catch(e:Dynamic) {
            trace ("Save Failed " + Std.string(e));
			return false;
        }
		
		return true;
	}
	
	/**
	 * Saves a binary file. 
	 * If file does not exist it will be created (including parent directories).
	 * @param	fullPath	The file path (absolute or relative) eg: "dir/file.ext"
	 * @param	data		The data to save to the file.
	 * @return				Operation failed or successful.
	 */
	static public function saveAsBytes(fullPath:String, data:ByteArray):Bool {
		var path:Path = validate(fullPath, data);
		
		if (path == null) {
			return false;
		}
		
		try {
			File.saveBytes(path.toString(), cast(data, Bytes));
        } catch(e:Dynamic) {
            trace ("Save Failed " + Std.string(e));
			return false;
        }
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	/**
	 * Verifies path and data, creates directory if it does not exist.
	 */
	static function validate(fullPath:String, data:Dynamic):Path {
		
		// verify path
		if (fullPath == null || fullPath == "") {
			trace(error + "invalid path");
			return null;
		}
		
		// verify data
		if (data == null) {
			trace(error + "invalid save data");
			return null;
		}
		
		// process path
		var path:Path = new Path(FileSystem.fullPath(fullPath));
		
		// if directory does not exist create file directory.
		if (!FileSystem.exists(path.dir)) {
			FileSystem.createDirectory(path.dir);
		}
		
		return path;
	}
	#end
}
