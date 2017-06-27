/**	Author       :    Marcus Yavorskyy
*   Email        :    marcus.yavorskyy@beethree.net
*   Description  :    Class for GoogleDrive intergration.
*   Created Date :    27.02.2017
**/


public with sharing class GoogleDrive {	
	public static Map<String, googleDriveParents__c> parentIds = googleDriveParents__c.getAll();

	// Creates a Query String for sending as a parameter.
	private static String createQueryString(Map<String, String> params) {
	    String str = '';
	    for (String name : params.keySet()) {
	      if (str.length() > 1) {
	        str += '&';
	      }
	    String value = params.get(name);
	    str += EncodingUtil.urlEncode(name, 'UTF-8') + '=' + EncodingUtil.urlEncode(value, 'UTF-8');
	    }
	    return str;
	}


	// Create for each created Dossier a Google Folder and Add the Url to the dossier.
	@future(callout = 'true')
	public static void createFolderForDossier(Set <Id> dossierIds){
		System.debug('METHOD  - createFolderForDossier - STARTED');
		String alternateLink;
		Httprequest request;
		Map <String, Object> requestBodyMap = new Map <String, Object>();
		Map <String, Object> responseMap = new Map <String, Object>();
		List <Dossier__c> toUpdate = new List <Dossier__c>();
		String parentId;
		List <Dossier__c> toCheck = new List <Dossier__c>();
		// Get new Dossiers
		Map <Id, Dossier__c> dossiersMap = DossierDAO.getDossiersMapByIds(dossierIds);
   		googleDriveParents__c folderIdRecord = googleDriveParents__c.getInstance('Dossier Mappen');

		if(null != folderIdRecord ){
			parentId = folderIdRecord.ParentId__c;
		}

		//for each dossier create a folder.
		for (Dossier__c dossier : dossiersMap.values()){

			String folderName = dossier.Name;
			if(getIfFolderExists(folderName, parentId)){
				System.debug('Creating folder');

			    requestBodyMap = new Map<String, Object> {
			      'title' => dossier.Name,
			      'mimeType' => 'application/vnd.google-apps.folder',
			      'parents'=> new List<Map<String, String>> {
			        new Map<String, String> {
			          'id' => parentId
			        }
			      }
			    };
			    // Create a request from the Body.
			    request = createRequest(requestBodyMap, 'POST', true, null);
			    // Send Request And get the response from Google Drives
			    responseMap = getResponse(request);

			    System.debug('responseMap' + responseMap);
			    alternateLink = (String)responseMap.get('alternateLink');
			    // Get the Link to the Folder and insert the value to the Dossier
			    dossier.Google_Drive_Folder__c = alternateLink;
			    toUpdate.add(dossier);
			}
		}
		update toUpdate;

	}

	// Check if Folder already exists.
	public static Boolean getIfFolderExists (String folderName, String parentFolder) {
		List<Object> items= new List<Object>();
		Map<String, Object> responseMap = new Map <String, Object>();
	    Map<String, String> params = new Map<String, String>();
	    String queryString='';
	    params.put('q', '(mimeType = \'application/vnd.google-apps.folder\') and title = \'' + folderName + '\' and \''+parentFolder+'\' in parents and trashed = false');
		params.put('max_results', '1');
		params.put('fields', 'items(id)');
		queryString = createQueryString(params);

	    //String queryString = createQueryString(params);

	    Httprequest request = createRequest(null, 'GET', false, queryString); 
	    responseMap = getResponse(request);
	    if(responseMap != null){

		    if(!responseMap.isEmpty()){ 
		    	items = (List<Object>)responseMap.get('items');
		    }
		    	    	
	    }
	    System.debug('items' + items);

	    // if there is no such folder returns True else return False.

	    if(null != items && items.isEmpty()){
	      	return true;
	    }else{
	      	return false; 
	    }


	}


	public static Map <String, Object> getResponse (Httprequest request){
		Map <String, Object> toReturn = new Map <String, Object>();
		Httpresponse response;
		//try {
	        Http http = new Http();
		    if(!Test.isRunningTest()){
		    	// Sends the request and gets the response.   
	        	response = http.send(request);
		        System.debug('response.STATUS:'+ response.getStatus() );
		        System.debug('response.STATUS_CODE:'+ response.getStatusCode() );
		        System.debug('response.BODY: '+ response.getBody() );
		        if (response.getStatusCode() >= 200 && response.getStatusCode()<= 300) {
				    System.debug('response.getStatusCode(): '+ response.getStatusCode() );
		        }
		      
		        toReturn = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		    }else{
		    	List<Object> obj = new List<Object>();
		    	Object obj2 = 'https://alternate';
				toReturn.put('alternateLink', obj2);
				toReturn.put('items', obj);
		    }

	        System.debug('responseMap' + toReturn);
	      
	    /*} catch (Exception e) {
	        System.debug(e);
	        toReturn = null;
	    }*/
		return toReturn;
	}

	public static Httprequest createRequest(Map <String, Object> requestBodyMap, String method, Boolean noSearch, String query){
		
		String requestBody;
	    Httprequest toReturn = new Httprequest();
	    toReturn.setMethod(method);
	    if(noSearch){
			requestBody = JSON.serialize(requestBodyMap);
	    	toReturn.setEndpoint('callout:GoogleDriveFiles');
	    	toReturn.setHeader('Content-type', 'application/json');
	   		toReturn.setBody(requestBody);
	    }else{

	    	String endpointValue = 'callout:GoogleDriveFiles';
	    	if(!Test.isRunningTest()){ // temporal Solution
	    		endpointValue += '?' + query;
	    	}
	    	toReturn.setEndpoint(endpointValue);

	    }
	    return toReturn;
	}
	
}