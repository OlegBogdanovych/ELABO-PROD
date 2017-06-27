@isTest
public class ResultExtensionTest {
    
    @isTest public static void resultTest() {
        GoogleHttpCalloutMockTest.runMockUp();

        TestData.init_Custom_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name = 'Test');
        insert account;
        Contact contact = new Contact (LastName = 'Test' , AccountId = account.id);
        insert contact;
        Dossier__c dossier = new Dossier__c(Relatie__c = account.id,Contactpersoon_opdrachtgever__c = contact.id, Datum_Binnenkomst__c = date.today());
        insert dossier;
        Product__c product = new Product__c(Name = 'Test', AO_percentage_direct_na_onderzoek__c = true, Uurtarief__c = 0, 
                                            Meldingsfrequentie_actueel__c = true, Vervolginterventie_aangeboden__c = true);
        insert product;
        Dossierproduct__c dosProd = new Dossierproduct__c(Dossier__c = dossier.id, Product__c = product.Id);
        insert dosProd;
        System.debug(dosProd + ' ' + product);
        ResultExtension resCtrl = new ResultExtension(new ApexPages.StandardController(dossier));
        Integer i = 0;
        for (ResultExtension.FieldVisibility res: resCtrl.visibilityByFieldName) {
            System.debug(res.visibility);
            if (res.visibility) {
                i++;
            }
        }
        System.assertEquals(4, i);
        resCtrl.saveDossier();

    }

    @isTest public static void resultTestWithOverride() {
        GoogleHttpCalloutMockTest.runMockUp();

        TestData.init_Custom_Settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name = 'Test');
        insert account;
        Contact contact = new Contact (LastName = 'Test' , AccountId = account.id);
        insert contact;
        Dossier__c dossier = new Dossier__c(Relatie__c = account.id,Contactpersoon_opdrachtgever__c = contact.id, 
                                            Datum_Binnenkomst__c = date.today() , Product_Exception__c = 'Relatie');
        insert dossier;
        Product__c product = new Product__c(Name = 'Test', AO_percentage_direct_na_onderzoek__c = false, Uurtarief__c = 0, 
                                            Meldingsfrequentie_actueel__c = false, Vervolginterventie_aangeboden__c = false);
        insert product;
        Product_Exeption__c productEx = new Product_Exeption__c(AO_percentage_direct_na_onderzoek__c = true, 
                                            Product__c = product.id, Account__c = account.id,
                                            Meldingsfrequentie_actueel__c = false, Vervolginterventie_aangeboden__c = true);
        insert productEx;
        Dossierproduct__c dosProd = new Dossierproduct__c(Dossier__c = dossier.id, Product__c = product.Id);
        insert dosProd;
        System.debug(dosProd + ' ' + product);
        ResultExtension resCtrl = new ResultExtension(new ApexPages.StandardController(dossier));
        Integer i = 0;
        for (ResultExtension.FieldVisibility res: resCtrl.visibilityByFieldName) {
            System.debug(res.visibility);
            if (res.visibility) {
                i++;
            }
        }
        System.assertEquals(3, i);
        resCtrl.saveDossier();

    }
    
    
}