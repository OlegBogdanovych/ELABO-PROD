public with sharing class DossierProductUtil {
    public DossierProductUtil() {
        
    }
    public static void entry(TriggerParams triggerParams) {
        List<Dossierproduct__c> triggerNew = (List<Dossierproduct__c>)triggerParams.triggerNew;
        List<Dossierproduct__c> triggerOld = (List<Dossierproduct__c>)triggerParams.triggerOld;
        Map<Id, Dossierproduct__c> oldMap = (Map<Id, Dossierproduct__c>)triggerParams.oldMap;
        Map<Id, Dossierproduct__c> newMap = (Map<Id, Dossierproduct__c>)triggerParams.newMap;
        if (triggerParams.isBefore) {
            if(triggerParams.isUpdate || triggerParams.isInsert) {
                setProductExeption(triggerNew);
                updateDossier(triggerNew, false);
            }
           
        }

        if (triggerParams.isAfter) {
            if(triggerParams.isUpdate || triggerParams.isInsert) {
                if (triggerParams.isInsert && !System.isFuture()) {
                    generateTasks(triggerNew);
                }
                
                updateDossier(triggerNew, false);
            }
        }

    }
    public static void updateDossier (List<Dossierproduct__c> products, Boolean toRemove) {
        Set <Id> productsIds = new Set <Id>();
        Set <Id> dosPrIds = new Set <Id>();
        Set <Id> dosIds = new Set <Id>();
        Set <Id> excepIds = new Set <Id>();
        for (Dossierproduct__c doPr: products) {
            productsIds.add(doPr.Product__c);
            dosIds.add(doPr.Dossier__c);
            excepIds.add(doPr.Product_Exeption__c);
            dosPrIds.add(doPr.Id);
        }
        products = [select Id, Product__c, Product__r.Doorlooptijd_in_dagen__c, Product__r.Binnen_hoeveel_dagen_na_bezoekdatum__c, Product_exeption__c , Product__r.Name,Dossier__c  from Dossierproduct__c where id in: dosPrIds ];
        Map <Id, Dossier__c> dosByIds = new Map <Id, Dossier__c>([select Id from Dossier__c where Id in: dosIds]);
        /*Map <Id, Product__c> prByIds = new Map <Id, Product__c>([select Id, Doorlooptijd_in_dagen__c, Name from Product__c where Id in: productsIds]);*/
        Map <Id, Product_Exeption__c> exByIds = new Map <Id, Product_Exeption__c>();
        if (excepIds.size() > 0){
           exByIds = new Map <Id, Product_Exeption__c>([select Id, Doorlooptijd_in_werkdagen__c, Name from Product_Exeption__c where Id in: excepIds]);
        }
        List <Dossier__c> toUpdate = new List <Dossier__c>();
        for (Dossierproduct__c doPr: products) {
            Dossier__c dos = dosByIds.get(doPr.Dossier__c);
            if (toRemove) {
                dos.Soort_onderzoek__c = null;
                toUpdate.add(dos);
            } else {
                dos.Soort_onderzoek__c = doPr.Product__r.Name;
                if ( doPr.Product__r.Doorlooptijd_in_dagen__c != null) {
                    dos.Doorlooptijd_dagen__c =  doPr.Product__r.Doorlooptijd_in_dagen__c;
                }
                //if ( doPr.Product__r.Binnen_hoeveel_dagen_na_bezoekdatum__c != null) {
                //    dos.Doorlooptijd_dagen__c =  doPr.Product__r.Binnen_hoeveel_dagen_na_bezoekdatum__c;
                //}
                if (doPr.Product_Exeption__c != null && exByIds.containsKey(doPr.Product_Exeption__c) && exByIds.get(doPr.Product_Exeption__c).Doorlooptijd_in_werkdagen__c != null ) {
                    dos.Doorlooptijd_dagen__c = exByIds.get(doPr.Product_Exeption__c).Doorlooptijd_in_werkdagen__c ;
                }
                toUpdate.add(dos);
            }
        }
        System.debug('TO UPDTAE' + toUpdate.size() + ' ' + toUpdate);
        update toUpdate;
    }
    public static void generateTasks (List<Dossierproduct__c> products) {
        Set <Id> dossierIds = new Set <Id> ();
        for (Dossierproduct__c dosProd: products){
            if (!dosProd.Tasks_are_created__c) {
                dossierIds.add(dosProd.Dossier__c);
            }
        }
         if(!System.isFuture() && !System.isScheduled() && !System.isBatch()) {
            TaskGenerator.generateTasks(dossierIds);
        }
    }
    
    public static void setProductExeption(List<Dossierproduct__c> products) {
        Set <Id> accIds = new Set <Id>();
        Set <Id> productIds = new Set <Id>();
        Set <Id> dossierIds = new Set <Id>();
        for (Dossierproduct__c dossierProduct: products) {
            productIds.add(dossierProduct.Product__c);
            
            dossierIds.add(dossierProduct.Dossier__c);
        }
        List <Dossier__c > dossiers = [Select Id, Relatie__c, Verwijzer__c, Product_exception__c from Dossier__c where id in:dossierIds];
        for (Dossier__c dos: dossiers) {
            if (dos.Product_exception__c == 'Relatie') {
                accIds.add(dos.Relatie__c);
            } else if (dos.Product_exception__c == 'Verwijzer') {
                accIds.add(dos.Verwijzer__c);
            } 
        }
        System.debug(productIds + ' ' + accIds);
        List <Product_Exeption__c> exceptions = [select Id, Account__c, Product__c from Product_Exeption__c where Account__c in:accIds  and Product__c in: productIds ];
        System.debug(exceptions );
        Map <Id, Map<id, Product_Exeption__c>> exByPrByAccountId = new Map <Id, Map<Id, Product_Exeption__c>>();
        for (Product_Exeption__c exeption: exceptions ) {
            if (exByPrByAccountId.containsKey(exeption.Account__c)) {
                exByPrByAccountId.get(exeption.Account__c).put(exeption.Product__c , exeption);
            } else {
                Map<id, Product_Exeption__c> dosByPr = new Map<id, Product_Exeption__c>();
                dosByPr.put(exeption.Product__c, exeption);
                exByPrByAccountId.put(exeption.Account__c, dosByPr);
            }
        }
        System.debug(exByPrByAccountId);
        for (Dossierproduct__c product: products) {
            if (exByPrByAccountId.containsKey(product.AccountId__c) && exByPrByAccountId.get(product.AccountId__c).containsKey(product.Product__c)) {
                product.Product_Exeption__c = exByPrByAccountId.get(product.AccountId__c).get(product.Product__c).id;
            }
        }

    }
}