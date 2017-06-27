public class ProductExeptionUtil {
    public static void entry (TriggerParams triggerParams) {
        
        Map<Id,  Product_Exeption__c> newMap = (Map<Id, Product_Exeption__c>)triggerParams.newMap;
        Map<Id, Product_Exeption__c> oldMap = (Map<Id, Product_Exeption__c>)triggerParams.oldMap;  
        List<Product_Exeption__c> triggerNew = (List<Product_Exeption__c>)triggerParams.triggerNew; 
        List<Product_Exeption__c> triggerOld = (List<Product_Exeption__c>)triggerParams.triggerOld; 
        Set <Id> exToChange = new Set <Id>();
        if (triggerParams.isAfter) {
            if (triggerParams.isInsert) {
                  //addExceptionToDossiers(triggerNew);
            }
        }
        if (triggerParams.isAfter) {
            if (triggerParams.isInsert || triggerParams.isUpdate) {
                for (Product_Exeption__c ex: newMap.values()) {
                    /*if (oldMap != null && oldMap.containsKey(ex.Id) && oldMap.get(ex.Id).Leading_Account__c != newMap.get(ex.Id).Leading_Account__c
                            && newMap.get(ex.Id).Leading_Account__c != null){
                        exToChange.add(ex.id);
                    }*/
                    
                }
            }
            
        }
    }
   
    /*public static void addExceptionToDossiers(List <Product_Exeption__c> exceptions){
        Set <Id> accIds = new Set <Id>();
        Set <Id> productIds = new Set <Id>();
        for (Product_exeption__c exeption: exceptions) {
            accIds.add(exeption.Account__c);
            productIds.add(exeption.product__c);
        }
        List< Dossierproduct__c> dossierProducts = [select Id, Dossier__r.Relatie__c, Product__c from Dossierproduct__c where Dossier__r.Relatie__c in: accIds and Product__c in:productIds ];
        Map <Id, Map<id, List<Dossierproduct__c>>> dosProdByPrByAccountId = new Map <Id, Map<Id, List<Dossierproduct__c>>>();
        for (Dossierproduct__c dossierProduct: dossierProducts ) {
            if (dosProdByPrByAccountId.containsKey(dossierProduct.Dossier__r.Relatie__c)) {
                if ( dosProdByPrByAccountId.get(dossierProduct.Dossier__r.Relatie__c).containsKey (dossierProduct.Product__c )){
                    dosProdByPrByAccountId.get(dossierProduct.Dossier__r.Relatie__c).get(dossierProduct.Product__c ).add(dossierProduct);
                } else {
                    dosProdByPrByAccountId.get(dossierProduct.Dossier__r.Relatie__c).put(dossierProduct.Product__c, new List <DossierProduct__c>{dossierProduct});
                }
            } else {
                Map<id, List<Dossierproduct__c>> dosByPr = new Map<id, List<Dossierproduct__c>>();
                dosByPr.put(dossierProduct.Product__c, new List <DossierProduct__c>{dossierProduct});
                dosProdByPrByAccountId.put(dossierProduct.Dossier__r.Relatie__c, dosByPr);
            }
        }
        List <DossierProduct__c> dosProductToUpdate = new List <DossierProduct__c>();
        for (Product_exeption__c exeption: exceptions){
            if (dosProdByPrByAccountId.containsKey(exeption.Account__c) && dosProdByPrByAccountId.get(exeption.Account__c).containsKey(exeption.Product__c)) {
                for (DossierProduct__c dosProd:dosProdByPrByAccountId.get(exeption.Account__c).get(exeption.Product__c) ) {
                    dosProd.Product_exeption__c = exeption.Id;
                    dosProductToUpdate.add(dosProd);
                }
            }
        }
        update dosProductToUpdate;
    }*/
}