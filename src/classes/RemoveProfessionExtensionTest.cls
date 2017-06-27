@isTest
private class RemoveProfessionExtensionTest {
    
    @isTest static void removeDossier() {
        GoogleHttpCalloutMockTest.runMockUp();

        TestData.init_custom_settings();
        TestData.init_Remote_Api_Settings();
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
        ApexPages.StandardController sc = new ApexPages.StandardController(dossier);
        RemoveDossierExtension rp = new RemoveDossierExtension(sc);
        rp.redirectBack();
        System.assertEquals(null, [select handler__c from Dossier__c ].handler__c);
    }
    
}