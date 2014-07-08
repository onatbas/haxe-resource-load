package com.onatbas.akaloader.loaders ;

import flash.net.URLLoaderDataFormat;
import com.onatbas.akaloader.misc.FileType;

class ByteArrayLoader extends BaseLoader
{
	public function new(id:String) {
		super(id, FileType.BYTES);
		loader.dataFormat = URLLoaderDataFormat.BINARY;
    }
}