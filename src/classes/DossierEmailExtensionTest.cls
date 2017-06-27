@isTest
private class DossierEmailExtensionTest {
    
    @isTest static void testEmailSend() {
        init_Custom_Settings();
        GoogleHttpCalloutMockTest.runMockUp();
        

        PageReference pageRef = Page.DossierEmail;
        Test.setCurrentPage(pageRef);
        Test.startTest();
Account account = new Account(Name='Test', Factuur_E_mail__c = 'test@test.com');
        insert account;
        Contact c = new Contact (LastName = 'Test' , AccountId = account.id);
        insert c;
        RecordType rT = [select Id from RecordType where Name = 'Elabo' and SobjectType = 'Dossier__c'];
        Dossier__c dossier = new Dossier__c( Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched', RecordTypeId =rt.id, Contactpersoon_opdrachtgever__c = c.id, Datum_Binnenkomst__c = date.today() );
       insert dossier;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(dossier);
        DossierEmailExtension dossExt = new DossierEmailExtension(sc);
        

        

            dossExt.toAddress = 'test@mail.com;test2@mail.com';
            dossExt.ccAddress = 'test3@mail.com;test4@mail.com';
            dossExt.bccAddress = 'test5@mail.com;test6@mail.com';
            dossExt.emailSubject = 'test subject';

            dossier.EmailBody__c = 'Test E,ail Body';

            dossExt.sendMail();
        Test.stopTest();
    }

    @isTest static void testEmailSend_WrongCC() {
        init_Custom_Settings();
        GoogleHttpCalloutMockTest.runMockUp();

        Account account = new Account(Name='Test', Factuur_E_mail__c = 'test@test.com');
        insert account;
         Contact c = new Contact (LastName = 'Test' , AccountId = account.id);
        insert c;
        RecordType rT = [select Id from RecordType where Name = 'Elabo' and SobjectType = 'Dossier__c'];
        Dossier__c dossier = new Dossier__c( Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched', RecordTypeId =rt.id, Contactpersoon_opdrachtgever__c = c.id, Datum_Binnenkomst__c = date.today() );
        insert dossier;

        ApexPages.StandardController sc = new ApexPages.StandardController(dossier);
        DossierEmailExtension dossExt = new DossierEmailExtension(sc);
        
        PageReference pageRef = Page.DossierEmail;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        
            dossExt.toAddress = 'test@mail.com;test2@mail.com';
            dossExt.ccAddress = 'test3@mailcom;test4@mail.com';
            dossExt.bccAddress = 'test5@mail.com;test6@mail.com';
            dossExt.emailSubject = 'test subject';

            dossier.EmailBody__c = 'Test E,ail Body';

            dossExt.sendMail();
        Test.stopTest();
    }

    @isTest static void testEmailSend_wrongBcc() {
        init_Custom_Settings();
        GoogleHttpCalloutMockTest.runMockUp();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test');
        insert account;
        Contact c = new Contact (LastName = 'Test' , AccountId = account.id);
        insert c;
        RecordType rT = [select Id from RecordType where Name = 'Elabo' and SobjectType = 'Dossier__c'];
        Dossier__c dossier = new Dossier__c( Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched', RecordTypeId =rt.id, Contactpersoon_opdrachtgever__c = c.id, Datum_Binnenkomst__c = date.today() );
        insert dossier;

        ApexPages.StandardController sc = new ApexPages.StandardController(dossier);
        DossierEmailExtension dossExt = new DossierEmailExtension(sc);
        
        PageReference pageRef = Page.DossierEmail;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        
            dossExt.toAddress = 'test@mail.com;test2@mail.com';
            dossExt.ccAddress = 'test3@mail.com;test4@mail.com';
            dossExt.bccAddress = 'test5@mailcom;test6@mail.com';
            dossExt.emailSubject = 'test subject';

            dossier.EmailBody__c = 'Test E,ail Body';

            dossExt.sendMail();
        Test.stopTest();
    }

    public static void init_Custom_Settings() {

        List <TF_Ledger_Settings__c> ledgers = new List <TF_Ledger_Settings__c>();
        ledgers.add(new TF_Ledger_Settings__c(Name = 'Turnover Elabo', account_number__c = '8080'));
        ledgers.add(new TF_Ledger_Settings__c(Name = 'Turnover Kie', account_number__c = '8080'));
        ledgers.add(new TF_Ledger_Settings__c(Name = 'Turnover Mediation', account_number__c = '8080'));
        ledgers.add(new TF_Ledger_Settings__c(Name = 'Debtor', account_number__c = '8080'));
        insert ledgers;

        List<Remote_API_Setting__c> rAS = new List<Remote_API_Setting__c>();
        
        Map<String, Remote_API_Setting__c> remoteApiSettings = Remote_API_Setting__c.getAll();
        
        if(!remoteApiSettings.containsKey('Twinfield Account')) {
          rAS.add(new Remote_API_Setting__c(Name='Twinfield Account', 
          value__c='271607002'));
        }
        
        if(!remoteApiSettings.containsKey('Twinfield Organisation')) {
          rAS.add(new Remote_API_Setting__c(Name='Twinfield Organisation', 
          value__c=' DJL-MKB'));
        }
        if(!remoteApiSettings.containsKey('Twinfield Office')) {
          rAS.add(new Remote_API_Setting__c(Name='Twinfield Office', 
          value__c='2716072'));
        }
        if(!remoteApiSettings.containsKey('Twinfield Pw')) {
          rAS.add(new Remote_API_Setting__c(Name='Twinfield Pw', 
          value__c='@lopK39!T'));
        }
        

        insert rAS;

        Vat_code__c vat = new Vat_code__c(Name = 'VH21'        );
        insert vat;

        Task_types__c type = new Task_types__c(name = 'Afspraak_maken_met_partijen__c' , Record_Type_Name__c = 'Afspraak maken met partijen',
                            RelatedField__c = 'Binnen_aantal_uur_na_aanmelding__c', 
                            Account_Related__c = 'Binnen_aantal_uur_na_aanmelding__c',
                            AccountField__c = 'Afspraak_maken_met_partijen__c',
                            TaskSubject__c = 'Maak afspraak met partijen'
                            );
        insert type;
        type = new Task_types__c(name = 'Bewaken_vervolgadvies__c' , Record_Type_Name__c = 'Bewaken vervolgadvies',
                            RelatedField__c = 'Aantal_maanden_na_afronden_dossier__c', 
                            Account_Related__c = 'Aantal_maanden_na_afronden_dossier__c',
                            AccountField__c = 'Bewaken_vervolgadvies__c',
                            TaskSubject__c = 'Nabellen'
                            );
        insert type;
        type = new Task_types__c(name = 'Tussenrapportage__c' , Record_Type_Name__c = 'Tussenrapportage',
                            RelatedField__c = 'Hoeveel_dagen_verzenden__c', 
                            Account_Related__c = 'Hoeveel_dagen_na_bezoekdatum_verzenden__c',
                            AccountField__c = 'Tussenrapportage__c',
                            TaskSubject__c = 'Verzend tussenrapportage'
                            );
        insert type;
        type = new Task_types__c(name = 'Versturen_eindrapport__c' , Record_Type_Name__c = 'Versturen eindrapport',
                            RelatedField__c = 'Doorlooptijd_in_dagen__c', 
                            Account_Related__c = 'Doorlooptijd_in_werkdagen__c',
                            AccountField__c = 'Versturen_eindrapport__c',
                            TaskSubject__c = 'Verstuur eindrapport'

                            );
        insert type;
        type = new Task_types__c(name = 'Vervolgafspraak__c' , Record_Type_Name__c = 'Vervolgafspraak',
                            RelatedField__c = 'Minimaal_aantal_afspraken__c', 
                            Account_Related__c = 'Afspraak_maken_met_partijen__c',
                            AccountField__c = 'Minimaal_aantal_afspraken__c',
                            TaskSubject__c = 'Maak vervolgafspraak'

                            );
        insert type;
        type = new Task_types__c(name = 'Concept_rapportage_voorleggen__c' , Record_Type_Name__c = 'Concept rapportage voorleggen',
                            RelatedField__c = 'Concept_binnen_hoeveel_dagen_voorleggen__c', 
                            Account_Related__c = 'Concept_binnen_hoeveel_dagen_voorleggen__c',
                            AccountField__c = 'Concept_rapportage_voorleggen__c',
                            TaskSubject__c = 'Change Afwijkende product afspraken'

                            );
        insert type;
    }
    
}