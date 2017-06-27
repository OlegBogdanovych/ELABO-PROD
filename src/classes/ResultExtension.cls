public with sharing class ResultExtension {
    public Dossier__c dossier {get;set;}
    public Product__c product {get;set;}
    public String message {get;set;}
    public Boolean isError {get;set;}
    public ResultExtension(ApexPages.StandardController controller) {
        dossier = DossierDAO.getDossierById(controller.getRecord().id);
        product = ProducDAO.getproductByDossierId(dossier.id);
        product = overrideProduct(product, dossier);
        fillList();
    
    }
    
    public Product__c overrideProduct(Product__c product, Dossier__c dossier) {
        if (product != null) {
            Map<Id, Product_exeption__c> exceptionByProduct = ProductExeptionDAO.getExceptionByProduct  (dossier);
            Map<String, String> fieldsMapping = getDependencies();
            if (exceptionByProduct.containsKey(product.Id)) {
                Product_exeption__c exeption = exceptionByProduct.get(product.id);
                for (String fieldMapping: fieldsMapping.keyset()) {
                    if (exeption.get(fieldMapping) != null && (Boolean)exeption.get(fieldMapping)  ) {
                        product.put(fieldMapping, true);
                    }
                }
            }
            System.debug('overrided product');
        }
        return product;
    }
    public PageReference fillList() {
        System.debug(dossier);
        Map<String, String> fieldsMapping = getDependencies();
        String type='Dossier__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map <String, String> labelByApi = new Map <String, String>();
        for (String fieldName: fieldMap.keySet()) {
            fieldMap.get(fieldName).getDescribe().getLabel();
            labelByApi.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());

        }
        System.debug(labelByApi);
        System.debug('fieldsMapping ' + fieldsMapping );
        visibilityByFieldName = new List <FieldVisibility>();
        if (product != null) {
            for (String prodField: fieldsMapping.keySet()) {
            
                String prodNameLowerCase = prodField.toLowerCase();
                System.debug('prodField ' + prodField + ' ' + (Boolean)product.get(prodField));
                if (prodField == 'Vervolginterventie_aangeboden__c' && (Boolean)product.get(prodField) && dossier.Vervolginterventie_aangeboden__c != null 
                          && dossier.Vervolginterventie_aangeboden__c.indexOf('Ja') != -1) {
                    visibilityByFieldName.add(new FieldVisibility(fieldsMapping.get(prodField), true, labelByApi.get(prodNameLowerCase)));
                    visibilityByFieldName.add(new FieldVisibility('Type_vervolginterventie__c', true, labelByApi.get('type_vervolginterventie__c')));
                    if(dossier.Type_vervolginterventie__c != null && dossier.Type_vervolginterventie__c.indexOf('Anders') != -1) {
                        visibilityByFieldName.add(new FieldVisibility('Andere_vevolginterventie__c', true, labelByApi.get('andere_vevolginterventie__c')));
                    }
                    
                } else if (prodField == 'Re_integratie_afspraken_gemaakt__c' && (Boolean)product.get(prodField) && dossier.Re_integratie_afspraken_gemaakt__c != null 
                          && dossier.Re_integratie_afspraken_gemaakt__c.indexOf('Anders, namelijk') != -1) {
                    visibilityByFieldName.add(new FieldVisibility(fieldsMapping.get(prodField), true, labelByApi.get(prodNameLowerCase)));
                    visibilityByFieldName.add(new FieldVisibility('Andere_reintegratieafspraak__c', true, labelByApi.get('andere_reintegratieafspraak__c')));
                    

                    } else if (prodField == 'Vervolgonderzoek_noodzakelijk__c' && (Boolean)product.get(prodField) && dossier.Vervolgonderzoek_noodzakelijk__c != null 
                          && dossier.Vervolgonderzoek_noodzakelijk__c.indexOf('Ja') != -1) {
                    visibilityByFieldName.add(new FieldVisibility(fieldsMapping.get(prodField), true, labelByApi.get(prodNameLowerCase)));
                    visibilityByFieldName.add(new FieldVisibility('Wanneer_Vervolgonderzoek__c', true, labelByApi.get(' wanneer_vervolgonderzoek__c')));
                
                } else if (prodField == 'Vervolgadvies__c' && (Boolean)product.get(prodField) ) {
                   
                    System.debug(fieldsMapping.get(prodField) + ' ' +  labelByApi.get('Vervolgadvies_Picklist__c'));
                    visibilityByFieldName.add(new FieldVisibility(fieldsMapping.get(prodField), true, labelByApi.get('vervolgadvies_picklist__c')));
                    if ( dossier.Vervolgadvies_Picklist__c!= null && dossier.Vervolgadvies_Picklist__c.indexOf('Ja') != -1) {
                        visibilityByFieldName.add(new FieldVisibility('Type_Vervolgadvies__c', true, labelByApi.get('type_vervolgadvies__c')));
                        System.debug(dossier.Type_Vervolgadvies__c);
                        if(dossier.Type_Vervolgadvies__c!= null && dossier.Type_Vervolgadvies__c.indexOf('Overig') != -1) {
                            visibilityByFieldName.add(new FieldVisibility('Vervolgadvies__c', true, labelByApi.get('vervolgadvies__c')));
                        }
                    }
                    
                } else {
                    if (product.get(prodField) != null && (Boolean)product.get(prodField) ) {
                        visibilityByFieldName.add(new FieldVisibility(fieldsMapping.get(prodField), true, labelByApi.get(prodNameLowerCase)));
                    } else {
                        visibilityByFieldName.add(new FieldVisibility(fieldsMapping.get(prodField), false, labelByApi.get(prodNameLowerCase)));
                    }
                }
                
            }
            
        }
        
        
     
        visibilityByFieldName.add(new FieldVisibility('Opmerkingen__c', true, labelByApi.get('opmerkingen__c') ));
        System.debug('visibilityByFieldName ' + visibilityByFieldName);
        return null;
    }


    public Map<String, String> getDependencies () {
        List <ResultVisibility__mdt> resultsDependencies = [SELECT Id, DeveloperName, DossierField__c, MasterLabel, Label, Language, Order__c ,Prevent_for_close__c,
                                NamespacePrefix, ProductField__c, QualifiedApiName FROM ResultVisibility__mdt order by Order__c ASC NULLS LAST];
                                
        System.debug('resultsDependencies '+resultsDependencies );
        Map <String, String> dependencies = new Map <String, String>(); 
        for (ResultVisibility__mdt res: resultsDependencies) {
            dependencies.put(res.ProductField__c, res.DossierField__c);
        }
        return dependencies;
    }
    public List <FieldVisibility> visibilityByFieldName {
        get {
            if (visibilityByFieldName == null){
                visibilityByFieldName = new List <FieldVisibility>();
            }
            return visibilityByFieldName;
        } set;
    }

    public PageReference saveDossier () {
        message = '';
        isError = false;
        System.debug(dossier);
        try {
            update dossier;
            message = 'Resultaat opgeslagen.';
        } catch (Exception e) {
            isError = true;
            message = e.getMessage();
            System.debug('ERROR: ' + message);
        }
        return null;
    }

    public class FieldVisibility {
        public String fieldName {get;set;}
        public Boolean visibility {get;set;}
        public String label {get;set;}
    
        public FieldVisibility (String fieldName, Boolean visibility, String label ) {
            this.fieldName = fieldName;
            this.visibility = visibility;
            this.label = label;
            
        }
    }
}