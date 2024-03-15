/**
About
-----
Description: Batch class to set seller on opportunity
Create date: 2015-09-10

Update History
--------------
Created Sep 2015 - V.I 

Issues / TODOs
--------------  

*/

// Integer batchSize = 5;
// Id batchInstanceId = Database.executeBatch(new CreateFolsForExistingOppsBatch(false, false)); // Default batchsize 200
// Id batchInstanceId = Database.executeBatch(new CreateFolsForExistingOppsBatch(false, false), [batchSize]); // If not using default batch size

global class CreateFolsForExistingOppsBatch implements Database.Batchable<sObject>{
    
    String query = 'SELECT Id, Seller__c, Large_New_Sales__c, Large_Continuation_Sales__c, RecordTypeId, Sales_Outcome__c, Sales_Outcome_Large__c, Probability, IsClosed, IsWon, Risk__c, Revenue_Impact_This_Year__c, CloseDate FROM Opportunity';
    Boolean isUpdate;
    Set<Id> sellerIds;

    global CreateFolsForExistingOppsBatch(String customQueryFilter, Boolean isUpdateOnly){
        System.debug(customQueryFilter);
        isUpdate = isUpdateOnly;
        query += customQueryFilter;
    }

    global CreateFolsForExistingOppsBatch(Set<Id> inputSellerIds){
        isUpdate = false;
        sellerIds = inputSellerIds;
        query += ' WHERE Id IN (SELECT Opportunity__c FROM Forecast_Opportunity_Link__c WHERE Weekly_Forecast_Item__r.Seller__c IN :sellerIds)';
    }

    global CreateFolsForExistingOppsBatch(Boolean oppsWithoutFOLsOnly, Boolean isUpdateOnly){
        isUpdate = isUpdateOnly;
        if(oppsWithoutFOLsOnly){
            query += ' WHERE Id NOT IN (SELECT Opportunity__c FROM Forecast_Opportunity_Link__c)';
        }
        query += ' ORDER BY CloseDate ASC'; 
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CreateFolsForExistingOppsBatch Database.QueryLocator start. Query is: ' + query);
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        if(isUpdate){
            OpportunityTriggerHandler.forceFOLupdate(oppList);
        } else {
            OpportunityTriggerHandler.recreateFOL(oppList);         
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
    
}