package assets.manager.misc ;

enum LoaderStatus {
	IDLE;	 // has not yet loaded anything.
	READY;	 // will start loading if enough slots available.
	LOADING; // loader is loading data
	LOADED;	 // load finished with success.
	ERROR;	 // load finished with error.
}