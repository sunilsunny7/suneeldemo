// Id batchInstanceId = Database.executeBatch(new UpdateOpportunityLineItemBatch(''), 1); // Needs to be ran with batch size 1 for process builder update to work
global class UpdateOpportunityLineItemBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global UpdateOpportunityLineItemBatch(String customQuery) {
		if(customQuery == null || customQuery == ''){
			query = 'SELECT Id, Product_Family__c FROM OpportunityLineItem WHERE Product_Family__c = null';
		} else {
			query = customQuery;
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<OpportunityLineItem> oliList) {
		update oliList;
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('UpdateOpportunityLineItemBatch finished');
	}
}