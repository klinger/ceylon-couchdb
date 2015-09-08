import ceylon.net.uri {
	Uri,
	parse
}
import ceylon.net.http.client {
	ResponseClient=Response,
	RequestClient=Request
}
import ceylon.net.http {
	put,
	get,
	delete,
	Method
}
import ceylon.language {
	String
}
import ceylon.json {
	jsonparse=parse,
	JsonObject=Object,
	JsonValue=Value,
	JsonArray=Array
}

"The class CouchDB is a high-level API to access a CouchDB database via HTTP/HTTPS. 
 You can just create an instance of the class with a url like 
 http://adminuser:mypassword@127.0.0.1:5984/ 
 - you do not have to add the part 'username:password@' if everybody can access the CouchDB." // TODO
shared class CouchDB(String url) {
	
	"These method makes the requests to the CouchDB server. 
	    + uristring: example: http://127.0.0.1:5984/ or http://adminuser:mypassword@127.0.0.1:5984/
	    + method: this is a http method from ceylon.net.http (put, get, delete, ..)
	    + statuscodesForSuccess: the expected http statuscodes
	    + messageBody: this is the body of the http request to the CouchDB server
	    + revision: some requests to CouchDB require a version number
	     ##
	    + Return value (success) a string containing the message body of the HTTP response if HTTP statuscode in response is in statuscodesForSuccess 
	    + Return value (failed): Boolean 'false'"
	String|Boolean makeRequestWorker(String uristring, Method method, Integer[] statuscodesForSuccess, String messageBody, String revision) {
		// print( uristring); // TODO DEBUGSTRING
		Uri uri = parse(uristring);
		RequestClient request = uri.get();
		request.setHeader("Acccept", "aplication/json");
		request.setHeader("Accept-Encoding", "gzip,deflate");
		request.setHeader("Content-Type", "application/json");
		if (revision.size > 0) {
			request.setHeader("If-Match", revision);
		}
		request.method = method;
		request.data = messageBody;
		ResponseClient response = request.execute();
		try {
			String jsonstring = response.contents;
			if (response.status in statuscodesForSuccess) {
				return jsonstring;
			} else {
				// print(jsonstring); // TODO DEGBUGSTRING
				return false;
			}
		} catch (Exception e) {
			print("error: " + e.string);
			return false;
		}
	}
	
	"makeRequest, makeRevisionRequest and makeContentRequest call makeRequestWorker with a subset of the parameters. 
	    + Return value (success): Boolean 'true' if HTTP statuscode in response is in statuscodesForSuccess.
	    + Return value (failed): Boolean 'false'"
	Boolean makeRequest(String uristring, Method method, Integer[] statuscodesForSuccess, String messageBody) {
		Boolean|String answer = makeRequestWorker(uristring, method, statuscodesForSuccess, messageBody, "");
		if (is String answer) {
			return true;
		} else {
			return answer;
		}
	}
	
	"makeRequest, makeRevisionRequest and makeContentRequest call makeRequestWorker with a subset of the parameters. 
	    + Return value (success): Boolean 'true' if HTTP statuscode in response is in statuscodesForSuccess.
	    + Return value (failed): Boolean 'false'"
	Boolean makeRevisionRequest(String uristring, Method method, Integer[] statuscodesForSuccess, String messageBody, String revision) {
		Boolean|String answer = makeRequestWorker(uristring, method, statuscodesForSuccess, messageBody, revision);
		if (is String answer) {
			return true;
		} else {
			return answer;
		}
	}
	
	"makeRequest, makeRevisionRequest and makeContentRequest call makeRequestWorker with a subset of the parameters. 
	    + Return value (success) a string containing the message body of the HTTP response if HTTP statuscode in response is in statuscodesForSuccess 
	    + Return value (failed): Boolean 'false'"
	String|Boolean makeContentRequest(String uristring, Method method, Integer[] statuscodesForSuccess, String messageBody) {
		return makeRequestWorker(uristring, method, statuscodesForSuccess, messageBody, "");
	}
	
	"(not working yet) Inserts into a JSON document a CouchDB revision number."
	String insertRevision(variable String jsonDocument) {
		return jsonDocument; // TODO missing function, does not work yet
	}
	
	"Reads the CouchDB revision number from a jsonDocument.
	    + Return value (success): a string containing the revision number
	    + Return value (failed): Boolean 'false'"
	Boolean|String getRevision(variable String jsonDocument) {
		variable JsonValue? parsedJson = null;
		try {
			parsedJson = jsonparse(jsonDocument);
			if (exists revision = parsedJson) {
				if (is JsonObject revision) {
					JsonValue revID = revision.get("_rev");
					if (is String revID) {
						return revID;
					}
				}
			}
		} catch (Exception e) {
			print("getRevision CouchDB.ceylon error: " + e.string);
			return false;
		}
		return false;
	}
	
	"Creates a CouchDB database with the name databaseName.
	    + Return value (success): Boolean 'true'
	    + Return value (failed): Boolean 'false'"
	shared Boolean createDatabase(String databaseName) {
		return makeRequest(url + databaseName, put, [201], "");
	}
	
	"Deletes a CouchDB database with the name databaseName.
	    + Return value (success): Boolean 'true'
	    + Return value (failed): Boolean 'false'"
	shared Boolean deleteDatabase(String databaseName) {
		return makeRequest(url + databaseName, delete, [200], "");
	}
	
	"Gets the document with documentID from a CouchDB database with the name databaseName.
	    + Return value (success): a JSON string containing the document
	    + Return value (failed): Boolean 'false'"
	shared Boolean|String getDocument(String databaseName, String documentID) {
		return makeContentRequest(url + databaseName + "/" + documentID, get, [200, 304], "");
	}
	
	
	"Deletes a CouchDB document identified by the documentID in the database with the name databaseName. 
	    CouchDB only allows to delete documents if you know the revision number. This method gets the document, 
	    extracts the revisionnumber and deletes the document. 
	    + Return value (success): Boolean 'true'
	    + Return value (failed): Boolean 'false'"
	shared Boolean deleteDocument(String databaseName, String documentID) {
		Boolean|String documentInDB = getDocument(databaseName, documentID);
		if (is String documentInDB) {
			Boolean|String revision = getRevision(documentInDB);
			if (is String revision) {
				return makeRevisionRequest(url + databaseName + "/" + documentID, delete, [200, 202], "", revision);
			} else {
				// print ("This path isnt possible when communicating with a CouchDB database but it is needed in case of some defect.");				 
				return false;
			}
		} else {
			// print("Deleting not possible. The document doesnt exist."); 
			return false;
		}
	}
	
	"Saves the JSON Document jsonDocument with the ID documentID in the database databaseName.  
	    + Return value (success): Boolean 'true'
	    + Return value (failed): Boolean 'false'"
	shared Boolean saveDocument(String databaseName, String documentID, String jsonDocument) {
		return makeRequest(url + databaseName + "/" + documentID, put, [200, 201], jsonDocument);
	}
	
	
	"Saves an revised/updated version of a JSON document jsonDocument identified by the ID documentID in the CouchDB database databaseName.
	    An update is only possible if the current revision id is known. Thats why this method first requests the document and then uses
	    the revision id for the update via a HTTP If-Match header.
	    + Return value (success): Boolean 'true'
	    + Return value (failed): Boolean 'false'"
	shared Boolean updateDocument(String databaseName, String documentID, variable String jsonDocument) {
		Boolean|String documentInDB = getDocument(databaseName, documentID);
		if (is String documentInDB) {
			Boolean|String revision = getRevision(documentInDB);
			if (is String revision) {
				return makeRevisionRequest(url + databaseName + "/" + documentID, put, [200, 201], jsonDocument, revision);
			} else {
				// print ("This path is not possible when communicating with a CouchDB database (but it is needed if something breaks).");				 
				return false;
			}
		} else {
			// print("Update of document is not possible. Document does not exist?"); 
			return false;
		}
	}
}