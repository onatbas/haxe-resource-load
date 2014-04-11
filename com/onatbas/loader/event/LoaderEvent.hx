package com.onatbas.loader.event;

import com.onatbas.loader.loaders.IExternalLoader;
import flash.events.Event;
class LoaderEvent extends Event
{
    public static inline var COMPLETE:String = "loaderComplete";


    public var loader (default, null):IExternalLoader<Dynamic>;

    public function new (type:String, loader:IExternalLoader<Dynamic>)
    {
        this.loader = loader;
        super(type);
    }
}