// Id batchInstanceId = Database.executeBatch(new SetOpportunityWeekBatch()); // Default batchsize 200
//system.debug('batchInstanceId: ' + batchInstanceId);
global class SetOpportunityWeekBatch implements Database.Batchable<sObject>{    
    
    String query;

    global SetOpportunityWeekBatch(){
        query = 'Select Id, Telia_Week__c, CloseDate from Opportunity WHERE Telia_Week__c = null';
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        
        for(Opportunity opp : oppList){
                opp.Telia_Week__c = SEUTility.getWeekNumber(opp.CloseDate);
        }
        Database.update(oppList, false);
    }
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}