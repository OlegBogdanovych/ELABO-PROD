public with sharing class CreateDossierProductExtension {
  public List <Product__c> productList {
    get {
      if (productList == null) {
        productList = new List <Product__c>();
      }
      return productList;
    } set;
  }
  public Id selectedProductId {get;set;}
  public List <SelectOption> getProducts(){
    List<SelectOption> options = new List <SelectOption>();
    for (Product__c product: productList) {
      options.add(new SelectOption(product.Id, product.Name));
    }
    return options;
  }
  public DossierProduct__c dossierProduct {get;set;}
  public String errorMessage {get;set;}
  public CreateDossierProductExtension(ApexPages.StandardController controller) {
    System.debug(controller.getRecord());
    dossierProduct = (DossierProduct__c) controller.getRecord();
    
  }
  public Dossier__c dossier {get;set;}
  public void loadData(){
    dossier = [select Id, RecordType.Name from Dossier__c where id=: dossierProduct.Dossier__c];
    RecordType recordType = [select Id, Name from RecordType where SobjectType ='Product__c' and Name =: dossier.RecordType.Name];
    System.debug(recordType.Name + ' ' + recordType.id + ' ' + dossier.RecordType.Name);
    productList = [select Id, Name from Product__c where RecordTypeId =: recordType.id];
    System.debug(productList.size() + ' ' + productList);
  }
  public PageReference save () {
    try {
      dossierProduct.Product__c = selectedProductId;
      insert dossierProduct;
      dossier.Product__c = selectedProductId;
      update dossier;
      return new PageReference('/'+dossierProduct.Dossier__c);
    } catch(Exception e){
      errorMessage = e.getMessage();
      return null;
    }
  }
  
}