@isTest
public class CreateDossierProductTest {
  
  @isTest public static void createDosProduct() {
    TestData.init_Custom_Settings();
    GoogleHttpCalloutMockTest.runMockUp();

    Account account = new Account(Name='Test', Factuur_E_mail__c = 'test@test.com');
    insert account;
    RecordType rT = [select Id from RecordType where Name = 'Elabo' and SobjectType = 'Dossier__c'];
    RecordType rTPr = [select Id from RecordType where Name = 'Elabo' and SobjectType = 'Product__c'];
    Contact c = new Contact (LastName = 'Test' , AccountId = account.id);
        insert c;
    Dossier__c dossier = new Dossier__c( Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched', RecordTypeId =rt.id, Contactpersoon_opdrachtgever__c = c.id, Datum_Binnenkomst__c = date.today());
    insert dossier;
    ApexPages.StandardController sc = new ApexPages.StandardController(new Dossierproduct__c(Dossier__c=dossier.id));
    CreateDossierProductExtension ctrl = new CreateDossierProductExtension(sc);
    Product__c pr = new Product__c(RecordTypeId = rTPr.id, Name = 'Test', Uurtarief__c =1);
    insert pr;
    ctrl.loadData();
    ctrl.getProducts();
    ctrl.selectedProductId = pr.id;
    ctrl.save();
    System.assertEquals(1, [select Id from Dossierproduct__c where Dossier__c =: dossier.id].size());
  }
  
  
  
}