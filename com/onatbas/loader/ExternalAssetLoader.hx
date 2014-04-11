package com.onatbas.loader;

import flash.utils.ByteArray;
import aze.display.TilesheetEx;
import com.onatbas.loader.loaders.IExternalLoader;
import flash.events.EventDispatcher;
import flash.events.Event;
import com.onatbas.loader.LoadingStatusType;

import flash.display.Bitmap;
import flash.display.BitmapData;
import aze.display.SparrowTilesheet;

import com.onatbas.loader.ExternalDeliverableType;

class ExternalAssetLoader extends BaseLoaderManager<Dynamic>
{
    public function new(maxConnectionLimit:Int = 1)
    {
        super(maxConnectionLimit);
    }

    public function getBitmapData(id:String):BitmapData
    {
        var deliverable:ExternalDeliverable<BitmapData> = new ExternalDeliverable<BitmapData>();
        deliverable.id = id;
        deliverable.type = BITMAP;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

    public function getText(id:String):String
    {
        var deliverable:ExternalDeliverable<String> = new ExternalDeliverable<String>();
        deliverable.id = id;
        deliverable.type = TEXT;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

    public function getTileSheet(id:String):TilesheetEx
    {
        var deliverable:ExternalDeliverable<TilesheetEx> = new ExternalDeliverable<TilesheetEx>();
        deliverable.id = id;
        deliverable.type = ATLAS;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

    public function getTextureList(id:String):Iterator<String>
    {
        var deliverable:ExternalDeliverable<Iterator<String>> = new ExternalDeliverable<Iterator<String>>();
        deliverable.id = id;
        deliverable.type = TEXTURELIST;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

    public function getByteArray(id:String):ByteArray
    {
        var deliverable:ExternalDeliverable<ByteArray> = new ExternalDeliverable<ByteArray>();
        deliverable.id = id;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

}