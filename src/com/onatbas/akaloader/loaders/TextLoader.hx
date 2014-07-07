package com.onatbas.akaloader.loaders ;


class TextLoader extends BaseLoader
{
    public function new(id:String, request:String) {
        super(id, request);
		this.type = AssetType.TEXT;
    }

    override function prepare() {
		data = Std.string(loader.data);
	}
}