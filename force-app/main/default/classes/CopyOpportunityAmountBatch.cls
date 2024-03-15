// NOTE: In order to run this batch class without reducing the batch size, the opportunity trigger must be deactivated!
// Id batchInstanceId = Database.executeBatch(new CopyOpportunityAmountBatch()); // Default batchsize 200

global class CopyOpportunityAmountBatch implements Database.Batchable<sObject>{    
	
	String query;

    global CopyOpportunityAmountBatch(){
    	query = 'Select Id, Large_New_Sales__c, Large_Continuation_Sales__c, Winback_Revenue_12_month__c, Retain_Revenue_12_month__c from Opportunity';
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        
        for(Opportunity opp : oppList){
        	if(opp.Large_New_Sales__c == null || opp.Large_New_Sales__c == 0){
        		opp.Large_New_Sales__c = opp.Winback_Revenue_12_month__c;
        	}
        	if(opp.Large_Continuation_Sales__c == null || opp.Large_Continuation_Sales__c == 0){
        		opp.Large_Continuation_Sales__c = opp.Retain_Revenue_12_month__c;
        	}
        }
        update oppList;
    }
    
    global void finish(Database.BatchableContext BC){}
}