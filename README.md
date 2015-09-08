# ceylon-couchdb
API to access Apache CouchDB for the language Ceylon


This module is an API for the communication with a CouchDB database via HTTP.
   CouchDB uses a RESTful API to work with the database and the documents and views
   in the database. This Ceylon API gives high-level access to the most important
   tasks.  
   
   
   Example usage (create a new database, store/save a document in the database, update it, delete it, delete the database again):
   + CouchDB localCouchDB=CouchDB("http://127.0.0.1:5984/");		
   + localCouchDB.createDatabase("testceylonAPI");
   + localCouchDB.saveDocument("testceylonapi", "testDocumentID", \"\"\"{"testkey":"testvalue"}\"\"\"));
   + localCouchDB.updateDocument("testceylonapi", "testDocumentID",\"\"\"{"you":"her","his":"our"}\"\"\");
   + localCouchDB.deleteDocument("testceylonapi", "testDocumentID");
   + localCouchDB.deleteDatabase("testceylonAPI");  