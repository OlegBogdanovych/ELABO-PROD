@isTest
public class DocumentTemplateExtensionTest {
    
    @isTest static void test_method_one() {
    TestData.init_custom_settings();
        TestData.init_TF_Ledger_Settings();
        TestData.init_Remote_Api_Settings();
        GoogleHttpCalloutMockTest.runMockUp();

        Account acc = new Account(Name = 'Test',Factuur_E_mail__c = 'test@test.com');
        insert acc;
        Contact c = new Contact (LastName = 'Test' , AccountId = acc.id);
        insert c;
        Dossier__c dos = new Dossier__c (Relatie__c = acc.Id, Contactpersoon_opdrachtgever__c = c.id, Datum_Binnenkomst__c = date.today());
        insert dos;
        rsdoc__Document_Action__c template = new rsdoc__Document_Action__c(rsdoc__Template_Document_ID__c = 'test', rsdoc__Template_Name__c = 'test');
        insert template;
        ApexPages.StandardController ctrl = new ApexPages.StandardController(dos);
        DocumentTemplateExtension ext = new DocumentTemplateExtension(ctrl);
        ext.getTemplates();
        ext.selectedTemplate = template.id;
        ext.createTemplate();
        ext.reload();
    }
}