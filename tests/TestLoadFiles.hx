package ;
import async.tests.AsyncTestCase;
import com.onatbas.loader.AkaLoader;
import com.onatbas.loader.ExternalAssetLoaderEvent;
import haxe.unit.TestCase;

/**
 * Simple test case
 */
class TestLoadFiles extends AsyncTestCase
{	 
	private var loader:AkaLoader;
	
    public function new() {
        super();
		loader = new AkaLoader(3);
		loader.getData(
        loader.addEventListener(ExternalAssetLoaderEvent.LIST_LOAD_COMPLETE, handleLoadComplete);
    }
    
	override public function setup() {
	}
	
	override public function tearDown() {
	}
	
	public function testLoadingFromLocalPath() {
		assertTrue(true);
	}
	
	public function testLoadingFromAbsolutePath() {
		#if flash
		// must not load, status = ERROR
		#end
		
		assertTrue(true);
	}
	
	public function testLoadingNonExistingFiles() {
		assertTrue(true);
	}
	
	public function testRetrievingAssets() {
		// tests various forms of retrieving loaded assets.
	}
	
	public function testStatus() {
		// tests base loader status during the process.
	}
	
}