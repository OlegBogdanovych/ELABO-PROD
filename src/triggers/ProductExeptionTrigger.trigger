trigger ProductExeptionTrigger on Product_Exeption__c (before insert, 
  before update, 
  before delete, 
  after insert, 
  after update, 
  after delete, 
  after undelete) {

    ProductExeptionUtil.entry(new TriggerParams(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                              trigger.isUndelete, trigger.new, trigger.old, trigger.newMap, trigger.oldMap));
}