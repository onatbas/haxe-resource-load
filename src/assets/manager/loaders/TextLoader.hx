package assets.manager.loaders ;
import assets.manager.misc.FileType;


class TextLoader extends BaseLoader
{
    public function new(id:String) {
        super(id, FileType.TEXT);
    }

    override function processData() {
		data = Std.string(loader.data);
	}
}