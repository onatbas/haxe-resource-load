package com.onatbas.akaloader.savers ;


#if html5
#else
import sys.FileSystem;
import sys.io.File;
#end

import haxe.crypto.Md5;
import haxe.io.Bytes;
import flash.utils.ByteArray;
class ByteArraySaver implements IFileSaver<ByteArray>
{
    public function new (){}

    private var path:String;
    private var url:String;
    private var byteArray:ByteArray;

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
        #if html5
        throw("You can not use saver classes in js target");
        return false;
        #else
        return FileSystem.exists(getCompletePath());
        #end

    }

    public function setData(value:ByteArray):Void
    {
        this.byteArray = value;
    }

    public function save():Bool
    {
        #if html5
        throw("You can not use saver classes in js target");
        return false;
        #else
        try{

            var file_output = File.write(getCompletePath(), true);
            file_output.write(cast(byteArray, Bytes));
            file_output.close();
            return true;

        }catch(e:String)
        {
            trace ("Save Failed", e);
        }

        return false;
        #end

    }

    public function getCompletePath():String
    {
        return path + (path.charAt(path.length) == "/"  || path.length == 0 ? "" : "/") + getFileName();
    }



}