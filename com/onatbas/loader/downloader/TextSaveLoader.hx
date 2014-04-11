package com.onatbas.loader.downloader;
/**
 * @author Onat Baş
 * 25.01.2014
 *
 * */

import com.onatbas.loader.event.LoaderEvent;
import flash.events.Event;
import com.onatbas.loader.loaders.ExternalTextLoader;
import flash.events.EventDispatcher;
import com.onatbas.loader.loaders.IExternalLoader;
class TextSaveLoader implements IExternalLoader<String>
{
    private var saveAfterLoadRequired:Bool = false;

    private var dispatcher:EventDispatcher;
    private var textLoader:ExternalTextLoader;
    private var textSaver:TextSaver;

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
        textLoader.disposeAll();
    }

    public function start():Void
    {
        textLoader.start();
    }

    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        return textLoader.canDeliver(deliverable);
    }

    public function deliver(deliverable:ExternalDeliverable<String>):Void
    {
        textLoader.deliver(deliverable);
    }

    public function new(id:String, path:String, url:String)
    {
        this.id = id;

        dispatcher = new EventDispatcher();

        textSaver = new TextSaver();
        textSaver.setPath(path);
        textSaver.setUrl(url);


    if (textSaver.isSaved())
        {
            textLoader = new ExternalTextLoader(id, textSaver.getCompletePath());
            saveAfterLoadRequired = false;
        }
        else
        {
            textLoader = new ExternalTextLoader(id, url);
            saveAfterLoadRequired = true;
        }

        textLoader.addListener(LoaderEvent.COMPLETE, handleComplete);
    }

    private function handleComplete(e:LoaderEvent):Void
    {
        ready = true;

        dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
    }

    public function prepare():Void
    {
        textLoader.prepare();

        if (saveAfterLoadRequired)
        {
            textSaver.setData(textLoader.getText());
            textSaver.save();
        }

    }

    public function getText():String
    {
        return textLoader.getText();
    }

}
