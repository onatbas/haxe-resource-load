package com.onatbas.loader;

import flash.utils.ByteArray;
import com.onatbas.loader.loaders.IExternalLoader;
import flash.events.EventDispatcher;
import flash.events.Event;
import com.onatbas.loader.LoadingStatusType;
import openfl.media.Sound;

import flash.display.Bitmap;
import flash.display.BitmapData;

import com.onatbas.loader.ExternalDeliverableType;

class ExternalAssetLoader extends BaseLoaderManager<Dynamic>
{
    public function new(maxConnectionLimit:Int = 1)
    {
        super(maxConnectionLimit);
    }

	/**
	 * Gets loaded data with matching id as BitmapData.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getBitmapData(id:String):BitmapData
    {
        var deliverable:ExternalDeliverable<BitmapData> = new ExternalDeliverable<BitmapData>();
        deliverable.id = id;
        deliverable.type = BITMAP;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

	/**
	 * Gets loaded data with matching id as Text.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getText(id:String):String
    {
        var deliverable:ExternalDeliverable<String> = new ExternalDeliverable<String>();
        deliverable.id = id;
        deliverable.type = TEXT;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

	/**
	 * Gets loaded data with matching id as list of texture names.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getTextureList(id:String):Iterator<String>
    {
        var deliverable:ExternalDeliverable<Iterator<String>> = new ExternalDeliverable<Iterator<String>>();
        deliverable.id = id;
        deliverable.type = TEXTURELIST;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }

	/**
	 * Gets loaded data with matching id as ByteArray.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
    public function getByteArray(id:String):ByteArray
    {
        var deliverable:ExternalDeliverable<ByteArray> = new ExternalDeliverable<ByteArray>();
        deliverable.id = id;
        findAgent(deliverable).deliver(deliverable);
        return deliverable.data;
    }
	
	/**
	 * Gets loaded data with matching id as Sound.
	 * If it is not found returns null.
	 * @param	id		The asset id.
	 * @return 			Loaded data.
	 */
	public function getSound(id:String):Sound
	{
		var deliverable:ExternalDeliverable<Sound> = new ExternalDeliverable<Sound>();
		deliverable.id = id;
		deliverable.type = SOUND;
		findAgent(deliverable).deliver(deliverable);
		return deliverable.data;
	}
	
	/**
	 * Gets loaded data with matching id. 
	 * If it is not found returns null.
	 * @param  id	The asset id.
	 * @return		Loaded data.
	 */
	public function getData(id:String):Dynamic {
		
	}
	
	/**
	 * Gets the status of the data loader with matching id.
	 * If it does not exist null is returned.
	 * @param	id	The loader id (same as asset id).
	 * @return		Loader status.
	 */
	public function getStatus(id:String):LoadingStatusType {
		
	}

}