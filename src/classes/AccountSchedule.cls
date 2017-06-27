global class AccountSchedule  implements Database.batchable<sObject>, Database.AllowsCallouts , Database.Stateful {
	public Set <Id> dossierIds = new Set <Id>();
	public AccountSchedule (Set <Id> dossierIds) {
		this.dossierIds = dossierIds;
	}
	public Database.QueryLocator start(Database.BatchableContext BC) {
	    String query = 'SELECT Id FROM Dossier__c  limit 1';	
        return Database.getQueryLocator(query);
    }
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		DossierUtil.getTFNumber(dossierIds);
		
	}
	public void finish(Database.BatchableContext BC) {
	}
}