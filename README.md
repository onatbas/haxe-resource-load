AkaLoader - External Asset Loading Library for OpenFL
=========


This library contains some useful classes for handling external assets.

What this library is designed for:
=========

* Loading Assets without using openfl.Assets class. This allows you to use assets without embedding them.
* Use external assets from web or local storage. 
* Downloading/Saving assets from web.
* Reusing assets from pre-downloaded content without needing to connect to internet.
* Cross-Platform asset management system with very simple load/unload calls.
* Simplified, id based, delivering of assets.


I did not test on all platforms, but last time i checked, iOS, Android, HTML5, Mac, Windows builds are good to go.
NOTE: This is an old library, i don't quite recall what is implemented and what is not, but if you open issues, i will gladly check and try fixing it-implementing it. But you are free to fork this (please do!)

The way this library is intented to be used:
=========

You should have a ExternalAssetLoader instance 

```
 /**
    * External Asset Loading API
    * */
    private var loader:ExternalAssetLoader;
    
    
 /**
    * Crating Asset Loader and listening to load sequence events.
    * */
    private function initAssetLoader():Void
    {
        loader = new ExternalAssetLoader(3);
        loader.addEventListener(ExternalAssetLoaderEvent.LIST_LOAD_COMPLETE, handleLoadComplete);
    }

    /**
    * Triggering of this method suggests the requested external assets are loaded and ready to use.
    * */
    private function handleLoadComplete(e:ExternalAssetLoaderEvent):Void
    {
        trace ("Load Complete");
    }
```

And create a loader for each asset (of whichever type). Some loader types are included but it is really aesy to create for own Loaders. Just implement IExternalLoader<YourType>, fill required methods, and that's it.

Here is some loaders:
*ExternalBitmapLoader
*ExternalByteArrayLoader
*ExternalSoundLoader
*ExternalTextLoader
*ExternalTextureAtlasLoader // requires Tilesheet library, remove it if you dont want it.

Loaders are good for managing local assets, they can download data from web (since most of them use URLLoader)
If you need to download and save external assets from web, you should use SaveLoader classes, which are:
*AtlasSaveLoader
*ByteArraySaveLoader
*PngSaveLoader
*SoundSaveLoader
*TextSaveLoader

once you call load() method. SaveLoaders will download, and save the asset (in a fitting type) to local storage. The name for the saved file depends on the URL to load (ome md5'ing involved). So if you create same SaveLoader with same constructor parameter, next time you request load, if there is such file in local storage, it wont download from web but act like an ExternalLoader class.


Once you create loaders, you should add them to your ExternalAssetLoader, for example, here is my code for adding atlas loaders. Just be sure that everything has a unique id! 



```
  /**
    * Define an external atlas
    * */
    public function defineAtlas(id:String, bitmapUrl:String, xmlUrl:String):Void
    {
        var atlasLoader:ExternalTextureAtlasLoader = new ExternalTextureAtlasLoader(id, xmlUrl, bitmapUrl);
        loader.addLoader(atlasLoader);
    }

    /**
    * Define an external text.
    * */
    public function defineText(id:String, textUrl:String):Void
    {
        var atlasLoader:ExternalTextLoader = new ExternalTextLoader(id, textUrl);
        loader.addLoader(atlasLoader);
    }

   /**
    * Define an external bitmap.
    *
    * @id : Bitmap id that'll be used for requests.
    * @bitmapUrl : Url or Path to Bitmap.
    * */
    public function defineBitmap(id:String, bitmapUrl:String):Void
    {
        var atlasLoader:ExternalBitmapLoader = new ExternalBitmapLoader(id, bitmapUrl);
        loader.addLoader(atlasLoader);
    }

    /**
    * Define a ByteArray Loader
    *
    * @id : id that'll be used for requests
    * @bitmapUrl : Url or Path to ByteArray
    * */
    public function defineByteArray(id:String, url:String):Void
    {
        var atlasLoader:ExternalByteArrayLoader = new ExternalByteArrayLoader(id, url);
        loader.addLoader(atlasLoader);
    }

    /**
    * Define an OGG formatted sound loader
    *
    * @id : Id for sound.
    * @url : Url or Path to *.ogg
    * */
    public function defineSound(id:String, url:String):Void
    {
        var sound:ExternalSoundLoader = new ExternalSoundLoader(id, url);
        loader.addLoader(sound);
    }
```

You can also group your assets with ExternalAssetParty. Which is good for loading/unloading multiple entries with one load/unload call.Here's an example.
```
  var party:ExternalAssetParty;

        // Initializing json party.
        party = new ExternalAssetParty("jsonParty", 2);
        party.addText("otherAssets", "your path to json here");
        party.addText("playerData", "your path to player json here");
        party.addText("saveData", "your path to save data here");

  loader.addLoader(party);
```



Loading / Unloading of assets
=========

This part is pretty straight-forward. Loading and unloading is done by list of ids (Array<String>).

```
  var list = new Array<String>();
  
  list.push("jsonParty");
  list.push("myBitmapSaveLoaderId");
  list.push("mySparrowTileSheet");
  list.push("clickSound");
  list.push("otherClickSound");
  list.push("gamePartyThatIncludesSoundsAndBitmaps");

  loader.loadList(list);
  //loader.unloadList(list);
```

Thats it, the loading is asyncronous on all targets and when loading is complete, an ExternalAssetLoaderEvent will be dispatched from loader. That's why i put handleLoadComplete method there.

Receiving the Assets
=========

If you're requesting a predefined asset (like Bitmapdata, TilesheetEx, ByteArray, String etc.) this is simple as these:

```
var myByteArray:ByteArray = loader.getByteArray("myByteArrayId");
var myTilesheet:TilesheetEx = loader.getTileSheet("myTileSheet");
var myText:String = loader.getText("myJsonId");
var myBitmap:BitmapData = loader.getBitmapData("myBitmapData");
//...
```

The good thing about this is that you don't have to know in which party or atlas etc. that bitmapData with mybitmapData is. It searches in each loader, asks them if they can deliver this bitmapData, and deliver from there! If you're using my implementation of AtlasLoader, this means, when you request a mybitmapData from the Atlas sheet, you can get that bitmapData!


If you want to obtain a type that's not defined here, this part can be tricky, but i did this the this is because of two reasons.
1. i wanted to avoid typecasting as much as i can, and if the asset you're requesting comes from a loader that delivers only a single type, there is no typecasting.
2. To be extendible, it needs to be defined dynamically.
3. 
For example a sound getter is not implemented. But you can still obtain sounds like this:

```
        var deliverable = new ExternalDeliverable<Sound>();
        deliverable.id = id;
        deliverable.type = ExternalDeliverableType.SOUND;
        loader.findAgent(deliverable).deliver(deliverable);


        var mySound:Sound = deliverable.data;
```

About type >> deliverable.type = ExternalDeliverableType.SOUND; // if you implement some other asset form, leave this blank, since you implement the delivering algorithm in your Loader class, this wont be an issue.



Storing local Assets
=========

I've used this mostly for local asset management. If you want to ue local assets, you should include them in your package, with openfls project.xml tags, like this: 
```
    <assets path="content/subdirectory" embed="false" />
```
Don't forget to add embed="false", otherwise openfl will load all of them at the start of the application,which is what we are trying to avoid here :) Now all you have to do is define your loaders with their relative path. 

Quick note : on iOS, there's a strange behaviour of openFL. OpenFL places your content into a specific folder with strange names. for example, if you have a mybitmap.png in content/subdirectory, your content is saved in an unpredictable folder with a name content_subdirectory_mybitmap_png  .  so if you're targeting ios, i suggest using openfl.Assets.getPath() to validate exact path. Here is my code to do that.
```
    private function getPath(path:String):String
    {
        var assetPath = Assets.getPath(path);
        if (assetPath == null) return path;
        return assetPath;
    }
```

Usage Tips
=========

I suggest having a json file with a fixed path, formatted like this : https://gist.github.com/onatbas/10468471 , and first load that file, and define loaders according to that json file. 

Since you can change the content of this json file, you can change, remove, add asset entries into it, or at least this is how i used it.


A Little Explanation
=========

* Like i said, the code is old, i don't if it is still working right now. But i will be looking at issues and pull requests. 
* While downloading content, loader doesn't inform you about what it is doing. a SaveLoader will download an asset if it cant find it, but will not dispatch an event to inform, you have to check for that, or you can extend this library to dispatch these events, it should be easy to add something like that to ExternalAssetLoaderEvent. i just didn't have time for it and didnt need to use download feature so stopped working on it.
* The library doesnt check for permanent assets. If you want an asset to be permanent, you should not call unloadList() with a list with that id :) you have to check for that as well.
* I might be lazy sometimes, so if you think there's a fix you can handle, please fork! i'll be glad to see all these forks :)

Have fun ! 
