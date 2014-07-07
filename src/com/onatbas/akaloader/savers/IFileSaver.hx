package com.onatbas.akaloader.savers ;
/**
 * @author Onat Baş
 * 25.01.2014
 *
 *
 *
 * This interface draws the borders of a downloader API.
 *
 * */

interface IFileSaver<T>
{

    /**
    * @value Path to save or load the item from (refers to hard drive)
    * */
    public function setPath(value:String):Void;

    /**
    * @return   Returns the file name for the data to be saved in the hard drive.
     *          The name is calculated accoring to the url (possibly MD5'd
     *          state of the url).
     *          Might return null.
    * */
    public function getFileName():String;

    /**
    *
    * @return Returns true if the data is saved on the hard drive.
    * */
    public function isSaved():Bool;

    /**
    * @value    The data to be saved on the hard drive, intothe path specified,
    *           with the name generated.
    *
    * */
    public function setData(value:T):Void;


    /**
    *
    * Save data request.
    *
    * @return Returns is saving is seccessfull.
    * */
    public function save():Bool;


    /**
    * @return   Returns the exact path that data could be
    *           loaded.
    * */
    public function getCompletePath():String;

    /**
    * @value    The url to the external data.
    * */
    public function setUrl(value:String):Void;

}
