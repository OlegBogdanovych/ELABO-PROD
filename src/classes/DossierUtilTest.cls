@isTest
private class DossierUtilTest {

    @testSetup static void setupForTest() {
        TestData.init_custom_settings();
        GoogleHttpCalloutMockTest.runMockUp();

        Date mydate = System.today()+1;
        Account acc = new Account(Factuur_E_mail__c = 'test@test.com',Name = 'TestAccount', Betalingsconditie__c = 14);
        acc.Debiteurnummer__c = '4587940154';
        insert acc;
        Contact contactpers = new Contact(AccountId = acc.Id, Lastname = 'Yo', FirstName= 'No');
        insert contactpers;

        Product__c prod = new Product__c(Name = 'testprod', Vaste_prijs__c = 80);
        insert prod;
        Dossier__c dossier = new Dossier__c(Product__c = prod.Id ,OwnerId = UserInfo.getUserId() , 
                                            Relatie__c = acc.Id, Product_exception__c = 'Geen uitzondering', 
                                            Contactpersoon_opdrachtgever__c = contactpers.Id, Verwijzer__c = acc.Id,
                                            handler__c = UserInfo.getUserId() , Datum_Binnenkomst__c= mydate, Ingangsdatum__c = mydate+1, Einddatum__c = mydate); 
        System.debug('Created');
        insert dossier;
        System.debug('==INSERTED==');
        Product_Exeption__c prodEx = new Product_Exeption__c(Product__c = prod.Id, 
                                        Account__c = acc.Id, Doorlooptijd_in_werkdagen__c = 12);
        insert prodEx;
        Dossierproduct__c dosPr = new Dossierproduct__c(Product_exeption__c = prodEx.Id, 
                                            Dossier__c = dossier.Id, Product__c = prod.Id);
        insert dosPr;
        System.debug('found');
    }
    
    @isTest static void changeHandler() {
        GoogleHttpCalloutMockTest.runMockUp();

        Dossier__c dossier = [SELECT Id,  Relatie__c, Product_exception__c, 
                            Contactpersoon_opdrachtgever__c, Datum_Binnenkomst__c FROM Dossier__c 
                            WHERE handler__c =: UserInfo.getUserId() LIMIT 1]; 
        Account acc = [SELECT Id, Name, Debiteurnummer__c FROM Account WHERE Name =: 'TestAccount'];
        //acc.Debiteurnummer__c = '4587940154';
        //update acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    LocaleSidKey='en_US', ProfileId = p.Id,Kostenplaats__c='00001',
                                    TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                                    Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        insert user;
        System.debug([select Id from Dossier__Share ]);
        Test.startTest();
        dossier.handler__c = user.Id;
        update dossier;
         System.debug([select Id from Dossier__Share ]);
        Test.stopTest();
    }
    
    @isTest static void updateDossierPrExToVerwijzer() {
        GoogleHttpCalloutMockTest.runMockUp();

        Dossier__c dossier = [SELECT Id,  Relatie__c, Product_exception__c, 
                            Contactpersoon_opdrachtgever__c, Datum_Binnenkomst__c FROM Dossier__c 
                            WHERE Product_exception__c =: 'Geen uitzondering' LIMIT 1]; 
        System.debug('******* Geen uitzondering?? **** - ' + dossier.Product_exception__c);
        Test.startTest();

        dossier.Product_exception__c = 'Verwijzer';
        update dossier;
        Test.stopTest();

        System.debug('******* Verwijzer?? **** - ' + dossier.Product_exception__c);
        //dossier.Product_exception__c = 'Relatie';
        //update dossier;
        //System.debug('******* Relatie?? **** - ' + dossier.Product_exception__c);
    }
    
    @isTest static void updateDossierPrExToRelatie() {
        GoogleHttpCalloutMockTest.runMockUp();

        Dossier__c dossier = [SELECT Id,  Relatie__c, Product_exception__c, 
                            Contactpersoon_opdrachtgever__c, Datum_Binnenkomst__c FROM Dossier__c 
                            WHERE Product_exception__c =: 'Geen uitzondering' LIMIT 1]; 
        Test.startTest();

        dossier.Product_exception__c = 'Relatie';
        update dossier;
        Test.stopTest();


    }

    @isTest static void updateDossiertoCLosed() {
        GoogleHttpCalloutMockTest.runMockUp();

        Dossier__c dossier = [SELECT Id,  Relatie__c, Product_exception__c, 
                            Contactpersoon_opdrachtgever__c, Datum_Binnenkomst__c FROM Dossier__c 
                            WHERE Product_exception__c =: 'Geen uitzondering' LIMIT 1]; 
        Test.startTest();

        dossier.Status__c = 'Gesloten';

        update dossier;
        Test.stopTest();


    }

    @isTest static void checkBusinessDays() {
        GoogleHttpCalloutMockTest.runMockUp();

        Date mydate = System.today()+1;
        Dossier__c dossier = [SELECT Id,  Relatie__c, Product_exception__c, 
                            Contactpersoon_opdrachtgever__c, Datum_Binnenkomst__c FROM Dossier__c 
                            WHERE handler__c =: UserInfo.getUserId() AND Ingangsdatum__c =: mydate+1 LIMIT 1]; 
        Test.startTest();
        dossier.Ingangsdatum__c = mydate + 2;
        update dossier;
        Test.stopTest();

    }

}