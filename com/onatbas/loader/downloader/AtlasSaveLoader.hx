package com.onatbas.loader.downloader;

import com.onatbas.loader.event.LoaderEvent;
import com.onatbas.loader.loaders.IExternalLoader;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.EventDispatcher;
import flash.events.Event;
import aze.display.SparrowTilesheet;
import flash.display.Bitmap;
import flash.display.BitmapData;


class AtlasSaveLoader implements IExternalLoader<Dynamic>
{
    private var dispatcher:EventDispatcher;

    private var textLoader:TextSaveLoader;
    private var bitmapLoader:PngSaveLoader;

    private var xmlUrl:String;
    private var bitmapUrl:String;

    private var path:String;

    private var _atlas:SparrowTilesheet;
    public var atlas(get_atlas, never):SparrowTilesheet;

    public var id(default, null):String;

    private var deliverableBitmapDatas:Map<String, BitmapData>;
    private var deliverableBitmapSizes:Map<String, Rectangle>;
    private var deliverableBitmapRects:Map<String, Rectangle>;

    private var loadedCount:Int;
    private var scale:Float;

    public var ready(default, null):Bool = false;

    public function new(id:String, path:String, xmlUrl:String, bitmapUrl:String, scale:Float = 1)
    {
        this.dispatcher = new EventDispatcher();
        this.id = id;

        this.path = path;

        loadedCount = 0;
        this.scale = scale;
        this.xmlUrl = xmlUrl;
        this.bitmapUrl = bitmapUrl;
    }

    public function canDeliver(deliverable:ExternalDeliverable<Dynamic>):Bool
    {
        if (deliverable.type == TEXTURELIST) if (deliverable.id == id) return true;
        if (deliverable.type == ATLAS) if (deliverable.id == id) return true;
        if (deliverable.type == BITMAP) if (deliverableBitmapSizes.exists(deliverable.id)) return true;
        return false;
    }

    public function deliver(deliverable:ExternalDeliverable<Dynamic>):Void
    {

        if (deliverable.type == TEXTURELIST)
        {
            var keys = deliverableBitmapSizes.keys();
            deliverable.setDataByCasting(keys);
        }
        if (deliverable.type == ATLAS) deliverable.setDataByCasting(atlas);
        if (deliverable.type == BITMAP)
        {
            if (deliverableBitmapDatas[deliverable.id] == null)
                createBitmapData(deliverable.id);

            deliverable.setDataByCasting(deliverableBitmapDatas[deliverable.id]);
        }
    }

    private function createBitmapData(id:String):Void
    {
        var size:Rectangle = deliverableBitmapSizes[id];
        var rect:Rectangle = deliverableBitmapRects[id];

        var img = bitmapLoader.getBitmapData();

        var ins = new Point(0, 0);
        var bmp = new BitmapData(cast size.width, cast size.height, true, 0);
        ins.x = -size.left;
        ins.y = -size.top;
        bmp.copyPixels(img, rect, ins);

        deliverableBitmapDatas[id] = bmp;
    }

    public function start():Void
    {
        loadedCount = 0;
        textLoader = new TextSaveLoader(null, path, xmlUrl);
        textLoader.addListener(LoaderEvent.COMPLETE, handleComplete);
        textLoader.start();

        bitmapLoader = new PngSaveLoader(null, path, bitmapUrl);
        bitmapLoader.addListener(LoaderEvent.COMPLETE, handleComplete);
        bitmapLoader.start();

    }

    public function handleComplete(?e:LoaderEvent):Void
    {
        loadedCount++;
        if (loadedCount == 2)
        {
            textLoader.prepare();
            bitmapLoader.prepare();
            this.dispatcher.dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
        }
    }

    public function prepare():Void
    {

        var bitmap:BitmapData = bitmapLoader.getBitmapData();
        var text:String = textLoader.getText();

        _atlas = new SparrowTilesheet(bitmap, text, scale);
        ready = true;

        deliverableBitmapDatas = new Map<String, BitmapData>();
        deliverableBitmapSizes = new Map<String, Rectangle>();
        deliverableBitmapRects = new Map<String, Rectangle>();

        var x = new haxe.xml.Fast( Xml.parse(text).firstElement() );

        for (texture in x.nodes.SubTexture)
        {
            var name = texture.att.name;

            var rect = new Rectangle(
            Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));

            var size = if (texture.has.frameX) // trimmed
                new Rectangle(
                Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth), Std.parseInt(texture.att.frameHeight));
            else
                new Rectangle(0, 0, rect.width, rect.height);

            deliverableBitmapSizes[name] = size;
            deliverableBitmapRects[name] = rect;
            deliverableBitmapDatas[name] = null;
        }
    }

    public function get_atlas():SparrowTilesheet
    {
        return _atlas;
    }

    public function disposeAll():Void
    {
        textLoader.removeListener(Event.COMPLETE, handleComplete);
        bitmapLoader.removeListener(Event.COMPLETE, handleComplete);

        textLoader.disposeAll();
        bitmapLoader.disposeAll();

        textLoader = null;
        bitmapLoader = null;

        var key:String;
        for (key in deliverableBitmapDatas.keys())
        {
            if (deliverableBitmapDatas[key] == null) continue;
            deliverableBitmapDatas[key].dispose();
            deliverableBitmapDatas[key] = null;
        }

        _atlas = null;

    }

    public function addListener(type:String, listener:Dynamic -> Void):Void
    {
        this.dispatcher.addEventListener(type, listener);
    }

    public function removeListener(type:String, listener:Dynamic -> Void):Void
    {
        this.dispatcher.removeEventListener(type, listener);
    }
}
