import ceylon.test {
	test,
	assertFalse,
	assertTrue
}
import net.biver.couchdb {
	CouchDB
}

"Tests the CeylonCouchDB API. The tests assume a local CouchDB without user access restriction at http://127.0.0.1:5984."
test shared void couchDBAPITest() {
	CouchDB localCouchDB=CouchDB("http://127.0.0.1:5984/");
	
	// preparation, no assertion
	localCouchDB.createDatabase("testceylonapi");
	
	// print ("create database - again");
	assertFalse(localCouchDB.createDatabase("testceylonapi"));
	
	// print ("delete database");
	assertTrue(localCouchDB.deleteDatabase("testceylonapi"));
	
	// print ("delete database - again");
	assertFalse(localCouchDB.deleteDatabase("testceylonapi"));
	
	// print ("create database");
	assertTrue(localCouchDB.createDatabase("testceylonapi"));	
	
	// print ("save document in database");
	assertTrue(localCouchDB.saveDocument("testceylonapi", "testName", """{"test":"testvalue"}"""));
	
	//print ("save document in database - again (only updateDocument should works, save should not):");
	assertFalse(localCouchDB.saveDocument("testceylonapi", "testName", """{"test":"testvalue"}"""));
	
	// print ("delete document from database");
	assertTrue(localCouchDB.deleteDocument("testceylonapi", "testName"));
	
	// print ("delete document from database - again");
	assertFalse(localCouchDB.deleteDocument("testceylonapi", "testName"));
	
	// print ("save document in database");
	assertTrue(localCouchDB.saveDocument("testceylonapi", "testName", """{"test":"testvalue"}"""));
	
	// print ("read document from database");
	variable Boolean|String answer = localCouchDB.getDocument("testceylonapi", "testName");
	assert(answer is String);
	
	// print ("update document in database");
	assertTrue(localCouchDB.updateDocument("testceylonapi", "testName","""{"you":"her","his":"our"}"""));
	
	// clean up, no assertion
	localCouchDB.deleteDatabase("testceylonapi");	
}
