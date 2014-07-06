package com.onatbas.loader.loaders;
/**
 * @author Onat Baş
 * 11.02.2014
 *
 * */

import flash.media.Sound;


class SoundLoader extends BaseLoader
{
	
    public function new(id:String, url:String) {
		super(id, url);
		this.type = AssetType.SOUND;
    }

	override public function prepare():Void {
		var sound = new Sound();
		sound.loadCompressedDataFromByteArray(loader.data, loader.data.length);
		data = sound;
	}
	
}
