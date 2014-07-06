package com.onatbas.loader.loaders;


class ExternalTextLoader extends BaseExternalLoader
{
    public function new(id:String, request:String) {
        super(id, request);
    }

    override function prepare() {
		data = Std.string(loader.data);
	}
}