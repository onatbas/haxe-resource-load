Assets Manager provides utils to manage external files, its main features are:

* Load external files.
* Save files in different formats.
* Queue files to load / load them at once.
* Use relative, absolute path or url for files.
* Read folder structure and receive alerts for modified files or folders.

Assets Manager is based of [AkaLoader](https://github.com/onatbas/AkaLoader) by Onatbas.

### **Version 1.1 changes:**

* Added type based API to load, queue and get files.
* Added unique callbacks for each file loaded.
* Removed error signal dispatchers, error status must be checked by listener.

###Main Components

* **FileLoader** - Loads external files. **(cross-platform) - :requires openfl: -**
* **FileSaver** - Saves files to disk **(native targets)** 
* **FolderTree** - Reads folder structure **(native targets)**

**msignal** and **mlib** are also required by some of the components.

#FileLoader

Uses openfl URLLoader to load external files. Full-path, relative path or URL can be used, full-path not available for flash target (and html5?).

Files are loaded assynchronously, and diferent notifications are sent:
* **onFileLoaded :** everytime a file is loaded successfully.
* **onFilesLoaded :** when files are loaded and there are no more to load.
* **NEW** - Unique callbacks may be assigned to each file when loading or queueing them.

Example showing how to load a single file and assigning unique callback.
```actionscript
var loader = new FileLoader();
loader.loadText("text.txt", onTextLoaded); 

function onTextLoaded(f:FileInfo) {
    if (f.status == LoaderStatus.LOADED) {  // check for errors
        trace(f.data);
    }
}
```
Example showing how to queue multiple files and listen for all files loaded signal.

```actionscript
var loader = new FileLoader();
loader.onFilesLoaded.add(onComplete);   // listen to all files loaded signal.
loader.queueImage("image.png");         // local path
loader.queueImage("C:/dir/image.jpg");  // full path
loader.queueImage("www.img.com/i.jpg"); // url
loader.loadQueuedFiles();               // load queued files.

function onComplete(files:Array<FileInfo>) {
    for (file in files) {
        if (file.status == LoaderStatus.LOADED 
            && file.type == FileType.IMAGE) {
            addChild(new Bitmap(file.data));             
        }
    }
}
```

Supported types:

* **Image** - Png and jpg tested, retrieves data as BitmapData.
* **Sound** - Ogg tested, retreive data as Sound.
* **Text**  - Retrieve data as String.
* **Binary** - Retrieve data as bytearray.

#FileSaver
Provides a shortcut to save files in different formats, also verifies path and creates directories if they don't exist.

An example showing how to save diferent files:

```actionscript
FileSaver.saveAsPNG("C:/File.png", myBitmapData);
FileSaver.saveAsText("Text.txt", "some string"); // saves locally.
FileSaver.saveAsBytes("File", myByteArray); // saves locally.
```

#FolderTree

Folder tree reads a folder contents recursively and sends notifications when files or sub-dirs are added, removed or modified.


Example:
```actionscript
var ftree = new FolderTree();
ftree.setRoot("C:\rootDir");
ftree.onFilesAdded.add(onNew);
ftree.onFilesChanged.add(onModified);
ftree.onFilesRemoved.add(onRemoved);

ftree.refresh();
```
The first time ```refresh()``` is called, every file and dir it finds are going to be new, for eg. toString() would output:

```
D C:\rootDir\subDir - NEW
F C:\rootDir\subDir\text.txt - NEW
F C:\rootDir\subDir\imag.jpg - NEW
```

If file text.txt is renamed to rrrr.txt and refresh is called again, it would result in:

```
D C:\rootDir\subDir - UNCHANGED
F C:\rootDir\subDir\text.txt - REMOVED
F C:\rootDir\subDir\rrrr.txt - NEW
F C:\rootDir\subDir\imag.jpg - UNCHANGED
```

A third refresh after editing imag.jpg would result in:

```
D C:\rootDir\subDir - UNCHANGED
F C:\rootDir\subDir\rrrr.txt - UNCHANGED
F C:\rootDir\subDir\imag.jpg - CHANGED
```

And so on...


Folder trees can also be read from XML (see ```readTreeFromFile()```), non-native targets can also use this option.
