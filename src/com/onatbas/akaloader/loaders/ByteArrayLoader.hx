package com.onatbas.akaloader.loaders ;

import flash.net.URLLoaderDataFormat;

class ByteArrayLoader extends BaseLoader
{
	public function new(id:String, url:String) {
		super(id, url);
		this.type = AssetType.BYTES;
		loader.dataFormat = URLLoaderDataFormat.BINARY;
    }
}