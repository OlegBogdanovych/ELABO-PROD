public with sharing class AccountDao {
  public static Account getParentAccount(Id accountId) {
    return [select Id, Name, BillingCIty, ShippingCity, BillingCountry, ShippingCountry, 
          BillingStreet, ShippingStreet, BillingPostalCode, ShippingPostalCode, Debiteurnummer__c, KVK_Nummer__c, Factuur_E_mail__c, Ter_attentie_van__c, Betalingsconditie__c from Account where id=: accountId];
  }
  public static List<Account> getParentAccounts(Set<Id> accountIds) {
    return [select  Id, RecordTypeId, Name, Website, Phone, E_mail__c, BillingPostalCode, ShippingPostalCode, Factuur_E_mail__c, Betalingsconditie__c,Ter_attentie_van__c, KVK_Nummer__c,
            BillingCity, ShippingCity, Debiteurnummer__c ,  BillingStreet, ShippingStreet, RecordType.Name
          from Account where id in: accountIds];
  }
}