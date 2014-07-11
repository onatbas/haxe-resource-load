package ;
import async.tests.AsyncTestCase;
import haxe.xml.Fast;
import assets.manager.FolderTree;
#if (cpp || neko || php)
import massive.sys.io.FileSys;
import haxe.io.Path;
import haxe.unit.TestCase;
import massive.sys.io.File;
#end

/**
 * Tests folder tree class.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestFolderTree extends AsyncTestCase
{	 
	
	var manager:FolderTree;
	#if (cpp || neko || php)
	var rootPath:String;
	
	var root:File;
	var f1:File;
	var f2:File;
	var f3:File;
	
	#end
	public function new() {
		super();
		manager = new FolderTree();
	}
	#if (cpp || neko || php)
	override public function setup() {
		root = File.create(FileSys.getCwd() + "root");
		root.createDirectory(true);
		var A = root.resolvePath("A", true, FileType.DIRECTORY);
		var B = root.resolvePath("B", true, FileType.DIRECTORY);
		f1 = A.resolvePath("f1", true, FileType.FILE);
		f2 = A.resolvePath("f2", true, FileType.FILE);
		f3 = B.resolvePath("f3", true, FileType.FILE);
		rootPath = root.path.dir;
		manager.setRoot(rootPath);
	}
	
	
	override public function tearDown() {
		manager.nodeTree = new Array<Node>();
		root.deleteDirectory(true);
		f1 = null;
		f2 = null;
		f3 = null;
	}
	
	/**
	 * Tests setting root path to diferent (and also invalid) directories.
	 */
	public function testSetRootPath() {
		var pth:String;
		
		// test setting existing path
		pth = FileSys.getCwd() + "root";
		assertTrue(manager.setRoot(pth));
		assertTrue(manager.rootPath == pth);
		
		// test setting path to new dir
		pth = FileSys.getCwd() + "root\\newdir";
		assertTrue(manager.setRoot(pth));
		assertTrue(manager.rootPath == pth);
		
		// remove created dir
		var f = File.create(pth);
		f.deleteDirectory();
		
		// test setting relative path
		pth = "root\\new_relative_dir";
		assertTrue(manager.setRoot(pth));
		pth = FileSys.getCwd() + pth;
		assertTrue(manager.rootPath == pth);
		
		var f = File.create(pth);
		f.deleteDirectory();
		
		// test wrong paths
		try {
			manager.setRoot(FileSys.getCwd() + "root\\A\\f1"); // sets file name instead of dir
			assertTrue(false);
		} catch (e : Error) {
			assertTrue(true);
		}
		
	}
	
	// tests refreshing tree with no root set
	public function testNoRoot() {
		manager.clearRoot();
		assertTrue(manager.rootPath == "");
		try {
			manager.refreshTree();
			assertTrue(false);
		} catch (e:Error) {
			switch(e) {
				case InvalidPath(s) : assertTrue(true);
				case InvalidDirectory(s) : assertTrue(false);
				default:
			}
		}
	}
	
	
	public function testCreateTree() {
		
		// test number of nodes (2 directories + 3 files)
		var numNodes:Int = 0;
		manager.refreshTree();
		manager.forAllNodes(manager.nodeTree, function(n:Node) { numNodes++; } );
		assertTrue(numNodes == 5);
	}
	
	
	public function testStatusNew() {
		
		// all nodes must be new
		var newNodes = 0;
		manager.refreshTree();
		manager.forAllNodes(manager.nodeTree, function(n:Node) {
			if (n.status == NodeStatus.NEW) {
				newNodes++;
			}
		});
		assertTrue(newNodes == 5);
	}
	
	
	public function testStatusUnchanged() {
		
		// all nodes must be unchanged after new refresh
		var unchangedNodes = 0;
		manager.refreshTree();
		manager.refreshTree();
		manager.forAllNodes(manager.nodeTree, function(n:Node) {
			if (n.status == NodeStatus.UNCHANGED) {
				unchangedNodes++;
			}
		});
		assertTrue(unchangedNodes == 5);
	}
	
	
	public function testStatusRemoved() {
		
		// all nodes must have been removed after deleting and contents
		var removedNodes = 0;
		manager.refreshTree();
		root.deleteDirectoryContents();
		manager.refreshTree();
		manager.forAllNodes(manager.nodeTree, function(n:Node) {
			if (n.status == NodeStatus.REMOVED) {
				removedNodes++;
			}
		});
		assertTrue(removedNodes == 5);
	}
	
	public function testStatusChanged() {
		
		// write contents to two files, see if two files are changed
		var changedNodes = 0;
		manager.refreshTree();
		Sys.sleep(1); // waits one second to make sure files modified date is changed.
		f1.writeString("f1 modified");
		f2.writeString("f2 modified");
		manager.refreshTree();
		manager.forAllNodes(manager.nodeTree, function(n:Node) {
			if (n.status == NodeStatus.CHANGED) {
				changedNodes++;
			}
		});
		assertTrue(changedNodes == 2);
	}
	#end
	
	public function testReadingFastTree() {
		var tree = new Fast(Xml.parse("
			<dir path = 'assets'>
				<dir name = 'd1'>
					<file name='f1' />
					<file name='f2' />
				</dir>
				<file name='f1' />
			</dir>
			"
			));
		
		var nodes:Array<String>;
			
		manager.onFilesAdded.addOnce(function (n:Array<String>) { nodes = n; } );
		manager.readTreeFromFile(tree);
		
		assertTrue(nodes.length == 5);
		assertTrue(nodes.indexOf("assets") != -1);
		assertTrue(nodes.indexOf("assets/d1") != -1);
		assertTrue(nodes.indexOf("assets/f1") != -1);
		assertTrue(nodes.indexOf("assets/d1/f1") != -1);
		assertTrue(nodes.indexOf("assets/d1/f2") != -1);
	}
}
