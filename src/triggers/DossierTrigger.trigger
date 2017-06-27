trigger DossierTrigger on Dossier__c (after delete, after insert, after undelete, 
									after update, before delete, before insert, before update) {
	DossierUtil.entry(new TriggerParams(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
															trigger.isUndelete, trigger.new, trigger.old, trigger.newMap, trigger.oldMap));	
}