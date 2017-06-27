@isTest
private class AccountUtilTest {
    
    @isTest static void debuterNumberTest() {
        TestData.init_custom_settings();
        TestData.init_Remote_Api_Settings();
        GoogleHttpCalloutMockTest.runMockUp();

        Vat_code__c vat = new Vat_code__c(Name = 'VH21'        );
        insert vat;
        RecordType rT = [select Id from RecordType where SobjectType = 'Account' and Name = '1 Opdrachtgever'];
        Account account = new Account();
        account.Name = 'Test';
        account.Facturatieritme__c = 'Wekelijks';
        account.E_mail__c = 'TEST.test@test.test';
        account.RecordTypeId = rT.Id;
        account.Factuur_E_mail__c = 'test@test.com';
        Test.startTest();
        insert account;
        Contact c = new Contact (LastName = 'Test' , AccountId = account.id);
        insert c;
        Dossier__c dossier = new Dossier__c(Relatie__c = account.id, Contactpersoon_opdrachtgever__c = c.id, Datum_Binnenkomst__c = date.today());
        insert dossier;
        account.Send_request_to_TF__c = true;
        String response;
        String expectedResponse;
        
        //Test with invalid Relation Type.
        try {
          TwinfieldXmlRequestBuilder.getCreateRelationRequest('bla', null, '2016-12-12');
        } catch(Exception e) {
          System.assertEquals('NotAuthorizedTwinfieldException', e.getTypeName());
          System.assert(e.getMessage()=='Fout in Relatie type.');
        }
        //Test with invalid Relation
        try {
          TwinfieldXmlRequestBuilder.getCreateRelationRequest('CRD', null,  '2016-12-12');
        } catch(Exception e) {
          System.assertEquals('NotAuthorizedTwinfieldException', e.getTypeName());
          //System.assert(e.getMessage()=='Een Relatie die crediteur of debiteur is moet gekoppeld zijn aan een bedrijf.');
        }
        
        
        
        System.assertEquals(true, account.Send_request_to_TF__c);
        
        
        //TEST DEB request with valid Relation and no relation deb number
        response = TwinfieldXmlRequestBuilder.getCreateRelationRequest('DEB', account,  '2016-12-12');
        expectedResponse = '<?xml version="1.0" encoding="UTF-8"?><dimension><type>DEB</type>'
          
          +'<name>'+account.Name+'</name><website>null</website><addresses>'
          +'<address type="invoice" default="true">'
          +'<'+TwinfieldXmlRequestBuilder.ADDRESS_FIELD_NAME+'></'+TwinfieldXmlRequestBuilder.ADDRESS_FIELD_NAME+'>'
          +'<'+TwinfieldXmlRequestBuilder.VAT_CODE_FIELD_NAME+'>'+''+'</'+TwinfieldXmlRequestBuilder.VAT_CODE_FIELD_NAME+'>'
          +'<'+TwinfieldXmlRequestBuilder.COC_FIELD_NAME+'>'+''+'</'+TwinfieldXmlRequestBuilder.COC_FIELD_NAME+'>'
          +'<postcode>null</postcode><city>null</city><country>NL</country><telephone>null</telephone><email>'+account.e_mail__c+'</email></address></addresses></dimension>';
        //System.assertEquals(expectedResponse, response);
        

        Test.stopTest();
        //System.assertNotEquals(null, [select Debiteurnummer__c from Account].Debiteurnummer__c);

    }
    
    
}