public with sharing class ContactUtil {
	public ContactUtil() {
		
	}
	public static void entry(TriggerParams triggerParams) {
        List<Contact> triggerNew = (List<Contact>)triggerParams.triggerNew;
        List<Contact> triggerOld = (List<Contact>)triggerParams.triggerOld;
        Map<Id, Contact> oldMap = (Map<Id, Contact>)triggerParams.oldMap;
        Map<Id, Contact> newMap = (Map<Id, Contact>)triggerParams.newMap;


        if (triggerParams.isBefore){
        	if (triggerParams.isUpdate ) {
        		if(!triggerHelper.entryHasStartedGeoLoc){
	        		if ((!System.isBatch() && !System.isFuture()) || Test.isRunningTest()) {
			        	setGeolocation(newMap.keySet());
			        }
		  		}
		        if(!triggerHelper.entryHasStartedGeoLoc){
                   triggerHelper.recursiveHelperGeoLoc(true);
                }
	        }
        }
    }
    @future(Callout=true)
    public static void setGeolocation (Set<Id> contactIds) {
    	System.debug('@future contactIds ' + contactIds);
    	List <Contact> contacts = [select Id, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry,
    								 OtherLongitude, OtherLatitude   from Contact where id in: contactIds];
    	System.debug('contacts ' + contacts);
    	for (Contact contact: contacts) {
	    	String address = '';
	        if (contact.OtherStreet != null)
	            address += contact.OtherStreet +', ';
	        if (contact.OtherCity != null)
	            address += contact.OtherCity +', ';
	        if (contact.OtherState != null)
	            address += contact.OtherState +' ';
	        if (contact.OtherPostalCode != null)
	            address += contact.OtherPostalCode +', ';
	        if (contact.OtherCountry != null)
	            address += contact.OtherCountry;

	        address = EncodingUtil.urlEncode(address, 'UTF-8');
	        System.debug('address ' + address);
	        try{
	            List <Decimal> coordinates = GeolocationCallout.getLocation(address);
	            if (coordinates.size()>1){
	            	contact.OtherLatitude = coordinates.get(0);
	            	contact.OtherLongitude = coordinates.get(1);
	            }
	            System.debug(contact.OtherLatitude+ ' ' + contact.OtherLongitude);
	            update contact;
	        } catch (Exception e) {
	        	System.debug(e.getMessage());
	        	
	        }
	    }

    }
}