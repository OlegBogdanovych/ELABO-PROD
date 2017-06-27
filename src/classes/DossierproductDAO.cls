public with sharing class DossierproductDAO {
    public static Map<String, Task_types__c> types = Task_types__c.getAll();
    public static List<Dossierproduct__c> getDossierProductsByDossierId (Id dossierid) {
        return [select Id, Product__c, Product__r.Rit_Registratie__c, Product__r.Name, Tarief__c , Vergoeding_per_KM__c, Product_exeption__c, 
        			Product_exeption__r.Kortingspercentage_uurtarieven__c, Product_exeption__r.Kortingsperecentage_vaste_tarieven__c,
                    Product__r.Tariefsoort__c, Product__r.Uurtarief__c, Product__r.Vaste_prijs__c, Product__r.Quantity_invoice__c 
                    from Dossierproduct__c where Dossier__c =: dossierid];
    }

    //Get All Dossierproduct__c with Product__r and Product_exeption__r Fields(From Custom Settings) Where Dossier Id the same.
    public static List <Dossierproduct__c> getDossierPrWithPRFieldsByDosId (Set<Id> dossierIds){
        String fields = '';
        String query = '';
        for (Task_types__c taskType: types.values()) {
        	if(!fields.contains(taskType.Account_Related__c) 
        		&& (taskType.Account_Related__c != null && taskType.Account_Related__c != '')){
        		fields += 'Product_exeption__r.' + taskType.Account_Related__c + ', ';
        	}
        	if(!fields.contains(taskType.AccountField__c) 
        		&& (taskType.AccountField__c != null && taskType.AccountField__c != '')){
        		fields += 'Product_exeption__r.' + taskType.AccountField__c + ', ';
        	}
        	if(!fields.contains(taskType.Name) 
        		&& (taskType.Name != null && taskType.Name != '')){
        		fields += 'Product__r.' + taskType.Name + ', ';
        	}
        	if(!fields.contains(taskType.RelatedField__c) 
        		&& (taskType.RelatedField__c != null && taskType.RelatedField__c != '')){
        		fields += 'Product__r.' + taskType.RelatedField__c + ', ';
        	}
        }
        fields = fields.substring(0, fields.length()-2);
        System.debug('**** GetDossierPrWithPRFieldsByDosId = ' + fields);
        query = 'SELECT Id, Product__c, Product__r.Name, Dossier__c, ' + fields + ' FROM Dossierproduct__c WHERE Dossier__c IN: dossierIds';
        
        return Database.Query(query);
    }
}