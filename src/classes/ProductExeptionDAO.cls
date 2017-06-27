/** Author       :    Marcus Yavorskyy
*   Email        :    marcus.yavorskyy@beethree.net
*   Description  :    Class for accessing Product_Exeption__c from DB.
*   Created Date :    17.03.2017
**/


public with sharing class ProductExeptionDAO {
    //Get all TaskTypes from the Task_types__c Custom Setting.
    public static Map<String, Task_types__c> types = Task_types__c.getAll();

    //Get all Product_Exeption__c with the coresponding fields that match the accountIds and the productIds.
    public static List <Product_Exeption__c> getPrExByAccAndPrIds(Set<Id> accountIds, Set<Id> productIds){
        String fields = '';
        String query = '';
        for (Task_types__c taskType: types.values()) {
            if(!fields.contains(taskType.Account_Related__c) 
                && (taskType.Account_Related__c != null && taskType.Account_Related__c != '')){
                fields += taskType.Account_Related__c + ', ';
            }
            if(!fields.contains(taskType.AccountField__c) 
                && (taskType.AccountField__c != null && taskType.AccountField__c != '')){
                fields += taskType.AccountField__c + ', ';
            }
        }
        fields = fields.substring(0, fields.length()-2);
        query = 'SELECT Id, Account__c, Product__c, ' + fields + ' FROM Product_Exeption__c WHERE Account__c IN: accountIds AND Product__c IN: productIds';
        return Database.Query(query);

    }
    //Get all Product_Exeption__c with the coresponding fields that match the accountIds.
    public static List <Product_Exeption__c> getPrExByAccIds(Set<Id> accountIds){
        String fields = '';
        String query = '';
        for (Task_types__c taskType: types.values()) {
            if(!fields.contains(taskType.Account_Related__c) 
                && (taskType.Account_Related__c != null && taskType.Account_Related__c != '')){
                fields += taskType.Account_Related__c + ', ';
            }
            if(!fields.contains(taskType.AccountField__c) 
                && (taskType.AccountField__c != null && taskType.AccountField__c != '')){
                fields += taskType.AccountField__c + ', ';
            }
        }
        fields = fields.substring(0, fields.length()-2);
        query = 'SELECT Id, Account__c, Product__c, ' + fields + ' FROM Product_Exeption__c WHERE Account__c IN: accountIds';
        return Database.Query(query);

    }
    
    public static Map <Id, Product_Exeption__c> getExceptionByProduct (Dossier__c dossier) {
        Map <Id, Product_Exeption__c> exeptionsForDossier = new Map <Id, Product_Exeption__c>();
        String query = 'Select ';
        String type='Product_Exeption__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map <String, String> labelByApi = new Map <String, String>();
        for (String fieldName: fieldMap.keySet()) {
            query += fieldMap.get(fieldName).getDescribe().getLocalName() + ', ';
        }
        query = query.substring(0, query.length() -2 );
        
        if (dossier != null && dossier.Product_Exception__c != null) {
            Boolean makeQuery = false;
            if (dossier.Product_Exception__c == 'Verwijzer' && dossier.Verwijzer__c != null) {
                 makeQuery = true;
                 query += ' from Product_Exeption__c where Account__c = \''+dossier.Verwijzer__c +'\'';
            } else if (dossier.Product_Exception__c == 'Relatie') {
                 makeQuery = true;
                 query += ' from Product_Exeption__c where Account__c = \''+dossier.Relatie__c +'\'';
            } 
            System.debug('query ' + query);
            if (makeQuery) {
                for (Product_Exeption__c ex: Database.query(query)) {
                    exeptionsForDossier.put(ex.Product__c, ex);
                }
            }
        }         
        return exeptionsForDossier ;
    }
}