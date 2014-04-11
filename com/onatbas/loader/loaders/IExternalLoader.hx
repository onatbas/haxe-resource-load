package com.onatbas.loader.loaders;

import com.onatbas.loader.ExternalDeliverable;

interface IExternalLoader<T>
{
    public var id(default, null):String;
    public function addListener(type:String, listener:Dynamic -> Void):Void;
    public function removeListener(type:String, listener:Dynamic -> Void):Void;
    public function disposeAll():Void;
    public function start():Void;
    public function canDeliver(item:ExternalDeliverable<Dynamic>):Bool;
    public function deliver(item:ExternalDeliverable<T>):Void;

    public function prepare():Void;
    public var ready(default, null):Bool;

}