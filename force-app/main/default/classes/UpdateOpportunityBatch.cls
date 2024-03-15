// This is a general batch job for forcing an update to a set of opportunities.
// Typically this will be run if we need to update the field value of some newly created field
// Note: Add a custom query to the batch constructor call to specify which opportunities you want to update

// Id batchInstanceId = Database.executeBatch(new UpdateOpportunityBatch('[QUERY]'), 100); // Needs to be ran with batch size 1 for process builder update to work
global class UpdateOpportunityBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global UpdateOpportunityBatch(String customQuery) {
		if(customQuery == null || customQuery == ''){
			// This will update every opportunity in the system
			query = 'SELECT Id FROM Opportunity';
		} else {
			query = customQuery;
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
		update oppList;
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('UpdateOpportunityBatch finished');
	}
}