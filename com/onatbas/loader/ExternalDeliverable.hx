package com.onatbas.loader;

import com.onatbas.loader.ExternalDeliverableType;

class ExternalDeliverable<T>
{
    public function new()
    {}

    public var id:String;
    public var type:ExternalDeliverableType;
    public var data:T;

    public function setDataByCasting(item:Dynamic):Void
    {
        data = cast item;
    }
}