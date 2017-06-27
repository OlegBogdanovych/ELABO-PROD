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
        List<Profile> profilesManagement = [SELECT Id FROM Profile WHERE Name='Management Team' limit 1];
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
        }
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
    }
    
}