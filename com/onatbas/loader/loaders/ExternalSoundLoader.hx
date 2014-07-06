package com.onatbas.loader.loaders;
/**
 * @author Onat Baş
 * 11.02.2014
 *
 * */

import flash.media.Sound;


class ExternalSoundLoader extends BaseExternalLoader
{
	
    public function new(id:String, url:String) {
		super(id, url);
    }

    public function getSound():Sound
    {
        return sound;
    }

    public function prepare():Void
    {
        ready = true;
    }

    public function start():Void
    {
        loader.start();
    }

	override public function prepare():Void {
		var sound = new Sound();
		sound.loadCompressedDataFromByteArray(loader.data, loader.data.length);
		data = sound;
	}
	
}
