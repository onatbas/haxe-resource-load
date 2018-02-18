package;
import async.tests.AsyncTestRunner;

class TestMain {
    
    static function main(){
        var r = new AsyncTestRunner(onCompleteTests);
		
		r.add(new TestLoadFiles());
		r.add(new TestSaveFiles());
		r.add(new TestFolderTree());
        r.run();
    }
	
	static private function onCompleteTests() {
		#if COVERAGE
		var logger = mcover.coverage.MCoverage.getLogger();
		logger.report();
		#end
		
		#if !flash
		Sys.exit(0);
		#end
	}
}