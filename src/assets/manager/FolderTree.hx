package assets.manager;
import assets.manager.FolderTree.Node;
import haxe.io.Path;
import haxe.xml.Fast;
import msignal.Signal.Signal1;
#if (cpp || neko || php)
import sys.FileSystem;
import massive.sys.io.File;
import massive.sys.io.FileSys;
import massive.sys.util.PathUtil;
#end

enum Error {
	InvalidDirectory( s : String);
	InvalidPath(s : String);
	RepeatedNode(s : String);
}

enum NodeStatus {
	NEW;
	REMOVED;
	CHANGED;
	UNCHANGED;
}

typedef Node = {
	path:String,
	isDir:Bool,
	children:Array<Node>,
	mdate:Date,
	status:NodeStatus,
}

/**
 * ...
 * @author TiagoLr
 */
class FolderTree {
	
	/** Tree generated from reading xml file or directory contents */
	public var nodeTree:Array<Node>;
	/** Path to the root tree folder */
	public var rootPath(default, null):String;
	/** If true means that its currently loading files */
	public var isLoading(default,null):Bool;
	/** Dispatched when new files are detected */
	public var onFilesAdded:Signal1<Array<String>>;
	/** Dispatched when missing files are detected */
	public var onFilesRemoved:Signal1<Array<String>>;
	/** Dispatched when modified files are detected */
	public var onFilesChanged:Signal1<Array<String>>;
	
	var treeFile:Fast;
	
	public function new() { 
		nodeTree = new Array<Node>();
		rootPath = "";
		
		onFilesAdded = new Signal1<Array<String>>();
		onFilesChanged = new Signal1<Array<String>>();
		onFilesRemoved = new Signal1<Array<String>>();
	}
	
	//---------------------------------------------------------------------------------
	//  FOLDER TREE METHODS
	//---------------------------------------------------------------------------------
	/**
	 * Sets root folder path.
	 * @param	path	Relative or absolute path to the root folder.
	 * @return
	 */
	public function setRoot(path:String):Bool {
		
		#if (cpp || neko || php)
		// Check if path is relative, if true add current dir to it.
		path = FileSystem.fullPath(path);
		path = PathUtil.cleanUpPath(path);
		
		var f:File = File.create(path, null, false);
		if (f.exists) {
			
			if (f.isFile) {
				throw Error.InvalidDirectory( "cannot set root path to existing file");
			}
			// directory exists, use it
			rootPath = f.path.dir;
			return true;
		} else {
		   
			// directory does not exist, create it
		   if (f.createDirectory()) {
			   rootPath = f.path.dir;
			   return true;
		   } else {
			   clearRoot();
			   return false;
		   }
		}
		#end
		
		return false;
	}
	
	public function clearRoot() {
		rootPath = "";
	}
	
	/**
	 * Rebuilds node tree.
	 * If XML file is set, will read files tree from the xml.
	 * Otherwise will read contents recursively from root path.
	 */
	public function refreshTree() {
		
		#if flash
		if (treeFile == null) {
			throw "Must set tree xml file first";
		}
		#end
		
		var root = rootPath;
		#if (cpp || neko || php)
		if (treeFile == null) { // if reading tree from file, check valid path
			if (!FileSys.exists(root) || !FileSys.isDirectory(root)) {
				throw Error.InvalidPath(root);
			}
		}
		#end
		
		// delete removed nodes
		removeDeleted(nodeTree);
		
		// set all tree nodes to REMOVED status
		forAllNodes(nodeTree, function f (n:Node) { n.status = NodeStatus.REMOVED; });
		
		// update node tree
		if (treeFile != null) {
			
			// read tree from xml file
			readTreeXml(treeFile, nodeTree, "");
			treeFile = null; // cleanup after reading file.
			
		} else {
			
			// read tree from folder path
			readPath(root, nodeTree);
		}
		
		// notify listeners of tree changes
		notifyAll();
	}
	
	/**
	 * Applies function to all nodes recursively.
	 * @param	nodes
	 * @param	f
	 */
	public function forAllNodes(nodes : Array<Node>, f : Node-> Void ) {
		for (n in nodes) {
			f(n);
			forAllNodes(n.children, f);
		}
	}
	
	/**
	 * Read xml file and recursively generates tree structure from it.
	 * Paths are not verified.
	 * 
	 * @usage Xml example (note: only root dir has path)
	 * <dir path = 'assets'>
			<dir name = 'd1'>
				<file name='f1' />
				<file name='f2' />
			</dir>
			<file name='f1' />
		</dir>
	 * 
	 * @param	file
	 */
	public function readTreeFromFile(file:Fast) {
		treeFile = file;
		refreshTree();
	}
	
	/**
	 * Print all nodes and their status
	 * @return
	 */
	public function toString():String {
		var result:String = "";
		
		forAllNodes(nodeTree, function (n:Node) {
			n.isDir ? result += "D " : result += "F ";
			result += n.path + " - " + Std.string(n.status);
			result += '\n';
		});
		
		return result;
	}
	/**
	 * If node exists, return if it is a file, otherwise return false.
	 * @param	nodeId
	 */
	public function isNodeFile(nodeId:String):Bool {
		var n:Node = getNode(nodeId, nodeTree, true);
		if (n != null) {
			return !n.isDir;
		}
		return false;
	}
	
	/**
	 * If node exists, return if it is a directory, otherwise return false.
	 * @param	nodeId
	 */
	public function isNodeDir(nodeId:String):Bool {
		var n:Node = getNode(nodeId, nodeTree, true);
		if (n != null) {
			return n.isDir;
		}
		return false;
	}
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	/**
	 * Read xml file and recursively generates tree structure from it.
	 * Paths are not verified.
	 * @param	root
	 * @param	nodes
	 */
	function readTreeXml(root:Fast, nodes:Array<Node>, parentPath:String) {
		
		for (el in root.elements) {
			var name = el.name.toLowerCase();
			if (name != "dir" && name != "file") {
				continue;
			}
			
			var path:String;
			if (parentPath == "") {
				path = el.att.path;
			} else {
				path = Path.addTrailingSlash(parentPath) + el.att.name;
			}
			var node:Node = getNode(path, nodes, false);
			if (node == null) {
				node = createNode(path, name == "dir", new Array<Node>(), Date.now(), NodeStatus.NEW);
				nodes.push(node);
			} else if (node.status == NodeStatus.NEW) {
				
				// if a node has status NEW at this point it means it was added during readTreeXml cycle.
				throw Error.RepeatedNode("Found Repeated node " + path);
			} else {
				
				// node already existed from other tree read.
				node.status = NodeStatus.UNCHANGED;
			}
			
			if (el.name.toLowerCase() == "dir") {
				readTreeXml(el, node.children, path);
			}
		}
		
	}
	/**
	 * Reads path and recursively generates a tree structure from it.
	 * @param	path	filesystem directory
	 * @param	nodes	existing nodes corresponding to this path contents
	 */
	function readPath(root:String, nodes:Array<Node>) {
		
		#if (cpp || neko || php)
		var paths:Array<String> = FileSys.readDirectory(root);
		for (path in paths) {
			path = Path.addTrailingSlash(root) + path;
			
			if (!FileSys.exists(path)) {
				throw Error.InvalidPath(path);
			}
			
			// see if its directory or file, grab modified date if its a file
			var isDir = FileSystem.isDirectory(path);
			var mdate = FileSystem.stat(path).mtime;
			
			// create new node if it does not exist already
			var node:Node = getNode(path, nodes, false);
			if (node == null) {
				node = createNode(path, isDir, new Array<Node>(), mdate, NodeStatus.NEW);
				nodes.push(node);
			} else {
			// update exisitng node
				if (mdate.getTime() > node.mdate.getTime()) {
					node.mdate = mdate;
					node.status = NodeStatus.CHANGED;
				} else {
					node.status = NodeStatus.UNCHANGED;
				}
			}
			
			if (FileSys.isDirectory(path)) {
				readPath(path, node.children);
			}
		}
		#end
	}
	
	function notifyAll() {
		var filesAdded:Array<String> = new Array<String>();
		var filesRemoved:Array<String> = new Array<String>();
		var filesChanged:Array<String> = new Array<String>();
		
		// create notifications
		forAllNodes(nodeTree, function (n:Node) {
			if (n.status == NodeStatus.UNCHANGED) 
				return;
		
			switch(n.status) {
				
				case NodeStatus.NEW:
					filesAdded.push(n.path);
					
				case NodeStatus.REMOVED:
					filesRemoved.push(n.path);
					
				case NodeStatus.CHANGED:
					filesChanged.push(n.path);
					
				case NodeStatus.UNCHANGED:
					// do nothing
			}
		});
		
		// dispatch notifications
		if (filesAdded.length > 0) {
			onFilesAdded.dispatch(filesAdded);
		}
		if (filesChanged.length > 0) {
			onFilesChanged.dispatch(filesChanged);
		}
		if (filesRemoved.length > 0) {
			onFilesRemoved.dispatch(filesRemoved);
		}
	}
	
	function createNode(path:String, isDir:Bool, children:Array<Node>, mdate:Date, status:NodeStatus) {
		
		var node = {
			path : path,
			isDir : isDir,
			children : children,
			mdate: mdate,
			status : status
		}
		
		return node;
	}
	/**
	 * Removes nodes from tree marked as "REMOVED"
	 * @param	nodes
	 */
	function removeDeleted(nodes:Array<Node>) {
		var i:Int = 0;
		var node:Node;
		
		while (i < nodes.length) {
			node = nodes[i];
			if (node.status == NodeStatus.REMOVED) {
				nodes.splice(i, 1);
				i--;
			} else {
				removeDeleted(node.children);
			}
			
			i++;
		}
		
	}
	/**
	 * Searches node recursively in node tree
	 * @param	path			the node path name
	 * @param	levelNodes		the starting nodes (use nodeTree to search the whole tree).
	 * @param	recursive		search the tree recursively?
	 * @return
	 */
	public function getNode(path:String, nodes:Array<Node>, recursive:Bool = true):Node {
		for (n in nodes) {
			
			if (n.path == path) {
				return n;
			}
			
			if (recursive) {
				var result:Node;
				for (child in n.children) {
					result = getNode(path, n.children, true);
					if (result != null) {
						return result;
					}
				}
			}
		}
		
		return null;
	}
	
}