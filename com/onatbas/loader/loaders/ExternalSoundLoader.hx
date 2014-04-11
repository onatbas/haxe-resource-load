package com.onatbas.loader.loaders;
/**
 * @author Onat Baş
 * 11.02.2014
 *
 * */

import flash.utils.ByteArray;
import com.onatbas.loader.event.LoaderEvent;
import flash.events.Event;
import flash.net.URLRequest;
import flash.events.EventDispatcher;
import flash.media.Sound;

import com.onatbas.loader.ExternalDeliverableType;

class ExternalSoundLoader implements IExternalLoader<Sound>
{

    public var id(default, null):String;
    public var ready(default, null):Bool;

    private var sound:Sound;
    private var loader:ExternalByteArrayLoader;

    private var dispatcher:EventDispatcher;


    /**
    *
    *
    * */
    public function new(id:String, url:String)
    {
        ready = false;
        this.id = id;
        dispatcher = new EventDispatcher();
        this.loader = new ExternalByteArrayLoader(id, url);
        sound = new Sound();
        this.loader.addListener(LoaderEvent.COMPLETE, handleComplete);
    }

    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        if (deliverable.type != SOUND) return false;
        if (deliverable.id != this.id) return false;

        return true;
    }

    public function deliver(deliverable:ExternalDeliverable<Sound>):Void
    {
        deliverable.data = sound;
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

    public function handleComplete(e:LoaderEvent):Void
    {
        loader.prepare();
        #if html5
        for (i in 0...20){
            trace ("Sound Loader in html5 is not supported yet");
        }
        #else
        sound.loadCompressedDataFromByteArray(loader.data, loader.data.length);
        #end
        dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));

    }


    public function disposeAll():Void
    {
        loader.disposeAll();
        sound.close();
        ready = false;
    }

    public function addListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void):Void
    {
        dispatcher.removeEventListener(type, listener);
    }

    public function getByteArray():ByteArray
    {
        return loader.data;
    }
}
