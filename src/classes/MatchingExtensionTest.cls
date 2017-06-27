@isTest
private class MatchingExtensionTest {
    
    @isTest static void test_method_one() {

        TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'System Admin' limit 1];
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,Kostenplaats__c='147852',
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        
        
         
        insert user;
        update user;
        user = new User(Alias = 'standt', Email='stand11arduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Kostenplaats__c='147852',
                            TimeZoneSidKey='America/Los_Angeles', UserName='Ok1@test.test', 
                            Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Ferdinand Bolstraat');
            insert user;
            user.Email = 'test@test.test';
            update user;
        System.runAs(user){
            Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test', Betalingsconditie__c = 2);
            insert account;
            Contact contact = new Contact(LastName = 'TestC', AccountId = account.id, OtherStreet = 'Dantestraat', 
                                        OtherCity = 'Amsterdam', OtherPostalCode = '3076 KJ', OtherCountry = 'Nederland' );
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
            
            String address1 = '';
        if (user.Street != null)
            address1 += user.Street +', ';
        if (user.City != null)
            address1 += user.City +', ';
        if (user.State != null)
            address1 += user.State +' ';
        if (user.PostalCode != null)
            address1 += user.PostalCode +', ';
        if (user.Country != null)
            address1 += user.Country;
        String address2 = address1;
        address2.replace('Dantestraat', 'Ferdinand Bolstraat');
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        address2 = EncodingUtil.urlEncode(address2, 'UTF-8');
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address1+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address2+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleUserResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+address2+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleResponceDistance');

        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
            insert contact;
            update contact;
            GoogleHttpCalloutMockTest.runMockUp();

            Dossier__c dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched',Contactpersoon_opdrachtgever__c = contact.id, Datum_Binnenkomst__c = date.today());
            insert dossier;
            GoogleHttpCalloutMockTest.runMockUp();

            dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched',Contactpersoon_opdrachtgever__c = contact.id, Datum_Binnenkomst__c = date.today());
            insert dossier;
            GoogleHttpCalloutMockTest.runMockUp();

            dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Voorlopig gematched',Contactpersoon_opdrachtgever__c = contact.id, Datum_Binnenkomst__c = date.today());
            insert dossier;
            
            
            
           
            MatchingExtension ctrl = new MatchingExtension();
            ctrl.loadData();
            ctrl.seacrhByNumber = '00';
            ctrl.addFilterToDossiers();
            ctrl.unmatchedDossiers.get(0).isSelected = true;
            
            ctrl.findUsers ();
            ctrl.closeMatchUser();
            ctrl.findUsers();
    
            ctrl.selectedType = 'All';
            ctrl.unmatchedDossiers.get(0).isSelected = true;
            ctrl.users.get(0).isSelected = true;
            ctrl.addFilter();
            ctrl.saveDefault();
            ctrl.users.get(0).isSelected = true;
            ctrl.finishMatching();
            ctrl.setOpen();
            ctrl.getSkillFilter();
            ctrl.getTypeFilter();
            ctrl.unmatch();
            
            List <String> fields = new List <String>{'Name', 'AccountName', 'Datum', 'End','Load', 'Branche', 'OtherAddress', 'User' };
            List <String> dirs = new List <String>{'ASCENDING', 'DESCENDING'};
            for (String dir: dirs) {
                for (String f: fields) {
                    ctrl.sortDirection = dir;
                    ctrl.sortField = f;
                    ctrl.sortByFiled();
                }
            }
          
            
            ctrl.sortByFiledVoor();
            fields = new List <String>{'Name', 'Skill', 'Address', 'uren','Mogelijk', 'type', 'Voorkeur' };
            for (String dir: dirs) {
                for (String f: fields) {
                    ctrl.sortDirection = dir;
                    ctrl.sortField = f;
                    ctrl.sortByFiledUser();
                }
            }
            fields = new List <String>{'Name', 'AccountName', 'Datum', 'End','Load', 'Branche', 'OtherAddress' };
            dirs = new List <String>{'ASCENDING', 'DESCENDING'};
            ctrl.loadData();
            for (String dir: dirs) {
                for (String f: fields) {
                    ctrl.sortDirection = dir;
                    ctrl.sortField = f;
                    ctrl.sortByFiled();
                    
                }
            }
         }
        Test.stopTest();
    }
    
    /*@isTest static void test_method_two() {
        TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test');
        insert account;
        Contact contact = new Contact(LastName = 'TestC', AccountId = account.id, OtherStreet = 'Dantestraat', 
                                    OtherCity = 'Amsterdam', OtherPostalCode = '3076 KJ', OtherCountry = 'Nederland' );
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
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'System Admin' limit 1];
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        String address1 = '';
        if (user.Street != null)
            address1 += user.Street +', ';
        if (user.City != null)
            address1 += user.City +', ';
        if (user.State != null)
            address1 += user.State +' ';
        if (user.PostalCode != null)
            address1 += user.PostalCode +', ';
        if (user.Country != null)
            address1 += user.Country;
        String address2 = address1;
        address2.replace('Dantestraat', 'Ferdinand Bolstraat');
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        address2 = EncodingUtil.urlEncode(address2, 'UTF-8');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address1+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address2+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleUserResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+address2+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleResponceDistance');

        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        insert contact;
        update contact;
        Dossier__c dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Voorlopig gematched');
        insert dossier;
        
        
        insert user;
        update user;
        user = new User(Alias = 'standt', Email='stand11arduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok1@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Ferdinand Bolstraat');
        insert user;
        user.Email = 'test@test.test';
        update user;
        MatchingExtension ctrl = new MatchingExtension();
        ctrl.loadData();
        ctrl.seacrhByNumber = '00';
        ctrl.addFilterToDossiers();
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        
        ctrl.findUsers ();
        ctrl.closeMatchUser();
        ctrl.findUsers();

        ctrl.selectedType = 'All';
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        ctrl.users.get(0).isSelected = true;
        ctrl.addFilter();
        ctrl.saveDefault();
        ctrl.users.get(0).isSelected = true;
        ctrl.finishMatching();
        ctrl.setOpen();
        ctrl.getSkillFilter();
        ctrl.getTypeFilter();
        
        List <String> fields = new List <String>{'Name', 'AccountName', 'Datum', 'End','Load' };
        List <String> dirs = new List <String>{'ASCENDING', 'DESCENDING'};
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiled();
            }
        }
      
        
        ctrl.sortByFiledVoor();
        fields = new List <String>{'Name', 'Skill', 'Address', 'uren','Mogelijk', 'type', 'Voorkeur' };
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiledUser();
            }
        }
  
        Test.stopTest();
    }
     @isTest static void test_method_two3() {
        TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test');
        insert account;
        Contact contact = new Contact(LastName = 'TestC', AccountId = account.id, OtherStreet = 'Dantestraat', 
                                    OtherCity = 'Amsterdam', OtherPostalCode = '3076 KJ', OtherCountry = 'Nederland' );
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
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'System Admin' limit 1];
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        String address1 = '';
        if (user.Street != null)
            address1 += user.Street +', ';
        if (user.City != null)
            address1 += user.City +', ';
        if (user.State != null)
            address1 += user.State +' ';
        if (user.PostalCode != null)
            address1 += user.PostalCode +', ';
        if (user.Country != null)
            address1 += user.Country;
        String address2 = address1;
        address2.replace('Dantestraat', 'Ferdinand Bolstraat');
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        address2 = EncodingUtil.urlEncode(address2, 'UTF-8');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address1+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address2+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleUserResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+address2+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleResponceDistance');

        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        insert contact;
        update contact;
        Dossier__c dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Voorlopig gematched');
        insert dossier;
        
        
        insert user;
        update user;
        user = new User(Alias = 'standt', Email='stand11arduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok1@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Ferdinand Bolstraat');
        insert user;
        user.Email = 'test@test.test';
        update user;
        MatchingExtension ctrl = new MatchingExtension();
        ctrl.loadData();
        ctrl.seacrhByNumber = '00';
        ctrl.addFilterToDossiers();
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        
        ctrl.findUsers ();
        ctrl.closeMatchUser();
        ctrl.findUsers();

        ctrl.selectedType = 'All';
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        ctrl.users.get(0).isSelected = true;
        ctrl.addFilter();
        ctrl.saveDefault();
        ctrl.users.get(0).isSelected = true;
        ctrl.finishMatching();
        ctrl.setOpen();
        ctrl.getSkillFilter();
        ctrl.getTypeFilter();
        
        List <String> fields = new List <String>{'Name', 'AccountName', 'Datum' };
        List <String> dirs = new List <String>{'ASCENDING', 'DESCENDING'};
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiled();
            }
        }
      
        
        ctrl.sortByFiledVoor();
        fields = new List <String>{'Name', 'Skill', 'Address', 'uren','Mogelijk', 'type', 'Voorkeur' };
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiledUser();
            }
        }
     
 
        Test.stopTest();
    }
     @isTest static void test_method_two4() {
        TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test');
        insert account;
        Contact contact = new Contact(LastName = 'TestC', AccountId = account.id, OtherStreet = 'Dantestraat', 
                                    OtherCity = 'Amsterdam', OtherPostalCode = '3076 KJ', OtherCountry = 'Nederland' );
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
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'System Admin' limit 1];
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        String address1 = '';
        if (user.Street != null)
            address1 += user.Street +', ';
        if (user.City != null)
            address1 += user.City +', ';
        if (user.State != null)
            address1 += user.State +' ';
        if (user.PostalCode != null)
            address1 += user.PostalCode +', ';
        if (user.Country != null)
            address1 += user.Country;
        String address2 = address1;
        address2.replace('Dantestraat', 'Ferdinand Bolstraat');
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        address2 = EncodingUtil.urlEncode(address2, 'UTF-8');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address1+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address2+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleUserResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+address2+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleResponceDistance');

        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        insert contact;
        update contact;
        Dossier__c dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Voorlopig gematched');
        insert dossier;
        
        
        insert user;
        update user;
        user = new User(Alias = 'standt', Email='stand11arduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok1@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Ferdinand Bolstraat');
        insert user;
        user.Email = 'test@test.test';
        update user;
        MatchingExtension ctrl = new MatchingExtension();
        ctrl.loadData();
        ctrl.seacrhByNumber = '00';
        ctrl.addFilterToDossiers();
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        
        ctrl.findUsers ();
        ctrl.closeMatchUser();
        ctrl.findUsers();

        ctrl.selectedType = 'All';
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        ctrl.users.get(0).isSelected = true;
        ctrl.addFilter();
        ctrl.saveDefault();
        ctrl.users.get(0).isSelected = true;
        ctrl.finishMatching();
        ctrl.setOpen();
        ctrl.getSkillFilter();
        ctrl.getTypeFilter();
        
        List <String> fields = new List <String>{'Name', 'AccountName' };
        List <String> dirs = new List <String>{'ASCENDING', 'DESCENDING'};
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiled();
            }
        }
      
        
        ctrl.sortByFiledVoor();
        fields = new List <String>{'Name', 'Skill', 'Address', 'uren','Mogelijk', 'type', 'Voorkeur' };
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiledUser();
            }
        }
       
        
        
 
        Test.stopTest();
    }
     @isTest static void test_method_two5() {
        TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test');
        insert account;
        Contact contact = new Contact(LastName = 'TestC', AccountId = account.id, OtherStreet = 'Dantestraat', 
                                    OtherCity = 'Amsterdam', OtherPostalCode = '3076 KJ', OtherCountry = 'Nederland' );
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
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'System Admin' limit 1];
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        String address1 = '';
        if (user.Street != null)
            address1 += user.Street +', ';
        if (user.City != null)
            address1 += user.City +', ';
        if (user.State != null)
            address1 += user.State +' ';
        if (user.PostalCode != null)
            address1 += user.PostalCode +', ';
        if (user.Country != null)
            address1 += user.Country;
        String address2 = address1;
        address2.replace('Dantestraat', 'Ferdinand Bolstraat');
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        address2 = EncodingUtil.urlEncode(address2, 'UTF-8');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address1+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address2+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleUserResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+address2+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleResponceDistance');

        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        insert contact;
        update contact;
        Dossier__c dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Voorlopig gematched');
        insert dossier;
        
        
        insert user;
        update user;
        user = new User(Alias = 'standt', Email='stand11arduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok1@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Ferdinand Bolstraat');
        insert user;
        user.Email = 'test@test.test';
        update user;
        MatchingExtension ctrl = new MatchingExtension();
        ctrl.loadData();
        ctrl.seacrhByNumber = '00';
        ctrl.addFilterToDossiers();
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        
        ctrl.findUsers ();
        ctrl.closeMatchUser();
        ctrl.findUsers();

        ctrl.selectedType = 'All';
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        ctrl.users.get(0).isSelected = true;
        ctrl.addFilter();
        ctrl.saveDefault();
        ctrl.users.get(0).isSelected = true;
        ctrl.finishMatching();
        ctrl.setOpen();
        ctrl.getSkillFilter();
        ctrl.getTypeFilter();
        
        List <String> fields = new List <String>{'Name' };
        List <String> dirs = new List <String>{'ASCENDING', 'DESCENDING'};
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiled();
            }
        }
      
        
        ctrl.sortByFiledVoor();
        fields = new List <String>{'Name', 'Skill', 'Address', 'uren','Mogelijk', 'type', 'Voorkeur' };
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiledUser();
            }
        }
        
        
        
 
        Test.stopTest();
    }
         @isTest static void test_method_two6() {
        TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test');
        insert account;
        Contact contact = new Contact(LastName = 'TestC', AccountId = account.id, OtherStreet = 'Dantestraat', 
                                    OtherCity = 'Amsterdam', OtherPostalCode = '3076 KJ', OtherCountry = 'Nederland' );
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
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'System Admin' limit 1];
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        String address1 = '';
        if (user.Street != null)
            address1 += user.Street +', ';
        if (user.City != null)
            address1 += user.City +', ';
        if (user.State != null)
            address1 += user.State +' ';
        if (user.PostalCode != null)
            address1 += user.PostalCode +', ';
        if (user.Country != null)
            address1 += user.Country;
        String address2 = address1;
        address2.replace('Dantestraat', 'Ferdinand Bolstraat');
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        address2 = EncodingUtil.urlEncode(address2, 'UTF-8');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address1+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address2+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleUserResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+address2+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleResponceDistance');

        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        insert contact;
        update contact;
        Dossier__c dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Voorlopig gematched');
        insert dossier;
        
        
        insert user;
        update user;
        user = new User(Alias = 'standt', Email='stand11arduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok1@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Ferdinand Bolstraat');
        insert user;
        user.Email = 'test@test.test';
        update user;
        MatchingExtension ctrl = new MatchingExtension();
        ctrl.loadData();
        ctrl.seacrhByNumber = '00';
        ctrl.addFilterToDossiers();
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        
        ctrl.findUsers ();
        ctrl.closeMatchUser();
        ctrl.findUsers();

        ctrl.selectedType = 'All';
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        ctrl.users.get(0).isSelected = true;
        ctrl.addFilter();
        ctrl.saveDefault();
        ctrl.users.get(0).isSelected = true;
        ctrl.finishMatching();
        ctrl.setOpen();
        ctrl.getSkillFilter();
        ctrl.getTypeFilter();
        
        List <String> fields = new List <String>{'OtherAddress' };
        List <String> dirs = new List <String>{'ASCENDING', 'DESCENDING'};
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiled();
            }
        }
      
        
        ctrl.sortByFiledVoor();
        fields = new List <String>{'Name', 'Skill', 'Address', 'uren','Mogelijk', 'type', 'Voorkeur' };
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiledUser();
            }
        }
        
        
        
 
        Test.stopTest();
    }
         @isTest static void test_method_two7() {
        TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test');
        insert account;
        Contact contact = new Contact(LastName = 'TestC', AccountId = account.id, OtherStreet = 'Dantestraat', 
                                    OtherCity = 'Amsterdam', OtherPostalCode = '3076 KJ', OtherCountry = 'Nederland' );
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
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'System Admin' limit 1];
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        String address1 = '';
        if (user.Street != null)
            address1 += user.Street +', ';
        if (user.City != null)
            address1 += user.City +', ';
        if (user.State != null)
            address1 += user.State +' ';
        if (user.PostalCode != null)
            address1 += user.PostalCode +', ';
        if (user.Country != null)
            address1 += user.Country;
        String address2 = address1;
        address2.replace('Dantestraat', 'Ferdinand Bolstraat');
        address1 = EncodingUtil.urlEncode(address1, 'UTF-8');
        address2 = EncodingUtil.urlEncode(address2, 'UTF-8');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address1+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleContactResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/geocode/json?address='+address2+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleUserResponce');
        multimock.setStaticResource('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+address2+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU', 'GoogleResponceDistance');

        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        insert contact;
        update contact;
        Dossier__c dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched');
        insert dossier;
        dossier = new Dossier__c(Client__c = contact.id, Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Voorlopig gematched');
        insert dossier;
        
        
        insert user;
        update user;
        user = new User(Alias = 'standt', Email='stand11arduser@testorg.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='Ok1@test.test', 
                        Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Ferdinand Bolstraat');
        insert user;
        user.Email = 'test@test.test';
        update user;
        MatchingExtension ctrl = new MatchingExtension();
        ctrl.loadData();
        ctrl.seacrhByNumber = '00';
        ctrl.addFilterToDossiers();
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        
        ctrl.findUsers ();
        ctrl.closeMatchUser();
        ctrl.findUsers();

        ctrl.selectedType = 'All';
        ctrl.unmatchedDossiers.get(0).isSelected = true;
        ctrl.users.get(0).isSelected = true;
        ctrl.addFilter();
        ctrl.saveDefault();
        ctrl.users.get(0).isSelected = true;
        ctrl.finishMatching();
        ctrl.setOpen();
        ctrl.getSkillFilter();
        ctrl.getTypeFilter();
        
        List <String> fields = new List <String>{'End' };
        List <String> dirs = new List <String>{'ASCENDING', 'DESCENDING'};
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiled();
            }
        }
      
        
        ctrl.sortByFiledVoor();
        fields = new List <String>{'Name', 'Skill', 'Address', 'uren','Mogelijk', 'type', 'Voorkeur' };
        for (String dir: dirs) {
            for (String f: fields) {
                ctrl.sortDirection = dir;
                ctrl.sortField = f;
                ctrl.sortByFiledUser();
            }
        }
        
        
        
 
        Test.stopTest();
    }*/
}