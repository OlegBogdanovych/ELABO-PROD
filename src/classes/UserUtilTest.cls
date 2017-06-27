@isTest
public class UserUtilTest {
    
    @isTest public static void test_method_one() {
        
        List<Group> accessToDossiersGroup = [Select Name, DeveloperName 
                                            From Group 
                                            where DeveloperName = 'access_to_dossiers' 
                                            LIMIT 1];
        if(accessToDossiersGroup.isEmpty()) {
            Group testGroup = new Group();
            testGroup.Name = 'access to dossiers';
            testGroup.DeveloperName = 'access_to_dossiers';
            insert testGroup;
        }
        Profile adminProf = [select Id from Profile where Name = 'System administrator' or Name = 'Systeembeheerder'];
        User admin = new User(Alias = 'standta', Email='standarduser@testorg.coma',
                            EmailEncodingKey='UTF-8', LastName='TestingA', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = adminprof.Id,Kostenplaats__c='00001',
                            TimeZoneSidKey='America/Los_Angeles', UserName='aOk@test.test', 
                            Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
        insert admin;
        List<Profile> profilesManagement = [SELECT Id FROM Profile WHERE Name='Backoffice medewerker' limit 1]; //Management Team
        List<Profile> profilesProfIntern = [SELECT Id FROM Profile WHERE Name='Professional intern' limit 1];
        Test.startTest();
        System.debug('Start test');
        if(!profilesManagement.isEmpty() && !profilesProfIntern.isEmpty() ){
            System.debug('after if');
            User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = profilesManagement[0].Id,Kostenplaats__c='00001',
                            TimeZoneSidKey='America/Los_Angeles', UserName='Ok@test.test', 
                            Label__c = 'Elabo', City='Amsterdam', Country='Nederland', Street = 'Dantestraat', PostalCode='3076 KJ');
            insert user;
            user.ProfileId = profilesProfIntern[0].id;
            update user;
            
        System.runAs (admin){
            TestData.init_custom_settings();
            Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test',  Send_request_to_TF__c  = false, Debiteurnummer__c = '1010101', Betalingsconditie__c = 2);
            insert account;
            Contact c = new Contact (LastName = 'Test' , AccountId = account.id);
            insert c;
            Dossier__c dossier = new Dossier__c(Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched', handler__c = user.id , Client__c = c.Id, Soort_onderzoek__c = 'ket',
                ClosedDate__c = date.today(), Invoice_is_sent__c = true, Contactpersoon_opdrachtgever__c = c.id, Straat__c = 'Street', Postcode__c = '79888', Plaats__c =  'Plaats',
                Datum_Binnenkomst__c = date.today(), Ingangsdatum__c = date.today());
            GoogleHttpCalloutMockTest.runMockUp();
            insert dossier;
        
           update user;
        }
            System.debug([select Id, UserOrGroupId from Dossier__Share ]); 
            System.assertNotEquals(0,[select Id from Dossier__Share ].size(),'handler should have access to dossier'); 
        }
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
    
    }
    
}