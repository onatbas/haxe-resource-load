package com.onatbas.akaloader.loaders ;
import com.onatbas.akaloader.misc.FileType;


class TextLoader extends BaseLoader
{
    public function new(id:String) {
        super(id, FileType.TEXT);
    }

    override function processData() {
		data = Std.string(loader.data);
	}
}