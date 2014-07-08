package com.onatbas.akaloader.misc;

enum LoaderStatus {
	IDLE;	 // has not yet loaded anything.
	READY;	 // will start loading if enough slots available.
	LOADING; // loader is loading data
	LOADED;	 // load finished with success.
	FAILED;	 // load finished with error.
}