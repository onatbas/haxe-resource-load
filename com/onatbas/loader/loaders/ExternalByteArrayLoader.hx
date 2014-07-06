package com.onatbas.loader.loaders;

import flash.net.URLLoaderDataFormat;

class ExternalByteArrayLoader extends BaseExternalLoader
{
	public function new(id:String, url:String) {
		super(id, url);
		loader.dataFormat = URLLoaderDataFormat.BINARY;
    }
}