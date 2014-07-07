package com.onatbas.akaloader.utils ;
/**
 * @author Onat Baş
 * 24.01.2014
 *
 * */

#if html5
        #else
import sys.io.File;
import sys.io.FileOutput;

#end
import flash.display.IBitmapDrawable;
import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.display.BitmapData;
class SaveUtil
{

    /**
* This method renders whatever IBitmapDrawable content it gets, and saves it
* with the given width and height. Scales the content if needed. And saves it as
* png to hard drive.
*
* @width        Explicit width for content to be saved
* @height       Explicit height for content to be saved
* @content      IBitmapDrawable content
* @path         Path to target folder including file name with extension
* @smoothing    is rendering going to be smoothened?
* */
    /*    public static function saveAs(width:Float, height:Float, content:IBitmapDrawable, path:String, smoothing:Bool):Void
    {
        var saveBitmap:BitmapData = new BitmapData(Std.int(width), Std.int(height));
        var matrix:flash.geom.Matrix = new flash.geom.Matrix();
        var ratioX:Float;
        var ratioY:Float;
        ratioX = width / content.width;
        ratioY = height / content.height;

        matrix.scale(ratioX, ratioY);
        saveBitmap.draw(content, matrix, null, null, null, smoothing);
        savePNG(saveBitmap, path);
    }*/

    /**
* This method saves pngs on hard drive.
*
* @bitmapData BitmapData to be saved.
* @path Path to folder including the name with extension.
* */
    public static function savePNG(bitmapData:BitmapData, path:String):Void
    {

        #if html5
        throw("You can not use saver classes in js target");
        #else
        var byteArray:ByteArray = bitmapData.encode('png');
        var handle:FileOutput = File.write(path, true);
        handle.write(cast(byteArray, Bytes));
        handle.close();
        #end

    }
}
