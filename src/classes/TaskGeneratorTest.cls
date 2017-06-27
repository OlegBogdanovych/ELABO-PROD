@isTest
private class TaskGeneratorTest {
    
    @testSetup
    static void taskSetup(){

        TestData.init_custom_settings();
        Account account = new Account(Factuur_E_mail__c = 'test@test.com',Name='Test',  Send_request_to_TF__c  = false, Debiteurnummer__c = '1010101', Betalingsconditie__c = 2);
        insert account;
        Contact c = new Contact (LastName = 'Test' , AccountId = account.id);
        insert c;
        Dossier__c dossier = new Dossier__c(Relatie__c = account.id, Label__c = 'Elabo', Status__c = 'Unmatched', handler__c = UserInfo.getUserId() , Client__c = c.Id, Soort_onderzoek__c = 'ket',
            ClosedDate__c = date.today(), Invoice_is_sent__c = true, Contactpersoon_opdrachtgever__c = c.id, Straat__c = 'Street', Postcode__c = '79888', Plaats__c =  'Plaats',
            Datum_Binnenkomst__c = date.today(), Ingangsdatum__c = date.today());
        GoogleHttpCalloutMockTest.runMockUp();
        insert dossier;
       
        dossier.handler__c = [select Id from User where isActive = true limit 1].id;
        dossier.Status__c = 'Gesloten';
        GoogleHttpCalloutMockTest.runMockUp();
        update dossier;
        Product__c product = new Product__c(Afspraak_maken_met_partijen__c = true, Bewaken_vervolgadvies__c = true, Versturen_eindrapport__c = true,
                                            Vervolgafspraak__c = true, Tussenrapportage__c = true, Doorlooptijd_in_dagen__c = 10,
                                            Binnen_aantal_uur_na_aanmelding__c = 2, Concept_binnen_hoeveel_dagen_voorleggen__c = 10,
                                            Concept_rapportage_voorleggen__c = true, Aantal_maanden_na_afronden_dossier__c = 1, 
                                            Binnen_hoeveel_dagen_na_bezoekdatum__c = 2, Wanneer_binnen_de_doorlooptijd_verzenden__c = 25, 
                                            Hoeveel_dagen_verzenden__c = 2, Minimaal_aantal_afspraken__c = 2, Uurtarief__c = 0);
        insert product;
        Product_Exeption__c prEx = new Product_Exeption__c(Doorlooptijd_in_werkdagen__c = 30, Account__c = account.id, Product__c = product.id);

        insert prEx;
        Dossierproduct__c pr = new Dossierproduct__c(Dossier__c = dossier.id, Product__c = product.id, Product_Exeption__c= prEx.id);

        insert pr;

    }



    @isTest static void testCreatedTasks() {
        System.assertEquals(30, [select Id, Doorlooptijd_in_werkdagen__c  from DossierProduct__c].Doorlooptijd_in_werkdagen__c  );
        Dossier__c dossier = [SELECT Id, Relatie__c, Status__c, handler__c, Client__c, Soort_onderzoek__c,
            ClosedDate__c, Invoice_is_sent__c, Contactpersoon_opdrachtgever__c, Straat__c, Postcode__c, Plaats__c,
            Datum_Binnenkomst__c, Ingangsdatum__c FROM Dossier__c WHERE Postcode__c =: '79888'];
        List <Task> tasks = [select Id, RecordType.ID, ActivityDate, RecordType.Name from Task where WhatId =: dossier.id];

        System.debug('[***] tasks '+ tasks.size() + ' ' + tasks);
        
        Map <String, List<Task>> tasksPerRecordType = new   Map <String, List<Task>>();
        for (Task task: tasks) {
            if (tasksPerRecordType.containsKey(task.RecordType.Name)) {
                tasksPerRecordType.get(task.RecordType.Name).add(task);
            } else {
                tasksPerRecordType.put(task.RecordType.Name, new List <Task>{task});
            }
        }

        System.assertEquals(1, tasksPerRecordType.get('Afspraak maken met partijen').size());
        System.assertEquals(1, tasksPerRecordType.get('Bewaken vervolgadvies').size());
        //System.assertEquals(1, tasksPerRecordType.get('Versturen eindrapport').size());
        //Test.startTest();
        Task task = [select Id from Task where WhatId =: dossier.id and recordType.Name = 'Afspraak maken met partijen'];
        task.Status = 'Completed';
        task.Afspraakdatum__c = date.today();
        task.Tijdstip__c = '10:00';
        task.Description = 'Lore Ipsum';
        task.Email_contactpersoon_opdrachtgever__c  = 'test@test.test';
        
        GoogleHttpCalloutMockTest.runMockUp();
        update task;


        //Test.stopTest();


        //tasks = [select Id from Task where WhatId =: dossier.id and recordType.Name in ('Tussenrapportage', 'Versturen eindrapport')];
        //System.assertEquals(4, tasks.size());
        
    }
    }