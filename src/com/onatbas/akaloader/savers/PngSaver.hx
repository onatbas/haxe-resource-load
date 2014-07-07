package com.onatbas.akaloader.savers ;
/**
 * @author Onat Baş
 * 25.01.2014
 *
 * */

#if html5
#else
import sys.FileSystem;
#end

import haxe.crypto.Md5;
import com.onatbas.akaloader.utils.SaveUtil;
import flash.display.BitmapData;

class PngSaver implements IFileSaver<BitmapData>
{

    private var path:String;
    private var url:String;
    private var bmpData:BitmapData;

    public function new()
    {}

    public function setPath(value:String):Void
    {
        this.path = value;
    }

    public function setUrl(value:String):Void
    {
        this.url = value;
    }

    public function getFileName():String
    {
        if (url == null) return null;
        return Md5.encode(url);
    }

    public function isSaved():Bool
    {

        if (!FileSystem.exists(path))
        {
            FileSystem.createDirectory(path);
        }

        #if html5
        throw("You can not use saver classes in js target");
        return false;

        #else
        return FileSystem.exists(getCompletePath());
        #end
    }

    public function setData(value:BitmapData):Void
    {
        this.bmpData = value;
    }

    public function save():Bool
    {
        #if html5
        throw("You can not use saver classes in js target");
        return false;
        #else

        try
        {
            SaveUtil.savePNG(bmpData, getCompletePath());

        } catch (e:String)
        {
            trace("Save Failed", e);
        }

        return false;
        #end
    }

    public function getCompletePath():String
    {
        var extension:String;
        #if flash
        extension = ".png";
        #else
        extension = "";
        #end
           return path + (path.charAt(path.length) == "/"  || path.length == 0 ? "" : "/") + getFileName() + extension;

      //  return path + "_" + getFileName() + extension;
    }

}
