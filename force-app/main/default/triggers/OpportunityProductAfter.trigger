/**
    About
    -----
    Description: After trigger on Opportunity Product object
    Create date: June 2015
    
    Filters:
    -------
    1. Filters out all the opportunities that are related to opportunity products where sales outcome is not equal to null
    2. Filters out all the opportunitites that are related to opportunity products that are deleted
    3. Filters out all the products that belongs to a closed/won opportunity
    
    Update History
    --------------
    Created Jun 2015 - V.I
    Updated Oct 2015 - V.I
    Updated Sep 2016 - A.N This trigger has been replaced by OpportunityLineItem.trigger and will be deleted
    
    Issues / TODOs
    --------------  

    DELETE THIS CLASS

*/

trigger OpportunityProductAfter on OpportunityLineItem (after update, after delete, after undelete, after insert) {
    /*
    System.debug('OpportunityProductBeforeInsert trigger starts');
    
    //Creating Lists and Maps based on filter criteria
    List<Id> updateSalesOutcome = new List<Id>();
    List<Opportunity> closedWonOpps = new List<Opportunity>();
    List<Id> allOppIds = new List<Id>();
    
    if(!Trigger.isDelete){
        for(OpportunityLineItem oli : Trigger.new){
            //Filter 1
            if(oli.Sales_Outcome__c != null){
                updateSalesOutcome.add(oli.OpportunityId);
            }
        //Filter 3
        allOppIds.add(oli.OpportunityId);
        }
    }
    //Filter 2
    else{    
        for(OpportunityLineItem oli : Trigger.old){
            if(oli.Sales_Outcome__c != null){
                updateSalesOutcome.add(oli.OpportunityId);
            }
        //Filter 3
        allOppIds.add(oli.OpportunityId);
        }
    }

    //Execute logic in a service class 
    //Filter 1 & 2
    if(updateSalesOutcome.size() > 0){
        OpportunityServiceClass.updateSalesOutcome(updateSalesOutcome);
    } 
    
    //Filter 3
    closedWonOpps = [Select Id, CloseDate, OwnerId, AccountId from Opportunity where Id in : allOppIds and isWon = true];
    if(!closedWonOpps.isEmpty()){
        SolutionsSalesOutcomeServiceClass.deleteExistingRecords(closedWonOpps);
        SolutionsSalesOutcomeServiceClass.createNewRecords(closedWonOpps);
    }
    */
}