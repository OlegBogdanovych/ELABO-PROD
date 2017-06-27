public with sharing class DossierEmailExtension {
	public String toAddress {get; set;}
	public String ccAddress {get; set;}
	public String bccAddress {get; set;}
	public String emailSubject {get; set;}

	public Dossier__c dossier;

	public String errorMessage {get; set;}

	public DossierEmailExtension(ApexPages.StandardController ctrl) 
	{
		this.dossier = (Dossier__c)ctrl.getRecord();
		System.debug('OBdeb dossierID -->> ' + this.dossier.Id);
	}


	public PageReference sendMail()
	{
		errorMessage = null;
		List<String> toAddresses = new List<String>();
		List<String> ccAddresses = new List<String>();
		List<String> bccAddresses = new List<String>();

		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    	Pattern MyPattern = Pattern.compile(emailRegex);
    	Matcher MyMatcher;

    	List<String> addresses = toAddress.split(';');
    	for (String addr : addresses)
    	{
    		MyMatcher = MyPattern.matcher(addr);
    		if (!MyMatcher.matches())
	        {
	        	errorMessage = 'Wrong recipient email ' + addr + '<br />';
	        } else {
	        	toAddresses.add(addr);
	        }
    	}
    	

        if(ccAddress != null && ccAddress != '')
        {
        	addresses = ccAddress.split(';');
        	for (String addr : addresses)
    		{
    			MyMatcher = MyPattern.matcher(addr);
		    	if (!MyMatcher.matches())
		        {
		        	if(errorMessage != null)
		        	{
		        		errorMessage += '<br />';
		        		
		        	} else {
		        		errorMessage = '';
		        	}
		        	errorMessage += 'Wrong ccAddress ' + addr + ' email';
		        } else {
		        	ccAddresses.add(addr);
		        }
    		}
        }

        if(bccAddress != null && bccAddress != '')
        {
        	addresses = bccAddress.split(';');
        	for (String addr : addresses)
    		{
	        	MyMatcher = MyPattern.matcher(addr);
		    	if (!MyMatcher.matches())
		        {
		        	if(errorMessage != null)
		        	{
		        		errorMessage += '<br />';
		        		
		        	} else {
		        		errorMessage = '';
		        	}
		        	errorMessage += 'Wrong bccAddress ' + addr + ' email';
		        } else {
		        	bccAddresses.add(addr);
		        }
	    	}
        }

		if(errorMessage == null)
		{
			String body = dossier.EmailBody__c;
			if (body == null) {
				body = '';
			}
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(toAddresses);
			mail.setWhatId(dossier.Id);
			mail.setSenderDisplayName('Salesforce Support');
			mail.setSubject(emailSubject);
			mail.setUseSignature(false);
			mail.setHtmlBody(body);
			mail.setWhatId(this.dossier.Id);

			if(ccAddresses != null && !ccAddresses.isEmpty())
			{
				mail.setCcAddresses(ccAddresses);
			}

			if(bccAddresses != null && !bccAddresses.isEmpty())
			{
				mail.setBccAddresses(bccAddresses);
			}
			System.debug('to: ' + toAddresses);
            if(!Test.isRunningTest()){
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			if (!results.get(0).isSuccess()) {

    			System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();

    			String errorMessage = results.get(0).getErrors()[0].getMessage();
    			System.debug('ERROR: ' + errorMessage);
			}

            }
			
		}
		toAddress = null;
		ccAddress = null;
		bccAddress = null;
		emailSubject = null;
		dossier.EmailBody__c = null;
		return null;
	}
}