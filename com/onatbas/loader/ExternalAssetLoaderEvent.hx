package com.onatbas.loader;

import flash.events.Event;

class ExternalAssetLoaderEvent extends Event
{
    public static inline var LIST_LOAD_COMPLETE:String = 'listLoadComplete';

    public function new(type:String)
    {
        super(type);
    }

}