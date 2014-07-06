package com.onatbas.loader.downloader;
/**
 * @author Onat Baş
 * 25.01.2014
 *
 * */

import com.onatbas.loader.event.LoaderEvent;
import com.onatbas.loader.loaders.BitmapLoader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import com.onatbas.loader.loaders.IExternalLoader;
class PngSaveLoader implements IExternalLoader<BitmapData>
{

    private var saveAfterLoadRequired:Bool = false;

    private var dispatcher:EventDispatcher;
    private var bmpLoader:BitmapLoader;
    private var pngSaver:PngSaver;

    private var state:String;

    public var id(default, null):String;
    public var ready(default, null):Bool = false;



    public function addListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.removeEventListener(type, listener);
    }

    public function disposeAll():Void
    {
        bmpLoader.disposeAll();
    }

    public function start():Void
    {
        bmpLoader.start();
    }


    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        return bmpLoader.canDeliver(deliverable);
    }

    public function deliver(deliverable:ExternalDeliverable<BitmapData>):Void
    {
        bmpLoader.deliver(deliverable);
    }



    public function new(id:String, path:String, url:String)
    {
        this.id = id;

        dispatcher = new EventDispatcher();

        pngSaver = new PngSaver();
        pngSaver.setPath(path);
        pngSaver.setUrl(url);


        if (pngSaver.isSaved())
        {
            bmpLoader = new BitmapLoader(id, pngSaver.getCompletePath());
            saveAfterLoadRequired = false;
        }
        else
        {
            bmpLoader = new BitmapLoader(id, url);
            saveAfterLoadRequired = true;
        }


        bmpLoader.addListener(LoaderEvent.COMPLETE, handleComplete);
    }


    private function handleComplete(e:Event):Void
    {
        ready = true;

        dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }

    public function prepare():Void
    {
        bmpLoader.prepare();

        if (saveAfterLoadRequired)
        {
            pngSaver.setData(bmpLoader.getBitmapData());
            pngSaver.save();
        }

    }

    public function getBitmapData():BitmapData
    {
        return bmpLoader.getBitmapData();
    }


}
