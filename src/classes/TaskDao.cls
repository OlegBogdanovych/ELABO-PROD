public class TaskDao {
    public static Map<String, Task_types__c> types = Task_types__c.getAll();
    public static  List <Task> getTasksByDossierId (Id dossierId) {
        return [select Id, Aantal_Kilometers_gereden__c, Aantal_uur__c, 
                    Uursoort__c, Datum__c, Reden__c, Datum_gereden__c, RecordTypeId, RecordType.Name 
                from Task 
                where WhatId =: dossierId and RecordType.Name in ('Kilometerregistratie','Urenregistratie') 
                order by CreatedDate desc];
    }
    public static List <Product__c> getProductsTaskTypebyPId (Set<Id> productIds){
        String fields = '';
        for (String str: types.keySet()) {
            fields+=str + ', ';
        }
        for (Task_types__c taskType: types.values()) {
            fields+=taskType.RelatedField__c + ', ';
        }
        fields = fields.substring(0, fields.length()-2);
        String query = 'select Id, ' + fields + ' from Product__c where id in: productIds';
        
        return Database.Query(query);
    }
}