public with sharing class ErrorHandeling {
	public static void saveLog(String errorString, String responce, String recordId) {
		Twinfield_Log__c log = new Twinfield_Log__c();
	    log.Error__c = errorString;
	    log.Responce__c = responce;
	    log.RecordId__c = recordId;
	    if (responce.contains('salesline')) {
	    	log.Advice__c = 'Please check the error and try again by pushing Send Invoice button on ' + recordId;
		}
	    insert log;
	    System.debug('Error Log ' + log );
	}	
}