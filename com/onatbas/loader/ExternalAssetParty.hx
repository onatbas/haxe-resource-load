package com.onatbas.loader;

import com.onatbas.loader.loaders.ExternalSoundLoader;
import com.onatbas.loader.loaders.ExternalTextLoader;
import com.onatbas.loader.loaders.ExternalBitmapLoader;
import com.onatbas.loader.loaders.ExternalTextureAtlasLoader;

class ExternalAssetParty extends ExternalAssetGroup<Dynamic>
{

    public function addBitmap(id:String, url:String):Void
    {
        var loader:ExternalBitmapLoader = new ExternalBitmapLoader(id, url);
        manager.addLoader(loader);
    }

    public function addAtlas(id:String, bitmapUrl:String, xmlUrl:String, scale:Float = 1):Void
    {
        var loader:ExternalTextureAtlasLoader = new ExternalTextureAtlasLoader(id, xmlUrl, bitmapUrl, scale);
        manager.addLoader(loader);
    }

    public function addText(id:String, url:String):Void
    {
        var loader:ExternalTextLoader = new ExternalTextLoader(id, url);
        manager.addLoader(loader);
    }

    public function addSound(id:String, url:String):Void
    {
        var loader:ExternalSoundLoader = new ExternalSoundLoader(id, url);
        manager.addLoader(loader);
    }
}