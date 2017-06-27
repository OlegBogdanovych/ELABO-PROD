public with sharing class RemoveDossierExtension {
    public Dossier__c dos {get;set;}
    public RemoveDossierExtension(ApexPages.StandardController controller) {
        dos = [select Id, Handler__c from Dossier__c where id =: controller.getId()];
    }
    public PageReference redirectBack() {
        try {
            dos.Status__c = 'Unmatched';
            dos.Handler__c = null;
            System.debug('TO UPDATE ' + dos);
            update dos;
            List <DossierProduct__c> prods = [select Id from DossierProduct__c where Dossier__c =: dos.id];
            for (DossierProduct__c pr: prods) {
                pr.Tasks_are_created__c = false;
            }
            update prods;
            List <Task> tasks = [select Id from Task where WhatId =: dos.Id];
            System.debug('TO DELETE' + tasks.size() + ' ' + tasks  );
            delete tasks;
            return new PageReference('/'+dos.id);
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}